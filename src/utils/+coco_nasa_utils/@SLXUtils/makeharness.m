%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
% Notices:
%
% Copyright @ 2020 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.  All
% Rights Reserved.
%
% Disclaimers
%
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING,
% BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL CONFORM
% TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS
% FOR A PARTICULAR PURPOSE, OR FREEDOM FROM INFRINGEMENT, ANY WARRANTY THAT
% THE SUBJECT SOFTWARE WILL BE ERROR FREE, OR ANY WARRANTY THAT
% DOCUMENTATION, IF PROVIDED, WILL CONFORM TO THE SUBJECT SOFTWARE. THIS
% AGREEMENT DOES NOT, IN ANY MANNER, CONSTITUTE AN ENDORSEMENT BY
% GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT OF ANY RESULTS, RESULTING
% DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY OTHER APPLICATIONS RESULTING
% FROM USE OF THE SUBJECT SOFTWARE.  FURTHER, GOVERNMENT AGENCY DISCLAIMS
% ALL WARRANTIES AND LIABILITIES REGARDING THIRD-PARTY SOFTWARE, IF PRESENT
% IN THE ORIGINAL SOFTWARE, AND DISTRIBUTES IT "AS IS."
%
% Waiver and Indemnity:  RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS,
% AS WELL AS ANY PRIOR RECIPIENT.  IF RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES, EXPENSES OR
% LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM PRODUCTS BASED
% ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT SOFTWARE, RECIPIENT
% SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED STATES GOVERNMENT, ITS
% CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT, TO THE
% EXTENT PERMITTED BY LAW.  RECIPIENT'S SOLE REMEDY FOR ANY SUCH MATTER
% SHALL BE THE IMMEDIATE, UNILATERAL TERMINATION OF THIS AGREEMENT.
%
% Notice: The accuracy and quality of the results of running CoCoSim
% directly corresponds to the quality and accuracy of the model and the
% requirements given as inputs to CoCoSim. If the models and requirements
% are incorrectly captured or incorrectly input into CoCoSim, the results
% cannot be relied upon to generate or error check software being developed.
% Simply stated, the results of CoCoSim are only as good as
% the inputs given to CoCoSim.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [new_model_name, status] = makeharness(T, subsys_path, output_dir, postfix_name)
    % the model should be already loaded and subsys_path is the
    % path to the subsystem or the model name.
    if nargin < 4
        postfix_name = '_harness';
    end
    new_model_name = '';
    status = 0;
    try
        if isempty(T)
            display_msg('Tests struct is empty no test to be created',...
                MsgType.ERROR, 'makeharness', '');
            status = 1;
            return;
        end
        TisDataSet = false;
        if isa(T, 'Simulink.SimulationData.Dataset')
            TisDataSet = true;
        elseif ~isfield(T(1), 'time') || ~isfield(T(1), 'signals')
            display_msg('Tests struct should have "signals" and "time" fields or to be of type Simulink.SimulationData.Dataset',...
                MsgType.ERROR, 'makeharness', '');
            return;
        end
        model_full_path = coco_nasa_utils.MenuUtils.get_file_name(subsys_path);
        [model_dir, modelName, ext] = fileparts(model_full_path);
        if nargin < 3 || isempty(output_dir)
            output_dir = model_dir;
        end
        
        %get CompiledPortDataTypes of inports
        Inportsblocks = find_system(subsys_path, 'SearchDepth',1,'BlockType','Inport');
        compile_cmd = strcat(modelName, '([],[],[],''compile'')');
        eval (compile_cmd);
        compiledPortDataTypes = get_param(Inportsblocks,'CompiledPortDataTypes');
        compiledPortwidths = get_param(Inportsblocks,'CompiledPortWidths');
        compiledPortDimensions = get_param(Inportsblocks,'CompiledPortDimensions');
        %InportsDTs = cellfun(@(x) x.Outport, compiledPortDataTypes);
        term_cmd = strcat(modelName, '([],[],[],''term'')');
        eval (term_cmd);
        InportsWidths = cellfun(@(x) x.Outport, compiledPortwidths);
        for i=1:length(InportsWidths)
            if InportsWidths(i) > 1
                display_msg(sprintf('Make harness model does not support Multidimensional Inports for Inport "%s".', ...
                    HtmlItem.addOpenCmd(Inportsblocks{i})),...
                    MsgType.ERROR, 'makeharness', '');
                status = 1;
                return;
            end
        end
        acceptedDT = {'double' , 'single' , 'int8' , 'uint8' , 'int16' ,...
            'uint16' , 'int32' , 'uint32', 'boolean'};
        InportsDTs = cellfun(@(x) x.Outport, compiledPortDataTypes);
        for i=1:length(InportsDTs)
            if ~ismember(InportsDTs{i}, acceptedDT)
                display_msg(sprintf('Make harness model does not support datatype "%s" of Inport "%s".', ...
                    InportsDTs{i}, HtmlItem.addOpenCmd(Inportsblocks{i})),...
                    MsgType.ERROR, 'makeharness', '');
                status = 1;
                return;
            end
        end
        [~, subsys_name, ~] = fileparts(subsys_path);
        sampleTime = coco_nasa_utils.SLXUtils.getModelCompiledSampleTime(modelName);
        if numel(sampleTime) == 1
            sampleTime = [sampleTime, 0];
        end
        
        newBaseName = strcat(modelName, postfix_name);
        close_system(newBaseName, 0);
        new_model_name = fullfile(output_dir, strcat(newBaseName, ext));
        if exist(newBaseName, 'file'), delete(newBaseName);end
        if ~exist(new_model_name, 'file'), copyfile(model_full_path, new_model_name);end
        
        
        % create new model
        newSubName = fullfile(newBaseName, subsys_name);
        
        new_system(newBaseName);
        
        if coco_nasa_utils.MatlabUtils.contains(subsys_path, filesep)
            add_block(subsys_path, newSubName);
        else
            add_block('built-in/Subsystem', fullfile(newBaseName, subsys_name));
            Simulink.BlockDiagram.copyContentsToSubSystem...
                (subsys_path,  newSubName);
        end
        NewSubPortHandles = get_param(newSubName, 'PortHandles');
        nb_inports = numel(NewSubPortHandles.Inport);
        nb_outports = numel(NewSubPortHandles.Outport);
        max_ports = max(nb_inports, nb_outports);
        set_param(newSubName, 'Position', [350    50   510   (50+30*max_ports)]);
        % add outports
        for i=1:nb_outports
            p = get_param(NewSubPortHandles.Outport(i), 'Position');
            x = p(1) + 50;
            y = p(2);
            outport_name = strcat(newBaseName,'/Out',num2str(i));
            outport_handle = add_block('simulink/Ports & Subsystems/Out1',...
                outport_name,...
                'MakeNameUnique', 'on', ...
                'Position',[(x+10) (y) (x+30) (y+20)]);
            outportPortHandle = get_param(outport_handle,'PortHandles');
            add_line(newBaseName,...
                NewSubPortHandles.Outport(i), outportPortHandle.Inport(1),...
                'autorouting', 'on');
        end
        
        % add convertion subsystem with rate transitions
        convertSys = addConversionBlock(newBaseName, subsys_name, InportsDTs, sampleTime, nb_inports, max_ports);
        % add signal builder signal
        try
            stopTime = add_signal_builder(newBaseName, T, TisDataSet, sampleTime, convertSys,...
                nb_inports, InportsWidths, compiledPortDimensions, max_ports);
            % re-organize blocks
            BlocksPosition_pp(newBaseName, 1);
            
            configSet = getActiveConfigSet(newBaseName);
            set_param(configSet, 'SaveFormat', 'Structure', ...
                'StopTime', num2str(stopTime), ...
                'Solver', 'FixedStepDiscrete', ...
                'FixedStep', num2str(sampleTime(1)));
            save_system(newBaseName, new_model_name,'OverwriteIfChangedOnDisk',true);
            display_msg(['Generated harness model is in: ' new_model_name],...
                MsgType.RESULT, 'makeharness', '');
            %open(new_model_name)
        catch me
            display_msg('Test cases struct is not well formed.', MsgType.ERROR, 'makeharness', '');
            display_msg(me.message, MsgType.ERROR, 'makeharness', '');
            display_msg(me.getReport(), MsgType.DEBUG, 'makeharness', '');
            status = 1;
        end
        
    catch me
        display_msg('Failed generating harness model.', MsgType.ERROR, 'makeharness', '');
        display_msg(me.message, MsgType.ERROR, 'makeharness', '');
        display_msg(me.getReport(), MsgType.DEBUG, 'makeharness', '');
        status = 1;
    end
end


%% add conversion block
function convertSys = addConversionBlock(newBaseName, subsys_name, InportsDTs, sampleTime, nb_inports, max_ports)
    convertSys = fullfile(newBaseName, 'Converssion');
    add_block('built-in/Subsystem', convertSys, ...
        'Position', [270    50   290   (50+30*max_ports)], ...
        'BackgroundColor', 'black', ...
        'ForegroundColor', 'black');
    
    for i=1:nb_inports
        x = 100; y=100*i;
        inport_name = strcat(convertSys, filesep, 'In',num2str(i));
        add_block('simulink/Ports & Subsystems/In1',...
            inport_name,...
            'MakeNameUnique', 'on', ...
            'Position',[x y (x+30) (y+20)]);
        if ~strcmp(InportsDTs{i}, 'double')
            convBlkName = strcat(convertSys, filesep, 'convert', num2str(i));
            add_block('simulink/Signal Attributes/Data Type Conversion',convBlkName, ...
                'Position', [(x + 50) (y - 15) (x + 100) (y+35)],...
                'OutDataTypeStr', InportsDTs{i});
            add_line(convertSys, ...
                strcat('In',num2str(i), '/1'), ...
                strcat('convert', num2str(i), '/1'), ...
                'autorouting','on');
        end
        rateBlkName = strcat(convertSys, filesep, 'rateT', num2str(i));
        add_block('simulink/Signal Attributes/Rate Transition',rateBlkName, ...
            'Position', [(x + 150) (y - 15) (x + 200) (y+35)],...
            'Integrity', 'off', ...
            'Deterministic', 'off', ...
            'OutPortSampleTime', mat2str(sampleTime));
        if ~strcmp(InportsDTs{i}, 'double')
            add_line(convertSys, ...
                strcat('convert', num2str(i), '/1'), ...
                strcat('rateT', num2str(i), '/1'), ...
                'autorouting','on');
        else
            add_line(convertSys, ...
                strcat('In',num2str(i), '/1'), ...
                strcat('rateT', num2str(i), '/1'), ...
                'autorouting','on');
        end
        
        outport_name = strcat(convertSys, filesep, 'Out',num2str(i));
        add_block('simulink/Ports & Subsystems/Out1',...
            outport_name,...
            'MakeNameUnique', 'on', ...
            'Position', [(x + 300) y (x + 330) (y+20)]);
        add_line(convertSys, ...
            strcat('rateT', num2str(i), '/1'), ...
            strcat('Out',num2str(i), '/1'), ...
            'autorouting','on');
        
        %link conversion subsystem to model subsystem.
        add_line(newBaseName, ...
            strcat('Converssion', '/', num2str(i)), ...
            strcat(subsys_name, '/', num2str(i)), ...
            'autorouting','on');
        
    end
end

%% add_signal_builder: Signal Builder does not support multi-dimensional arrays
function stopTime = add_signal_builder(newBaseName, T, TisDataSet, sampleTime, convertSys,...
        nb_inports, InportsWidths, compiledPortDimensions, max_ports)
    % for tests with one step should be adapted
    if TisDataSet
        % case of Simulink dataset
        for i=1:length(T)
            ds = T(i);
            nbSignals = length(ds.getElementNames);
            for j=1:nbSignals
                if length(ds{j}.Values.Time) == 1
                    ds{j}.Values.Time(2) = sampleTime(1);
                    ds{j}.Values.Data(2) = ds{j}.Values.Data(1);
                end
            end
            T(i) = ds;
        end
    else
        % case of struct with signals and time.
        for i=1:numel(T)
            if numel(T(i).time) == 1
                T(i).time(2) = sampleTime(1);
                for j=1:numel( T(i).signals)
                    T(i).signals(j).values(2) = T(i).signals(j).values(1);
                end
            end
        end
    end
    signalBuilderName = fullfile(newBaseName, 'Inputs');
    if TisDataSet
        ds = T(1);
        nbSignals = length(ds.getElementNames);
        signalbuilder(signalBuilderName, 'create', ds{1}.Values.Time,...
            arrayfun(@(j) {double(ds{j}.Values.Data)}, (1:nbSignals))');
    else
        signalbuilder(signalBuilderName, 'create', T(1).time,...
            arrayfun(@(x) {double(x.values)}, T(1).signals)');
    end
    if TisDataSet
        % we assume all signals in the same dataset have the same Time.
        ds = T(1);
        stopTime = ds{1}.Values.Time(end) + 0.0000000000001;
    else
        stopTime = T(1).time(end) + 0.0000000000001;
    end
    for i=2:numel(T)
        try
            if TisDataSet
                ds = T(i);
                nbSignals = length(ds.getElementNames);
                signalbuilder(signalBuilderName, 'appendgroup', ...
                    ds{1}.Values.Time, ...
                    arrayfun(@(j) {double(ds{j}.Values.Data)}, (1:nbSignals))');
                if ds{1}.Values.Time(end) > stopTime
                    stopTime = ds{1}.Values.Time(end) + 0.0000000000001;
                end
            else
                signalbuilder(signalBuilderName, 'appendgroup', ...
                    T(i).time, ...
                    arrayfun(@(x) {double(x.values)}, T(i).signals)');
                if T(i).time(end) > stopTime
                    stopTime = T(i).time(end) + 0.0000000000001;
                end
            end
        catch me
            display_msg(me.getReport(), MsgType.DEBUG, 'makeharness', '');
        end
    end
    set_param(signalBuilderName, 'Position', [50    50   210   (50+30*max_ports)]);
    in_idx = 1;
    sgPortHandle = get_param(signalBuilderName,'PortHandles');
    convPortHandle = get_param(convertSys, 'PortHandles');
    for i=1:nb_inports
        if InportsWidths(i) > 1
            
            for j=1:InportsWidths(i)
                if j == 1
                    % add Mux block Inputs
                    muxH = add_block('built-in/Mux',...
                        fullfile(newBaseName, 'Mux'),...
                        'MAKENAMEUNIQUE','ON', ...
                        'Inputs', num2str(InportsWidths(i)));
                    muxPortHandle = get_param(muxH,'PortHandles');
                end
                add_line(newBaseName,...
                    sgPortHandle.Outport(in_idx), ...
                    muxPortHandle.Inport(j),...
                    'autorouting', 'on');
                
                in_idx = in_idx +1;
            end
            reshapeH = add_block('simulink/Math Operations/Reshape',...
                fullfile(newBaseName, 'Reshape'),...
                'MAKENAMEUNIQUE','ON', ...
                'OutputDimensionality', 'Customize', ...
                'OutputDimensions', mat2str(compiledPortDimensions{i}.Outport(2:end)));
            reshapePortHandle = get_param(reshapeH,'PortHandles');
            add_line(newBaseName, ...
                muxPortHandle.Outport(1), ...
                reshapePortHandle.Inport(1), ...
                'autorouting','on');
            add_line(newBaseName, ...
                reshapePortHandle.Outport(1), ...
                convPortHandle.Inport(i), ...
                'autorouting','on');
        else
            add_line(newBaseName, ...
                sgPortHandle.Outport(in_idx), ...
                convPortHandle.Inport(i), ...
                'autorouting','on');
            in_idx = in_idx +1;
        end
    end
    
end
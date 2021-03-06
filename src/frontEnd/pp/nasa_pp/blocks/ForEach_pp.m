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
function [status, errors_msg] = ForEach_pp(model)
    % ForEach_pp Searches for ForEach blocks and replaces them by a
    %  equivalent subsystem.
    %   model is a string containing the name of the model to search in
    status = 0;
    errors_msg = {};
    
    ForEach_list = find_system(model,...
        'LookUnderMasks', 'all', 'BlockType','ForEach');
    if not(isempty(ForEach_list))
        display_msg('Processing ForEach blocks...', MsgType.INFO, 'ForEach_pp', '');
        for i=length(ForEach_list):-1:1
            try
                display_msg(ForEach_list{i}, MsgType.INFO, 'ForEach_pp', '');
                expand_ForEach(model, ForEach_list{i});
            catch me
                display_msg(me.getReport(), MsgType.DEBUG, 'ForEach_pp', '');
                status = 1;
                errors_msg{end + 1} = sprintf('ForEach pre-process has failed for block %s', ForEach_list{i});
                continue;
            end
        end
        display_msg('Done\n\n', MsgType.INFO, 'ForEach_pp', '');
    end
end

function [] = expand_ForEach(model, blk)
    %% get block information
    forEachSubsys = fileparts(blk);
    feval(model, [],[],[],'compile');
    try
        portsHandles = get_param(forEachSubsys, 'PortHandles');
        portsDimnesions = get_param(portsHandles.Inport, 'CompiledPortDimensions');
        InputPartitionDimensions = get_param(blk, 'InputPartitionDimension');
        InputPartitionWidths = get_param(blk, 'InputPartitionWidth');
        OutputConcatenationDimensions = get_param(blk, 'OutputConcatenationDimension');
    catch me
        feval(model, [],[],[],'term');
        rethrow(me);
        return;
    end
    feval(model, [],[],[],'term');
    %in case there is variables from workspace
    InputPartitionDimensions = cellfun(@(x) evalin('base', x),...
        InputPartitionDimensions);
    InputPartitionWidths = cellfun(@(x) evalin('base', x),...
        InputPartitionWidths);
    OutputConcatenationDimensions = cellfun(@(x) evalin('base', x),...
        OutputConcatenationDimensions);
    nb_inports = numel(portsHandles.Inport);
    nb_outports= numel(portsHandles.Outport);
    %% we should calculate the number of partitions that will be applied
    % to inputs. For example for a signal of size [3,2,4] and with a partition
    % dimension 3 and partition width 2. We will have 2 partitions of the input
    % [3,2,2] x 2
    % the number of partitions will be also the number of
    % "selectors/vector concstenate" to create for each inport.
    % It will be also the number of copies of ForEach
    % subsystem.
    if iscell(portsDimnesions), firstPortDim = portsDimnesions{1};
    else firstPortDim = portsDimnesions; end
    firstInputPartitionDim = InputPartitionDimensions(1);
    firstInputPartitionWidth = InputPartitionWidths(1);
    nb_partition = firstPortDim(firstInputPartitionDim+1) / firstInputPartitionWidth;
    
    %% Create nb_partition copy of forEachSubsys and selectors and vector
    % concstenate.
    equivSubPath = strcat(forEachSubsys, '_tmp');
    
    equivSubHandle = add_block('built-in/Subsystem', equivSubPath,...
        'MakeNameUnique', 'on');
    
    %make sure the creation does not change the name
    equivSubName = get_param(equivSubHandle, 'Name');
    equivSubPath = fullfile(fileparts(equivSubPath), equivSubName);
    
    % Create inports
    for i=1:nb_inports
        inport_name = strcat(equivSubPath,'/In',num2str(i));
        add_block('simulink/Ports & Subsystems/In1',...
            inport_name,...
            'MakeNameUnique', 'on');
    end
    
    % Create outports
    for outport_idx=1:nb_outports
        concat_name = strcat('Concatenate_', num2str(outport_idx));
        concat_path = fullfile(equivSubPath, concat_name);
        
        NumInputs = nb_partition;
        ConcatenateDimension = OutputConcatenationDimensions(outport_idx);
        add_block('simulink/Math Operations/Vector Concatenate',...
            concat_path,...
            'MakeNameUnique', 'on', ...
            'NumInputs', num2str(NumInputs), ...
            'ConcatenateDimension', num2str(ConcatenateDimension), ...
            'Mode','Multidimensional array');
        outport_name = strcat(equivSubPath,'/Out',num2str(outport_idx));
        add_block('simulink/Ports & Subsystems/Out1',...
            outport_name,...
            'MakeNameUnique', 'on');
        
        add_line(equivSubPath,...
            strcat(concat_name, '/1'), ...
            strcat('Out', num2str(outport_idx), '/1'));
    end
    
    
    % create nb_partition copy of forEachSubsys
    for partition_idx=1:nb_partition
        CopyName = strcat('ForEach', num2str(partition_idx));
        CopyPath = fullfile(equivSubPath, CopyName);
        add_block(forEachSubsys, CopyPath);
        For_Eachblock = find_system(CopyPath, 'SearchDepth',1, ...
            'BlockType', 'ForEach');
        delete_block(For_Eachblock);
        %add selectors
        for inport_idx=1:nb_inports
            if iscell(portsDimnesions)
                inport_dim = portsDimnesions{inport_idx};
            else
                inport_dim = portsDimnesions; 
            end
            NumberOfDimensions = inport_dim(1);
            InputPartitionDim = InputPartitionDimensions(inport_idx);
            InputPartitionWidth = InputPartitionWidths(inport_idx);
            IndexOptionArray = arrayfun(@(x) {'Select all'}, ...
                (1:NumberOfDimensions));
            IndexOptionArray{InputPartitionDim} = 'Index vector (dialog)';
            
            IndexParamArray = arrayfun(@(x) {''}, ...
                (1:NumberOfDimensions));
            IndexParamArray{InputPartitionDim} = ...
                mat2str(((partition_idx-1)*InputPartitionWidth + 1 : InputPartitionWidth*partition_idx));
            selector_name = strcat('Selector_',...
                num2str(partition_idx), strcat('_In',num2str(inport_idx)));
            selector_path = fullfile(equivSubPath, selector_name);
            
            
            add_block('simulink/Signal Routing/Selector',...
                selector_path,...
                'MakeNameUnique', 'on', ...
                'IndexMode', 'One-based',...
                'IndexParamArray', IndexParamArray, ...
                'NumberOfDimensions', num2str(NumberOfDimensions),...
                'IndexOptionArray',IndexOptionArray, ...
                'InputPortWidth', '-1');
            add_line(equivSubPath,...
                strcat('In', num2str(inport_idx), '/1'),...
                strcat(selector_name, '/1'));
            add_line(equivSubPath,...
                strcat(selector_name, '/1'), ...
                strcat(CopyName, '/', num2str(inport_idx)));
        end
        for outport_idx=1:nb_outports
            concat_name = strcat('Concatenate_', num2str(outport_idx));
            add_line(equivSubPath,...
                strcat(CopyName, '/', num2str(outport_idx)),...
                strcat(concat_name, '/', num2str(partition_idx)));
        end
    end
    
    
    BlocksPosition_pp(equivSubPath);
    %% Replace the block by the new_block
    Orient=get_param(forEachSubsys,'orientation');
    Size=get_param(forEachSubsys,'position');
    delete_block(forEachSubsys);
    add_block(equivSubPath,forEachSubsys, ...
        'MakeNameUnique', 'on', ...
        'Orientation',Orient, ...
        'Position',Size);
    delete_block(equivSubPath);
end
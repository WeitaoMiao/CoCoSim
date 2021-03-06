%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Author: 
%   Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Block_Test
    %BLOCK_TEST : all other blocks test class inherit from this class
    properties(Constant)
        condExecSS = {'reset', 'trigger', 'enable', 'enable_trigger', 'if'};
    end
    
    methods(Abstract)
        status = generateTests(obj, outputDir)
    end
    methods(Static)
        function status = generateAllTests(outputDir, deleteIfExists)
            % Get the list of functions called X_test.m
            [slx_tests_root, ~, ~] = fileparts(mfilename('fullpath'));
            functions = dir(fullfile(slx_tests_root , '*_Test.m'));
            PWD = pwd;
            cd(slx_tests_root)
            % loop over the files
            for i=1:numel(functions)
                fun_name = functions(i).name(1:end-2);
                if strcmp(fun_name, 'Block_Test')
                    continue;
                end
                display_msg(['runing ' fun_name], MsgType.INFO, 'Block_Test', '');
                
                fh = str2func(fun_name);
                b = fh();
                new_outputDir = fullfile(outputDir, strrep(fun_name, '_Test', ''));
                coco_nasa_utils.MatlabUtils.mkdir(new_outputDir);
                status = b.generateTests(new_outputDir, deleteIfExists);
                if status
                    display_msg([fun_name ' Failed'], MsgType.ERROR, 'Block_Test', '');
                end
            end
            cd(PWD);
            
        end
        
        %%
        function status = connectBlockToInportsOutports(blk_path)
            status = 0;
            try
                parent = get_param(blk_path, 'Parent');
            catch
                parent = fileparts(blk_path);
            end
            blokPortHandles = get_param(blk_path, 'PortHandles');
            inputPorts = [blokPortHandles.Enable, ...
                blokPortHandles.Ifaction, ...
                blokPortHandles.Inport, ...
                blokPortHandles.Reset, ...
                blokPortHandles.Trigger];
            for i=1:numel(inputPorts)
                status = status + addInport(inputPorts(i));
            end
            for i=1:numel(blokPortHandles.Outport)
                status = status + addOutport(blokPortHandles.Outport(i));
            end
            BlocksPosition_pp(parent, 0);
            function status = addInport(newBlkPort)
                try
                    status = 0;
                    if get_param(newBlkPort, 'line') > 0
                        % already connected
                        return;
                    end
                    inport_name = fullfile(parent, 'In1');
                    inport_handle = add_block('simulink/Ports & Subsystems/In1',...
                        inport_name,...
                        'MakeNameUnique', 'on');
                    inportPortHandles = get_param(inport_handle, 'PortHandles');
                    add_line(parent,...
                        inportPortHandles.Outport(1), newBlkPort,...
                        'autorouting', 'on');
                catch Me
                    display_msg(Me.getReport(), ...
                        MsgType.DEBUG, 'Block_Test', '');
                    status = 1;
                end
            end
            function status = addOutport(newBlkPort)
                try
                    status = 0;
                    if get_param(newBlkPort, 'line') > 0
                        % already connected
                        return;
                    end
                    outport_name = fullfile(parent, 'Out1');
                    outport_handle = add_block('simulink/Ports & Subsystems/Out1',...
                        outport_name,...
                        'MakeNameUnique', 'on');
                    outportPortHandles = get_param(outport_handle, 'PortHandles');
                    add_line(parent,...
                        newBlkPort, outportPortHandles.Inport(1),...
                        'autorouting', 'on');
                catch Me
                    display_msg(Me.getReport(), ...
                        MsgType.DEBUG, 'Block_Test', '');
                    status = 1;
                end
            end
            % do the same for parent
            if ~strcmp(bdroot(blk_path), parent)
                status = Block_Test.connectBlockToInportsOutports(parent);
            end
        end
        
        %% propagate bus Datatype
        function propagateBusDT(inport_path, busDT)
            portIndex = str2num(get_param(inport_path, 'Port'));
            try
                blk_parent = get_param(inport_path, 'Parent');
            catch
                if ischar(inport_path)
                    blk_parent = fileparts(inport_path);
                else
                    return;
                end
            end
            bdroot_handle = get_param(bdroot(inport_path), 'Handle');
            blk_parent_h = get_param(blk_parent, 'Handle');
            if bdroot_handle ~= blk_parent_h
                subsystemPortHandles = get_param(blk_parent, 'PortHandles');
                l = get_param(subsystemPortHandles.Inport(portIndex), 'line');
                if l > 0
                    srcBlockHandle = get_param(l, 'SrcBlockHandle');
                    try
                        set_param(srcBlockHandle, ...
                            'OutDataTypeStr', busDT, ...
                            'BusOutputAsStruct', 'on');
                    catch
                    end
                    if strcmp(get_param(srcBlockHandle, 'BlockType'), 'Inport')
                        Block_Test.propagateBusDT(srcBlockHandle, busDT);
                    end
                end
            end
        end
        
        %% get block params from structur
        function blkParams = struct2blockParams(s)
            fdnames = fieldnames(s);
            blkParams = {};
            for j=1:length(fdnames)
                blkParams{end+1} = fdnames{j};
                blkParams{end+1} = s.(fdnames{j});
            end
        end
        
        %% create new model
        function [blkPath, mdl_path, skip] = create_new_model(mdl_name, outputDir, deleteIfExists, addCondExecSS, condExecSSIdx)
            skip = false;
            blkPath = '';
            mdl_path ='';
            try
                if bdIsLoaded(mdl_name), bdclose(mdl_name); end
                mdl_path = fullfile(outputDir, strcat(mdl_name, '.slx'));
                if exist(mdl_path, 'file')
                    if deleteIfExists
                        delete(mdl_path);
                    else
                        skip = true;
                    end
                end
            catch
                skip = true;
            end
            if skip
                return;
            end
            new_system(mdl_name);
            %open_system(mdl_name);
            if addCondExecSS
                if bdIsLoaded('Block_TestLib'), load_system('Block_TestLib'); end
                if condExecSSIdx > length(Block_Test.condExecSS)
                    condExecSSIdx = mod(condExecSSIdx, length(Block_Test.condExecSS)) + 1;
                end
                libPath = fullfile('Block_TestLib', Block_Test.condExecSS{condExecSSIdx});
                libDst = fullfile(mdl_name, Block_Test.condExecSS{condExecSSIdx});
                add_block(libPath, libDst);
                set_param(libDst, 'LinkStatus', 'inactive');
                SSlist = find_system(mdl_name, 'BlockType', 'SubSystem');
                % set blokPath inside the deepest Subsystem
                blkPath = fullfile(SSlist{end}, 'P');
            else
                blkPath = fullfile(mdl_name, 'P');
            end
        end
        
        %% add the block
        function add_and_connect_block(blkLibPath, blkPath, s)
            if isempty(s)
                add_block(blkLibPath, blkPath);
            else
                blkParams = Block_Test.struct2blockParams(s);
                add_block(blkLibPath, blkPath, blkParams{:});
            end
            Block_Test.connectBlockToInportsOutports(blkPath);
        end
        
        %% set configuration and save
        function failed = setConfigAndSave(mdl_name, mdl_path)
            configSet = getActiveConfigSet(mdl_name);
            set_param(configSet, 'Solver', 'FixedStepDiscrete');
            set_param(configSet, 'ParameterOverflowMsg', 'none');
            
            failed = CompileModelCheck_pp( mdl_name );
            if failed
                display_msg(['Model failed: ' mdl_name], ...
                    MsgType.ERROR, 'generateTests', '');
                save_system(mdl_name, mdl_path);
            else
                save_system(mdl_name, mdl_path);
            end
            bdclose(mdl_name);
        end
    end
end


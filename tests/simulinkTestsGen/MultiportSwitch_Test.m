%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Author: 
%   Trinh, Khanh V <khanh.v.trinh@nasa.gov>
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
classdef MultiportSwitch_Test < Block_Test
    %MultiportSwitch_Test generates test automatically.
    
    properties(Constant)
        fileNamePrefix = 'MultiportSwitch_TestGen';
        blkLibPath = 'simulink/Signal Routing/Multiport Switch';
    end
    
    properties
        % properties that will participate in permutations
        % Dependencies
        %       Selecting Zero-based contiguous or One-based contiguous 
        %           enables the Number of data ports parameter.
        %       Selecting Specify indices enables the Data port 
        %           indices parameter.        
        DataPortOrder = {'Zero-based contiguous','One-based contiguous',...
            'Specify indices'};
        %Dependencies
            % Selecting Zero-based contiguous or One-based contiguous ...
                %enables the Number of data ports parameter.
            % Selecting Specify indices enables the Data port indices parameter.
        Inputs = {'1','2','3','4'};
        DataPortIndices =  {'{[1,4],[2,3]}','{[2,4],3,[1,5]}','{1,[2,3],4}',...
            '{[1,4],[2,3],[5,6]}'};
        DataPortForDefault = {'Last data port','Additional data port'};
    end
    
    properties
        % other properties
        IndexMode =  {'Zero-based','One-based'};        
        SampleTime = {'-1'};
        RndMeth = {'Ceiling', 'Convergent', 'Floor', 'Nearest', 'Round', 'Simplest', 'Zero'};
        SaturateOnIntegerOverflow = {'off', 'on'};        
    end
    
    methods
        function status = generateTests(obj, outputDir, deleteIfExists)
            if ~exist('deleteIfExists', 'var')
                deleteIfExists = true;
            end
            status = 0;
            params = obj.getParams();
            nb_tests = length(params);
            condExecSSPeriod = floor(nb_tests/length(Block_Test.condExecSS));
            for i=1 : nb_tests
                testId = [];
                if ismember(i,testId)
                    continue;
                end
                try
                    s = params{i};
                    %% creat new model
                    mdl_name = sprintf('%s%d', obj.fileNamePrefix, i);
                    addCondExecSS = (mod(i, condExecSSPeriod) == 0);
                    condExecSSIdx = int32(i/condExecSSPeriod);
                    [blkPath, mdl_path, skip] = Block_Test.create_new_model(...
                        mdl_name, outputDir, deleteIfExists, addCondExecSS, ...
                        condExecSSIdx);
                    if skip
                        continue;
                    end
                    
                    %% remove parametres that does not belong to block params
                    %hws = get_param(mdl_name, 'modelworkspace');
                                        
                    %% add the block
                                   
                    Block_Test.add_and_connect_block(obj.blkLibPath, blkPath, s);
                    
                    %% go over inports
                    try
                        blk_parent = get_param(blkPath, 'Parent');
                    catch
                        blk_parent = fileparts(blkPath);
                    end
                    inport_list = find_system(blk_parent, ...
                        'SearchDepth',1, 'BlockType','Inport');
                    nbInpots = length(inport_list);  
                    
                    % handling dependencies 
                    if strcmp(s.DataPortOrder,'Specify indices')
                        
                    else
                        % if 1 D
                    end
                    
                    % all data port inputs to be [2x3]
                    for inPort = 2:numel(inport_list)
                        % handling dependencies
                        if strcmp(s.DataPortOrder,'Specify indices')
                            set_param(inport_list{inPort}, 'PortDimensions', '[2,3]');
                        else
                            % if 1D, then row or column vector
                            if strcmp(s.Inputs,'1')
                                set_param(inport_list{inPort}, 'PortDimensions', '[1,5]');
                            else
                                set_param(inport_list{inPort}, 'PortDimensions', '[2,3]');
                            end
                            numInpPorts = str2num(s.Inputs);
                            if strcmp(s.DataPortForDefault, 'Additional data port')
                                numInpPorts = numInpPorts + 1;
                            end
                        end
                    end
                                      
                    % set limits on control port
                    
                    % delete line from input 1 to Multiport switch
                    delete_line(blk_parent,'In1/1','P/1');

                    if strcmp(s.DataPortOrder, 'Zero-based contiguous')
                        lowerLimit = '0';
                        upperLimit = num2str(numInpPorts-1);
                        set_param(inport_list{1},...
                            'OutMin', '0', 'OutMax', num2str(numInpPorts-1));
                    else
                        lowerLimit = '1';
                        upperLimit = num2str(numInpPorts);                        
                        set_param(inport_list{1},...
                            'OutMin', '1', 'OutMax', num2str(numInpPorts));
                    end
                    
                    % add saturation block
                    add_block('simulink/Discontinuities/Saturation', ...
                        fullfile(blk_parent, 'Satur'), ...
                        'LowerLimit',lowerLimit,...
                        'UpperLimit',upperLimit);   
                    % connect saturation block
                    add_line(blk_parent,'In1/1','Satur/1','autorouting','on');
                    add_line(blk_parent,'Satur/1','P/1','autorouting','on');
                    
                    %% set model configuration parameters and save model if it compiles
                    failed = Block_Test.setConfigAndSave(mdl_name, mdl_path);
                    if failed, display(s), end
                catch me
                    display(s);
                    display_msg(['Model failed: ' mdl_name], ...
                        MsgType.DEBUG, 'generateTests', '');
                    display_msg(me.getReport(), MsgType.ERROR, 'generateTests', '');
                    bdclose(mdl_name)
                end
            end
        end
        
        function params2 = getParams(obj)
            
            params1 = obj.getPermutations();
            params2 = cell(1, length(params1));
            for p1 = 1 : length(params1)
                s = params1{p1};
                
                params2{p1} = s;
            end
        end
        
        function params = getPermutations(obj)
            params = {};       
            for pDataPortOrder = 1 : numel(obj.DataPortOrder)  
                for pDataPortForDefault = 1:numel(obj.DataPortForDefault)
                    if strcmp(obj.DataPortOrder{pDataPortOrder},'Specify indices')                    
                        for pDataPortIndices = 1 : numel( obj.DataPortIndices )
                            s = struct();
                            s.DataPortOrder = obj.DataPortOrder{pDataPortOrder};
                            s.DataPortForDefault = ...
                                obj.DataPortForDefault{pDataPortForDefault};                            
                            s.DataPortIndices = obj.DataPortIndices{pDataPortIndices};   
                            params{end+1} = s;
                        end                        
                    else
                        for pInputs = 1 : numel( obj.Inputs )
                            s = struct();
                            s.DataPortOrder = obj.DataPortOrder{pDataPortOrder};
                            s.DataPortForDefault = ...
                                obj.DataPortForDefault{pDataPortForDefault};                            
                            s.Inputs = obj.Inputs{pInputs};  
                            params{end+1} = s;
                        end                           
                    end
                    
                end
                
            end
        end

    end
end


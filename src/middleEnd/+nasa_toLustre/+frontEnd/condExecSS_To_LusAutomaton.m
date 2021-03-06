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
function [ main_node] = condExecSS_To_LusAutomaton( parent_ir, ss_ir, ...
    hasEnablePort, hasActionPort, hasTriggerPort, isContractBlk, main_sampleTime, xml_trace)
    %condExecSS_To_LusAutomaton create an automaton lustre node for
    %enabled/triggered/Action subsystem
    %INPUTS:
    %   ss_ir: The internal representation of the subsystem.
    

    %
    %
    
    
    % Adding lustre comments tracking the original path
    
    
    % creating node header
    if hasTriggerPort && hasEnablePort
        isEnableORAction = 0;
        isEnableAndTrigger = 1;
    else
        isEnableORAction = 1;
        isEnableAndTrigger = 0;
    end
    is_main_node = 0;
    isMatlabFunction = false;
    [blk_name, node_inputs, node_outputs,...
        node_inputs_withoutDT, node_outputs_withoutDT] = ...
       nasa_toLustre.utils.SLX2LusUtils.extractNodeHeader(parent_ir, ss_ir, is_main_node, ...
        isEnableORAction, isEnableAndTrigger, isContractBlk, isMatlabFunction,...
        main_sampleTime, xml_trace);
    
    
    
    node_name = strcat(blk_name, '_condExecSS');
    
    
    % Body code
    if isEnableAndTrigger
        % the case of enabledTriggered subsystem
        [body, variables] = write_enabled_AND_triggered_action_SS(ss_ir, blk_name, ...
            node_inputs_withoutDT, node_outputs_withoutDT);
    else
        [body, variables] = write_enabled_OR_triggered_OR_action_SS(ss_ir, blk_name, ...
            node_inputs_withoutDT, node_outputs_withoutDT, hasEnablePort, hasActionPort, hasTriggerPort);
        
    end
    comment = nasa_toLustre.lustreAst.LustreComment(...
        sprintf('Original block name: %s', ss_ir.Origin_path), true);
    main_node = nasa_toLustre.lustreAst.LustreNode(...
        comment, ...
        node_name,...
        node_inputs, ...
        node_outputs, ...
        {}, ...
        variables, ...
        body, ...
        is_main_node);
    
end


%%
function [body, variables_cell] =...
        write_enabled_OR_triggered_OR_action_SS(subsys, blk_name, ...
        node_inputs_withoutDT, node_outputs_withoutDT, hasEnablePort, hasActionPort, hasTriggerPort, original_node_call)
    %
    %
    % get the original node call
    if ~exist('original_node_call', 'var')
        original_node_call = nasa_toLustre.lustreAst.LustreEq(node_outputs_withoutDT, ...
            nasa_toLustre.lustreAst.NodeCallExpr(blk_name, node_inputs_withoutDT));
    end
    
    
    fields = fieldnames(subsys.Content);
    enablePortsFields = fields(...
        cellfun(@(x) (isfield(subsys.Content.(x),'BlockType')...
        && (strcmp(subsys.Content.(x).BlockType,'EnablePort') ...
        || strcmp(subsys.Content.(x).BlockType,'ActionPort')) ), fields));
    if hasTriggerPort && ~(hasEnablePort && hasActionPort)
        %the case of trigger port only
        is_restart = false;% by default
    else
        if hasEnablePort
            StatesWhenEnabling = subsys.Content.(enablePortsFields{1}).StatesWhenEnabling;
        else
            StatesWhenEnabling = subsys.Content.(enablePortsFields{1}).InitializeStates;
        end
        if strcmp(StatesWhenEnabling, 'reset')
            is_restart = true;
        else
            is_restart = false;
        end
    end
    Outportfields = ...
        fields(cellfun(@(x) (isfield(subsys.Content.(x),'BlockType')...
        && strcmp(subsys.Content.(x).BlockType, 'Outport')), fields));
    variables_cell = {};
    pre_out_str = {};
    inactiveStatement = {};
    for i=1:numel(Outportfields)
        outport_blk = subsys.Content.(Outportfields{i});
        [outputs_i, outputs_DT_i] =nasa_toLustre.utils.SLX2LusUtils.getBlockOutputsNames(subsys, outport_blk);
        OutputWhenDisabled = outport_blk.OutputWhenDisabled;
        InitialOutput_cell =nasa_toLustre.utils.SLX2LusUtils.getInitialOutput(subsys, outport_blk,...
            outport_blk.InitialOutput, outport_blk.CompiledPortDataTypes.Inport{1}, outport_blk.CompiledPortWidths.Inport);
        for out_idx=1:numel(outputs_i)
            out_name = outputs_i{out_idx}.getId();
            pre_out_name = sprintf('pre_%s',out_name);
            variables_cell{end + 1} = nasa_toLustre.lustreAst.LustreVar(pre_out_name, ...
                outputs_DT_i{out_idx}.getDT());
            inactiveStatement{end+1} = nasa_toLustre.lustreAst.LustreEq(outputs_i{out_idx}, ...
                nasa_toLustre.lustreAst.VarIdExpr(pre_out_name));
            if strcmp(OutputWhenDisabled, 'reset') && (hasActionPort || hasEnablePort)
                pre_out_str{end+1} = nasa_toLustre.lustreAst.LustreEq(nasa_toLustre.lustreAst.VarIdExpr(pre_out_name),...
                    InitialOutput_cell{out_idx});
            else
                pre_out_str{end+1} = nasa_toLustre.lustreAst.LustreEq(...
                    nasa_toLustre.lustreAst.VarIdExpr(pre_out_name),...
                    nasa_toLustre.lustreAst.IteExpr(nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.GT, ...
                    nasa_toLustre.lustreAst.VarIdExpr(nasa_toLustre.utils.SLX2LusUtils.nbStepStr()),...
                    nasa_toLustre.lustreAst.IntExpr(0)), ...
                    nasa_toLustre.lustreAst.UnaryExpr(nasa_toLustre.lustreAst.UnaryExpr.PRE, outputs_i{out_idx}), ...
                    InitialOutput_cell{out_idx}));
            end
        end
    end
    %
    % body_template = 'automaton enabled_%s\n\t';
    % body_template = [body_template, 'state Active_%s:\n\t'];
    % body_template = [body_template, 'unless (not %s) restart Inactive_%s\n\t'];
    % body_template = [body_template, 'let\n\t'];
    % body_template = [body_template, ' %s\n\t'];%call of subsystem
    % body_template = [body_template, 'tel\n\t'];
    % body_template = [body_template, 'state Inactive_%s:\n\t'];
    % body_template = [body_template, 'unless %s %s Active_%s\n\t'];
    % body_template = [body_template, 'let\n\t'];
    % body_template = [body_template, ' %s\n\t'];%out = pre_out;
    % body_template = [body_template, 'tel\n\t'];
    % automaton = sprintf(body_template, ...
    %     blk_name,...
    %     blk_name,...
    %    nasa_toLustre.utils.SLX2LusUtils.isEnabledStr(), blk_name,...
    %     original_node_call, ...
    %     blk_name,...
    %    nasa_toLustre.utils.SLX2LusUtils.isEnabledStr(), resumeOrRestart, blk_name,...
    %     inactiveStatement);
    automaton_name = sprintf('enabled_%s', blk_name);
    active_state_name = sprintf('Active_%s', blk_name);
    inactive_state_name = sprintf('Inactive_%s', blk_name);
    states{1} = nasa_toLustre.lustreAst.AutomatonState(active_state_name, ...
        {},...
        {nasa_toLustre.lustreAst.AutomatonTransExpr(nasa_toLustre.lustreAst.UnaryExpr(nasa_toLustre.lustreAst.UnaryExpr.NOT, ...
        nasa_toLustre.lustreAst.VarIdExpr(nasa_toLustre.utils.SLX2LusUtils.isEnabledStr())),...
        true, ...
        inactive_state_name)},...
        {}, ...
        {original_node_call});
    states{2} = nasa_toLustre.lustreAst.AutomatonState(inactive_state_name, ...
        {},...
        {nasa_toLustre.lustreAst.AutomatonTransExpr(nasa_toLustre.lustreAst.VarIdExpr(nasa_toLustre.utils.SLX2LusUtils.isEnabledStr()),...
        is_restart, ...
        active_state_name)},...
        {}, ...
        inactiveStatement);
    automaton{1} = nasa_toLustre.lustreAst.LustreAutomaton(automaton_name, states);
    body = [ pre_out_str, automaton];
    
end

%%
function [body, variables_cell] = write_enabled_AND_triggered_action_SS(subsys, blk_name, ...
        node_inputs_withoutDT, node_outputs_withoutDT)
    
    %
    %
    % get the original node call
    original_node_call = nasa_toLustre.lustreAst.LustreEq(node_outputs_withoutDT, ...
        nasa_toLustre.lustreAst.NodeCallExpr(blk_name, node_inputs_withoutDT));
    
    
    
    fields = fieldnames(subsys.Content);
    
    Outportfields = ...
        fields(cellfun(@(x) (isfield(subsys.Content.(x),'BlockType')...
        && strcmp(subsys.Content.(x).BlockType, 'Outport')), fields));
    variables_cell = {};
    pre_out_str = {};
    inactiveStatement = {};
    for i=1:numel(Outportfields)
        outport_blk = subsys.Content.(Outportfields{i});
        [outputs_i, outputs_DT_i] =nasa_toLustre.utils.SLX2LusUtils.getBlockOutputsNames(subsys, outport_blk);
        OutputWhenDisabled = outport_blk.OutputWhenDisabled;
        InitialOutput_cell =nasa_toLustre.utils.SLX2LusUtils.getInitialOutput(subsys, outport_blk,...
            outport_blk.InitialOutput, ...
            outport_blk.CompiledPortDataTypes.Inport{1}, outport_blk.CompiledPortWidths.Inport);
        for out_idx=1:numel(outputs_i)
            out_name = outputs_i{out_idx}.getId();
            if strcmp(OutputWhenDisabled, 'reset')
                pre_held_name = sprintf('pre_held_%s',out_name);
                variables_cell{end + 1} = nasa_toLustre.lustreAst.LustreVar(pre_held_name, ...
                    outputs_DT_i{out_idx}.getDT());
                pre_out_str{end+1} = nasa_toLustre.lustreAst.LustreEq(...
                    nasa_toLustre.lustreAst.VarIdExpr(pre_held_name),...
                    nasa_toLustre.lustreAst.IteExpr(nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.GT, ...
                    nasa_toLustre.lustreAst.VarIdExpr(nasa_toLustre.utils.SLX2LusUtils.nbStepStr()),...
                    nasa_toLustre.lustreAst.IntExpr(0)), ...
                    nasa_toLustre.lustreAst.UnaryExpr(nasa_toLustre.lustreAst.UnaryExpr.PRE, outputs_i{out_idx}), ...
                    InitialOutput_cell{out_idx}));
                inactiveStatement{end+1} = ...
                    nasa_toLustre.lustreAst.LustreEq(outputs_i{out_idx}, ...
                    nasa_toLustre.lustreAst.VarIdExpr(pre_held_name));
            else
                inactiveStatement{end+1} = ...
                    nasa_toLustre.lustreAst.LustreEq(outputs_i{out_idx}, ...
                    nasa_toLustre.lustreAst.VarIdExpr(sprintf('pre_%s',out_name)));
            end
        end
    end
    %
    % body_template = '\tautomaton triggered_%s\n\t\t';
    % body_template = [body_template, 'state Active_triggered_%s:\n\t\t'];
    % body_template = [body_template, 'unless (not %s) resume Inactive_triggered_%s\n\t\t'];
    % body_template = [body_template, 'let\n\t\t'];
    % body_template = [body_template, ' %s\n\t\t'];%call of subsystem
    % body_template = [body_template, 'tel\n\t\t'];
    % body_template = [body_template, 'state Inactive_triggered_%s:\n\t\t'];
    % body_template = [body_template, 'unless %s resume Active_triggered_%s\n\t\t'];
    % body_template = [body_template, 'let\n\t\t'];
    % body_template = [body_template, ' %s\n\t\t'];%out = pre_out;
    % body_template = [body_template, 'tel\n\t\t'];
    % automaton = sprintf(body_template, ...
    %     blk_name,...
    %     blk_name,...
    %    nasa_toLustre.utils.SLX2LusUtils.isTriggeredStr(), blk_name,...
    %     original_node_call, ...
    %     blk_name,...
    %    nasa_toLustre.utils.SLX2LusUtils.isTriggeredStr(), blk_name,...
    %     inactiveStatement);
    automaton_name = sprintf('triggered_%s', blk_name);
    active_state_name = sprintf('Active_triggered_%s', blk_name);
    inactive_state_name = sprintf('Inactive_triggered_%s', blk_name);
    states{1} = nasa_toLustre.lustreAst.AutomatonState(active_state_name, ...
        {},...
        {nasa_toLustre.lustreAst.AutomatonTransExpr(nasa_toLustre.lustreAst.UnaryExpr(nasa_toLustre.lustreAst.UnaryExpr.NOT, ...
        nasa_toLustre.lustreAst.VarIdExpr(nasa_toLustre.utils.SLX2LusUtils.isTriggeredStr())),...
        false, ...
        inactive_state_name)},...
        {}, ...
        {original_node_call});
    states{2} = nasa_toLustre.lustreAst.AutomatonState(inactive_state_name, ...
        {},...
        {nasa_toLustre.lustreAst.AutomatonTransExpr(nasa_toLustre.lustreAst.VarIdExpr(nasa_toLustre.utils.SLX2LusUtils.isTriggeredStr()),...
        false, ...
        active_state_name)},...
        {}, ...
        inactiveStatement);
    automaton = nasa_toLustre.lustreAst.LustreAutomaton(automaton_name, states);
    
    [bodyEnabledTriggered, variables_str_enabled] =...
        write_enabled_OR_triggered_OR_action_SS(subsys, blk_name, ...
        node_inputs_withoutDT, node_outputs_withoutDT, 1, 0, 0, automaton);
    body = [pre_out_str, bodyEnabledTriggered];
    if ~isempty(variables_str_enabled)
        variables_cell = [ variables_str_enabled, variables_cell];
    end
end


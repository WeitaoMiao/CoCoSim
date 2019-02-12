%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% write_children_actions
function [actions, outputs, inputs] = ...
        write_children_actions(state, actionType)
    L = nasa_toLustre.ToLustreImport.L;
    import(L{:})
    actions = {};
    outputs = {};
    inputs = {};
    global SF_STATES_NODESAST_MAP;
    childrenNames = state.Composition.Substates;
    nb_children = numel(childrenNames);
    childrenIDs = state.Composition.States;
    if isequal(state.Composition.Type, 'PARALLEL_AND')
        for i=1:nb_children
            if isequal(actionType, 'Entry')
                k=i;
                action_node_name = ...
                    SF2LusUtils.getEntryActionNodeName(...
                    childrenNames{k}, childrenIDs{k});
            else
                k=nb_children - i + 1;
                action_node_name = ...
                    SF2LusUtils.getExitActionNodeName(...
                    childrenNames{k}, childrenIDs{k});
            end
            if ~isKey(SF_STATES_NODESAST_MAP, action_node_name)
                ME = MException('COCOSIM:STATEFLOW', ...
                    'COMPILER ERROR: Not found node name "%s" in SF_STATES_NODESAST_MAP', ...
                    action_node_name);
                throw(ME);
            end
            actionNodeAst = SF_STATES_NODESAST_MAP(action_node_name);
            [call, oututs_Ids] = actionNodeAst.nodeCall(...
                true, BooleanExpr(false));
            actions{end+1} = LustreEq(oututs_Ids, call);
            outputs = [outputs, actionNodeAst.getOutputs()];
            inputs = [inputs, actionNodeAst.getInputs()];
        end
    else
        concurrent_actions = {};
        idStateVar = VarIdExpr(...
            SF2LusUtils.getStateIDName(state));
        [stateEnumType, stateInactiveEnum] = ...
            SF2LusUtils.addStateEnum(state, [], ...
            false, false, true);
        if nb_children >= 1
            inputs{end+1} = LustreVar(idStateVar, stateEnumType);
        end
        default_transition = state.Composition.DefaultTransitions;
        if isequal(actionType, 'Entry')...
                && ~isempty(default_transition)
            % we need to get the default condition code, as the
            % default transition decides what sub-state to enter while.
            % entering the state. This is the case where stateId ==
            % 0;
            %get_initial_state_code
            node_name = ...
                SF2LusUtils.getStateDefaultTransNodeName(state);
            cond = BinaryExpr(BinaryExpr.EQ, ...
                idStateVar, stateInactiveEnum);
            if isKey(SF_STATES_NODESAST_MAP, node_name)
                actionNodeAst = SF_STATES_NODESAST_MAP(node_name);
                [call, oututs_Ids] = actionNodeAst.nodeCall();

                concurrent_actions{end+1} = LustreEq(oututs_Ids, ...
                    IteExpr(cond, call, TupleExpr(oututs_Ids)));
                outputs = [outputs, actionNodeAst.getOutputs()];
                inputs = [inputs, actionNodeAst.getOutputs()];
                inputs = [inputs, actionNodeAst.getInputs()];
            else
                ME = MException('COCOSIM:STATEFLOW', ...
                    'COMPILER ERROR: Not found node name "%s" in SF_STATES_NODESAST_MAP', ...
                    node_name);
                throw(ME);
            end
        end
        isOneChildEntry = isequal(actionType, 'Entry') ...
            && (nb_children == 1) && isempty(default_transition);
        for i=1:nb_children
            % TODO: optimize the number of calls for nodes with the same output signature
            if isequal(actionType, 'Entry')
                action_node_name = ...
                    SF2LusUtils.getEntryActionNodeName(...
                    childrenNames{i}, childrenIDs{i});
            else
                action_node_name = ...
                    SF2LusUtils.getExitActionNodeName(...
                    childrenNames{i}, childrenIDs{i});
            end
            if ~isKey(SF_STATES_NODESAST_MAP, action_node_name)
                ME = MException('COCOSIM:STATEFLOW', ...
                    'COMPILER ERROR: Not found node name "%s" in SF_STATES_NODESAST_MAP', ...
                    action_node_name);
                throw(ME);
            end
            actionNodeAst = SF_STATES_NODESAST_MAP(action_node_name);
            [call, oututs_Ids] = actionNodeAst.nodeCall(...
                true, BooleanExpr(false));
            if isOneChildEntry
                concurrent_actions{end+1} = LustreEq(oututs_Ids, call);
                outputs = [outputs, actionNodeAst.getOutputs()];
                inputs = [inputs, actionNodeAst.getInputs()];
            else
                childName = SF2LusUtils.getUniqueName(...
                    childrenNames{i}, childrenIDs{i});
                [~, childEnum] = ...
                    SF2LusUtils.addStateEnum(...
                    state, childName);
                cond = BinaryExpr(BinaryExpr.EQ, ...
                    idStateVar, childEnum);
                concurrent_actions{end+1} = LustreEq(oututs_Ids, ...
                    IteExpr(cond, call, TupleExpr(oututs_Ids)));
                outputs = [outputs, actionNodeAst.getOutputs()];
                inputs = [inputs, actionNodeAst.getOutputs()];
                inputs = [inputs, actionNodeAst.getInputs()];
            end

        end
        if isequal(actionType, 'Entry') ...
                && nb_children == 0 && ...
                (~isempty(state.InnerTransitions)...
                || ~isempty(state.Composition.DefaultTransitions))
            %State that contains only transitions and junctions
            %inside
            [stateEnumType, stateInnerTransEnum] = ...
                SF2LusUtils.addStateEnum(state, [], ...
                true, false, false);
            concurrent_actions{end+1} = LustreEq(idStateVar,...
                stateInnerTransEnum);
            inputs{end+1} = LustreVar(idStateVar, stateEnumType);
            outputs{end+1} = LustreVar(idStateVar, stateEnumType);
        end

        if ~isempty(concurrent_actions)
            actions{1} = ConcurrentAssignments(concurrent_actions);
        end
    end
end


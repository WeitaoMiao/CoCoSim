function [node, external_nodes, opens, abstractedNodes] = get__Ceiling(lus_backend, varargin)
    if LusBackendType.isKIND2(lus_backend)
        import nasa_toLustre.lustreAst.*
        opens = {};
        abstractedNodes = {};
        external_nodes = {'LustDTLib__Floor'};
        node = LustreNode();
        node.setName('_Ceiling');
        node.setInputs(LustreVar('x', 'real'));
        node.setOutputs(LustreVar('y', 'int'));
        node.setIsMain(false);
        node.setBodyEqs(LustreEq(VarIdExpr('y'), ...
            UnaryExpr(UnaryExpr.NEG, ...
            NodeCallExpr('_Floor', ...
            UnaryExpr(UnaryExpr.NEG, VarIdExpr('x'), false)))));
    else
        opens = {'conv'};
        abstractedNodes = {};
        external_nodes = {};
        node = {};
    end
    
end
function [new_obj, outputs_map] = pseudoCode2Lustre_OnlyElseExp(obj, outputs_map, old_outputs_map, node, data_map)

    
    new_obj = nasa_toLustre.lustreAst.IteExpr(obj.condition.pseudoCode2Lustre(old_outputs_map, false, node, data_map),...
        obj.thenExpr.pseudoCode2Lustre(old_outputs_map, false, node, data_map),...
        obj.ElseExpr.pseudoCode2Lustre(outputs_map, false, node, data_map),...
        obj.OneLine);
end
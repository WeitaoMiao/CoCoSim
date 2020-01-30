function new_obj = changeArrowExp(obj, cond)

    new_args = cellfun(@(x) x.changeArrowExp(cond), obj.nodeArgs, 'UniformOutput', 0);
    if obj.has_restart
        condR = obj.restart_cond.changeArrowExp(cond);
    else
        condR = obj.restart_cond;
    end
    new_obj = nasa_toLustre.lustreAst.ActivateExpr(obj.nodeName, ...
        new_args, obj.activate_cond.changeArrowExp(cond), obj.has_restart, condR);
end

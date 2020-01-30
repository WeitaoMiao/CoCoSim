function code = print_lustrec(obj, backend)

    args_str = nasa_toLustre.lustreAst.NodeCallExpr.getArgsStr(obj.nodeArgs, backend);
    code = sprintf('(%s(%s) every %s)', ...
        obj.nodeName, ...
        args_str,...
        obj.cond.print(backend));
end

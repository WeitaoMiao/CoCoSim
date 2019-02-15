function new_obj = simplify(obj)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    import nasa_toLustre.lustreAst.*
    new_expr = obj.expr.simplify();
    if isa(new_expr, 'UnaryExpr') ...
            && isequal(new_expr.op, obj.op) ...
            && (isequal(obj.op, UnaryExpr.NOT) || isequal(obj.op, UnaryExpr.NEG))
        % - - x => x, not not b => b
        new_obj = new_expr.expr;
    else
        new_obj = UnaryExpr(obj.op, new_expr, obj.withPar);
    end
end

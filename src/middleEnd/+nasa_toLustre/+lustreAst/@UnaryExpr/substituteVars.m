function new_obj = substituteVars(obj, var, newVar)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    new_expr = obj.expr.substituteVars(var, newVar);
    new_obj = nasa_toLustre.lustreAst.UnaryExpr(obj.op, new_expr, obj.withPar);
end

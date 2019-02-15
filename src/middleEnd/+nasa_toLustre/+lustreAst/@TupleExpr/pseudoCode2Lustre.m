function [new_obj, outputs_map] = pseudoCode2Lustre(obj, outputs_map, isLeft)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    new_args = cell(numel(obj.args), 1);
    for i=1:numel(obj.args)
        [new_args{i}, outputs_map] = ...
            obj.args{i}.pseudoCode2Lustre(outputs_map, isLeft);
    end
    new_obj = nasa_toLustre.lustreAst.TupleExpr(new_args);
end

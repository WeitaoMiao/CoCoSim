function code = print_kind2(obj, backend)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    if isempty(obj.id)
        code = sprintf('--%%PROPERTY %s;', ...
            obj.exp.print(backend));
    else
        code = sprintf('--%%PROPERTY "%s" %s;', ...
            obj.id, ...
            obj.exp.print(backend));
    end
end

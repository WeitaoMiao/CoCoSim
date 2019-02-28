function code = listVarsWithDT(vars, backend, forNodeHeader)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin < 3
        forNodeHeader = false;
    end
    if iscell(vars)
        vars_code = cellfun(@(x) x.print(backend), vars, 'UniformOutput', 0);
        code = MatlabUtils.strjoin(vars_code, '\n\t');
    else
        code = vars.print(backend);
    end
    if forNodeHeader && LusBackendType.isJKIND(backend) && MatlabUtils.endsWith(code, ';')
        code = code(1:end-1);
    end
end

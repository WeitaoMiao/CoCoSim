classdef EnumTypeExpr < LustreExpr
    %EnumTypeExpr: e.g. type Direction = enum {North, South, East, West};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        enum_name;
        enum_args;
    end
    
    methods
        function obj = EnumTypeExpr(enum_name, enum_args)
            if iscell(enum_name)
                obj.enum_name = enum_name{1};
            else
                obj.enum_name = enum_name;
            end
            if ~iscell(enum_args)
                obj.enum_args{1} = enum_args;
            else
                obj.enum_args = enum_args;
            end
        end
        
        function enum_args = getEnumArgs(obj)
            enum_args = obj.enum_args;
        end
        function  setEnumArgs(obj, enum_args)
            if ~iscell(enum_args)
                obj.enum_args{1} = enum_args;
            else
                obj.enum_args = enum_args;
            end
        end
        
        function new_obj = deepCopy(obj)
            new_obj = EnumTypeExpr(obj.enum_name, obj.enum_args);
        end
        %% simplify expression
        function new_obj = simplify(obj)
            new_obj = obj;
        end
        %% This functions are used for ForIterator block
        function [new_obj, varIds] = changePre2Var(obj)
            varIds = {};
            new_obj = obj;
        end
        function new_obj = changeArrowExp(obj, ~)
            new_obj = obj;
        end
        %% This function is used by Stateflow function SF_To_LustreNode.getPseudoLusAction
        function varIds = GetVarIds(~)
            varIds = {};
        end
        % This function is used in Stateflow compiler to change from imperative
        % code to Lustre
        function [new_obj, outputs_map] = pseudoCode2Lustre(obj, outputs_map, ~)
            new_obj = obj;
        end
        %% This function is used by KIND2 LustreProgram.print()
        function nodesCalled = getNodesCalled(~)
            nodesCalled = {};
        end
        
        
        
        %%
        function code = print(obj, backend)
            %TODO: check if LUSTREC syntax is OK for the other backends.
            code = obj.print_lustrec(backend);
        end
        
        function code = print_lustrec(obj, ~)
            code = sprintf('type %s = enum {%s};\n', ...
                obj.enum_name, MatlabUtils.strjoin(obj.enum_args, ', '));
        end
        
        function code = print_kind2(obj)
            code = obj.print_lustrec(BackendType.KIND2);
        end
        function code = print_zustre(obj)
            code = obj.print_lustrec(BackendType.ZUSTRE);
        end
        function code = print_jkind(obj)
            code = obj.print_lustrec(BackendType.JKIND);
        end
        function code = print_prelude(obj)
            code = obj.print_lustrec(BackendType.PRELUDE);
        end
    end
    
end


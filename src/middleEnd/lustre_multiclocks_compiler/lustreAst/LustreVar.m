classdef LustreVar < LustreAst
    %LustreVar
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        name;%String
        type;%String
    end
    
    methods
        function obj = LustreVar(name, type)
            if isa(name, 'VarIdExpr')
                obj.name = name.getId();
            else
                obj.name = name;
            end
            obj.type = type;
        end
        
        function new_obj = deepCopy(obj)
            new_obj = LustreVar(obj.name, obj.type);
        end
        
        %% This functions are used for ForIterator block
        function [new_obj, varIds] = changePre2Var(obj)
            new_obj = obj;
            varIds = {};
        end
        
        function new_obj = changeArrowExp(obj, ~)
            new_obj = obj;
        end
        %% This function is used by Stateflow function SF_To_LustreNode.getPseudoLusAction
        function varIds = GetVarIds(obj)
            varIds = {obj.name};
        end
        %%
        function id = getId(obj)
            id = obj.name;
        end
        function dt = getDT(obj)
            dt = obj.type;
        end
        function code = print(obj, backend)
            %TODO: check if LUSTREC syntax is OK for the other backends.
            code = obj.print_lustrec(backend);
        end
        
        function code = print_lustrec(obj, backend)
            if BackendType.isKIND2(backend) ...
                    && isequal(obj.type, 'bool clock')
                dt = 'bool';
            else
                dt = obj.type;
            end
            
            code = sprintf('%s : %s;', obj.name, dt);
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
    methods(Static)
        function U = uniqueVars(vars)
            Ids = cellfun(@(x) x.getId(), ...
                vars, 'UniformOutput', false);
            [~, I] = unique(Ids);
            U = vars(I);
        end
        function U = removeVar(vars, v)
            Ids = cellfun(@(x) x.getId(), ...
                vars, 'UniformOutput', false);
            U = vars(~strcmp(Ids, v));
        end
    end
end


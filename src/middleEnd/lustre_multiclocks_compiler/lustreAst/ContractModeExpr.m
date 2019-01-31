classdef ContractModeExpr < LustreExpr
    %ContractGuaranteeExpr
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        name; %String
        requires; %LustreExp[]
        ensures; %LustreExp[]
    end
    
    methods
        function obj = ContractModeExpr(name, requires, ensures)
            obj.name = name;
            if ~iscell(requires)
                obj.requires{1} = requires;
            else
                obj.requires = requires;
            end
            if ~iscell(ensures)
                obj.ensures{1} = ensures;
            else
                obj.ensures = ensures;
            end
        end
        
        function new_obj = deepCopy(obj)
            new_requires = cellfun(@(x) x.deepCopy(), obj.requires, ...
                'UniformOutput', 0);
            new_ensures = cellfun(@(x) x.deepCopy(), obj.ensures, ...
                'UniformOutput', 0);
            new_obj = ContractModeExpr(obj.name, new_requires, new_ensures);
        end
        %% simplify expression
        function new_obj = simplify(obj)
            new_requires = cellfun(@(x) x.simplify(), obj.requires, ...
                'UniformOutput', 0);
            new_ensures = cellfun(@(x) x.simplify(), obj.ensures, ...
                'UniformOutput', 0);
            new_obj = ContractModeExpr(obj.name, new_requires, new_ensures);
        end
        
        %% nbOccurance
        function nb_occ = nbOccuranceVar(obj, var)
            occ_requires = cellfun(@(x) x.nbOccuranceVar(var), obj.requires, ...
                'UniformOutput', true);
            occ_ensures = cellfun(@(x) x.nbOccuranceVar(var), obj.ensures, ...
                'UniformOutput', true);
            nb_occ = sum(occ_requires) + sum(occ_ensures);
        end
        %% substituteVars 
        function new_obj = substituteVars(obj, oldVar, newVar)
            new_requires = cellfun(@(x) x.substituteVars(oldVar, newVar), obj.requires, ...
                'UniformOutput', 0);
            new_ensures = cellfun(@(x) x.substituteVars(oldVar, newVar), obj.ensures, ...
                'UniformOutput', 0);
            new_obj = ContractModeExpr(obj.name, new_requires, new_ensures);
        end
        %% This functions are used for ForIterator block
        function [new_obj, varIds] = changePre2Var(obj)
            new_obj = obj;
            varIds = {};
        end
        function new_obj = changeArrowExp(obj, ~)
            new_obj = obj;
        end
        
        %% This function is used by KIND2 LustreProgram.print()
        function nodesCalled = getNodesCalled(obj)
            nodesCalled = {};
            function addNodes(objects)
                for i=1:numel(objects)
                    nodesCalled = [nodesCalled, objects{i}.getNodesCalled()];
                end
            end
            addNodes(obj.requires);
            addNodes(obj.ensures);
        end
        
        %% This function is used in Stateflow compiler to change from imperative
        % code to Lustre
        function [new_obj, outputs_map] = pseudoCode2Lustre(obj, outputs_map, isLeft)
            new_requires = cellfun(@(x) x.pseudoCode2Lustre(outputs_map, false),...
                obj.requires, ...
                'UniformOutput', 0);
            new_ensures = cellfun(@(x) x.pseudoCode2Lustre(outputs_map, false),...
                obj.ensures, ...
                'UniformOutput', 0);
            new_obj = ContractModeExpr(obj.name, new_requires, new_ensures);
        end
        
        
        %%
        function code = print(obj, backend)
            if LusBackendType.isKIND2(backend)
                code = obj.print_kind2(backend);
            else
                code = '';
            end
        end
        
        function code = print_lustrec(obj)
            code = '';
        end
        function code = print_kind2(obj, backend)
            require = {};
            for j=1:numel(obj.requires)
                require{j} = sprintf('\t\trequire %s;\n', ...
                    obj.requires{j}.print(backend));
            end
            require = MatlabUtils.strjoin(require, '');
            
            ensure = {};
            for j=1:numel(obj.ensures)
                ensure{j} = sprintf('\t\tensure %s;\n', ...
                    obj.ensures{j}.print(backend));
            end
            ensure = MatlabUtils.strjoin(ensure, '');
            code = sprintf('\tmode %s(\n%s%s\t);\n', obj.name, require, ensure);
        end
        function code = print_zustre(obj)
            code = obj.print_lustrec();
        end
        function code = print_jkind(obj)
            code = obj.print_lustrec();
        end
        function code = print_prelude(obj)
            code = obj.print_lustrec();
        end
    end
    
end


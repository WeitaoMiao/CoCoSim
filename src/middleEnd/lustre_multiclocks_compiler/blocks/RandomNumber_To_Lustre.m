classdef RandomNumber_To_Lustre < Block_To_Lustre
    %RandomNumber_To_Lustre translates the RandomNumber block to a set of
    %random number generated by Matlab
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
    end
    
    methods
        
        function  write_code(obj, parent, blk, xml_trace, lus_backend, varargin)
            [outputs, outputs_dt] = SLX2LusUtils.getBlockOutputsNames(parent, blk, [], xml_trace);
            obj.addVariable(outputs_dt);
            [mean, ~, status] = ...
                Constant_To_Lustre.getValueFromParameter(parent, blk, blk.Mean);
            if status
                display_msg(sprintf('Variable %s in block %s not found neither in Matlab workspace or in Model workspace',...
                    blk.Mean, HtmlItem.addOpenCmd(blk.Origin_path)), ...
                    MsgType.ERROR, 'Constant_To_Lustre', '');
                return;
            end
            [variance, ~, status] = ...
                Constant_To_Lustre.getValueFromParameter(parent, blk, blk.Variance);
            if status
                display_msg(sprintf('Variable %s in block %s not found neither in Matlab workspace or in Model workspace',...
                    blk.Variance, HtmlItem.addOpenCmd(blk.Origin_path)), ...
                    MsgType.ERROR, 'Constant_To_Lustre', '');
                return;
            end
            a = mean - 2.57*sqrt(variance);
            b = mean + 2.57*sqrt(variance);
            nbSteps = 100;
            r = a + (b-a).*rand(nbSteps,1);
            blk_name = SLX2LusUtils.node_name_format(blk);
            obj.addExtenal_node(RandomNumber_To_Lustre.randomNode(blk_name, r, lus_backend));
            
            codes = {};
            if LusBackendType.isKIND2(lus_backend)
                codes{1} = LustreEq(outputs{1}, ...
                    NodeCallExpr(blk_name, BooleanExpr('true')));
            else
                clk_var = VarIdExpr(sprintf('%s_clock', blk_name));
                obj.addVariable(LustreVar(clk_var, 'bool clock'));
                obj.addExternal_libraries('_make_clock');
                codes{1} = LustreEq(clk_var, ...
                    NodeCallExpr('_make_clock',...
                    {IntExpr(nbSteps), IntExpr(0)}));
                % generating 100 random random that will be repeated each 100
                % steps
                codes{2} = LustreEq(outputs{1}, ...
                    EveryExpr(blk_name, BooleanExpr('true'), clk_var));
            end
            
            obj.setCode( codes );
        end
        
        function options = getUnsupportedOptions(obj, parent, blk, varargin)
            [~, ~, status] = ...
                Constant_To_Lustre.getValueFromParameter(parent, blk, blk.Mean);
            if status
                obj.addUnsupported_options(sprintf('Variable %s in block %s not found neither in Matlab workspace or in Model workspace',...
                    blk.Mean, HtmlItem.addOpenCmd(blk.Origin_path)));
            end
            [~, ~, status] = ...
                Constant_To_Lustre.getValueFromParameter(parent, blk, blk.Variance);
            if status
                obj.addUnsupported_options(sprintf('Variable %s in block %s not found neither in Matlab workspace or in Model workspace',...
                    blk.Variance, HtmlItem.addOpenCmd(blk.Origin_path)));
            end
            options = obj.unsupported_options;
        end
        %%
        function is_Abstracted = isAbstracted(~, lus_backend, varargin)
            is_Abstracted = LusBackendType.isKIND2(lus_backend);
        end
    end
    methods(Static)
        function node = randomNode(blk_name, r, lus_backend)
            node = LustreNode();
            node.setName(blk_name);
            node.setInputs(LustreVar('b', 'bool'));
            node.setOutputs(LustreVar('r', 'real'));
            if LusBackendType.isKIND2(lus_backend)
                contractElts{1} = ContractGuaranteeExpr('', ...
                    BinaryExpr(BinaryExpr.AND, ...
                    BinaryExpr(BinaryExpr.LTE, RealExpr(min(r)), VarIdExpr('r')), ...
                    BinaryExpr(BinaryExpr.LTE, VarIdExpr('r'), RealExpr(max(r)))));
                contract = LustreContract();
                contract.setBody(contractElts);
                node.setLocalContract(contract);
                node.setIsImported(true);
            else
                node.setBodyEqs(LustreEq(VarIdExpr('r'), ...
                    RandomNumber_To_Lustre.getRandomValues(r, 1)));
            end
            
            
            
        end
        function r_str = getRandomValues(r, i)
            if i == numel(r)
                r_str = RealExpr(r(i));
            else
                r_str =BinaryExpr(BinaryExpr.ARROW, ...
                    RealExpr(r(i)), ...
                    UnaryExpr(UnaryExpr.PRE,...
                    RandomNumber_To_Lustre.getRandomValues(r, i+1)));
                
            end
        end
    end
end


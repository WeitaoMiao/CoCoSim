classdef LustMathLib
    %LustMathLib This class  is a set of Lustre math libraries.
    
    properties
    end
    
    methods(Static)
        
        function [node, external_nodes_i, opens, abstractedNodes] = template(varargin)
            opens = {};
            abstractedNodes = {};
            external_nodes_i = {};
            node = '';
        end
        
        %% Min Max
        function [node, external_nodes_i, opens, abstractedNodes] = getMinMax(minOrMAx, dt)
            opens = {};
            abstractedNodes = {};
            external_nodes_i = {};
            node_name = strcat('_', minOrMAx, '_', dt);
            if strcmp(minOrMAx, 'min')
                op = BinaryExpr.LT;
            else
                op = BinaryExpr.GT;
            end
            %node_format = 'node %s (x, y: %s)\nreturns(z:%s);\nlet\n\t z = if (x %s y) then x else y;\ntel\n\n';
            %node  = sprintf(node_format, node_name, dt, dt, op);
            bodyElts = LustreEq(...
                VarIdExpr('z'), ...
                IteExpr(...
                    BinaryExpr(op, VarIdExpr('x'), VarIdExpr('y')), ...
                    VarIdExpr('x'), ...
                    VarIdExpr('y'))...
                );
            node = LustreNode();
            node.setName(node_name);
            node.setInputs({LustreVar('x', dt), LustreVar('y', dt)});
            node.setOutputs(LustreVar('z', dt));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__min_int(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getMinMax('min', 'int');
        end
        
        function [node, external_nodes_i, opens, abstractedNodes] = get__min_real(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getMinMax('min', 'real');
        end
        
        function [node, external_nodes_i, opens, abstractedNodes] = get__max_int(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getMinMax('max', 'int');
        end
        
        function [node, external_nodes_i, opens, abstractedNodes] = get__max_real(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getMinMax('max', 'real');
        end
        
        %%
        function [node, external_nodes_i, opens, abstractedNodes] = get_lustrec_math(varargin)
            opens = {'lustrec_math'};
            abstractedNodes = {'lustrec_math library'};
            external_nodes_i = {};
            node = '';
        end
        
        function [node, external_nodes_i, opens, abstractedNodes] = get_simulink_math_fcn(varargin)
            opens = {'simulink_math_fcn'};
            abstractedNodes = {'simulink_math_fcn library'};
            external_nodes_i = {};
            node = '';
        end
        
        %% fabs, abs
        function [node, external_nodes_i, opens, abstractedNodes] = get__fabs(varargin)
            opens = {};
            abstractedNodes = {};
            external_nodes_i = {};
            
            bodyElts{1} = LustreEq(...
                VarIdExpr('z'), ...
                IteExpr(...
                    BinaryExpr(BinaryExpr.GTE, VarIdExpr('x'), RealExpr('0.0')), ...
                    VarIdExpr('x'), ...
                    UnaryExpr(UnaryExpr.NEG, VarIdExpr('x')))...
                );
            node = LustreNode();
            node.setName('_fabs');
            node.setInputs(LustreVar('x', 'real'));
            node.setOutputs(LustreVar('z', 'real'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        
        function [node, external_nodes_i, opens, abstractedNodes] = get_abs_int(varargin)
            opens = {};
            abstractedNodes = {};
            external_nodes_i = {};
            bodyElts{1} = LustreEq(...
                VarIdExpr('y'), ...
                IteExpr(...
                    BinaryExpr(BinaryExpr.GTE, VarIdExpr('x'), IntExpr('0')), ...
                    VarIdExpr('x'), ...
                    UnaryExpr(UnaryExpr.NEG, VarIdExpr('x')))...
                );
            node = LustreNode();
            node.setName('abs_int');
            node.setInputs(LustreVar('x', 'int'));
            node.setOutputs(LustreVar('y', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        
        function [node, external_nodes_i, opens, abstractedNodes] = get_abs_real(varargin)
            opens = {};
            abstractedNodes = {};
            external_nodes_i = {};
            bodyElts{1} = LustreEq(...
                VarIdExpr('y'), ...
                IteExpr(...
                    BinaryExpr(BinaryExpr.GTE, VarIdExpr('x'), RealExpr('0.0')), ...
                    VarIdExpr('x'), ...
                    UnaryExpr(UnaryExpr.NEG, VarIdExpr('x')))...
                );
            node = LustreNode();
            node.setName('abs_real');
            node.setInputs(LustreVar('x', 'real'));
            node.setOutputs(LustreVar('y', 'real'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        
        %% sign
        function [node, external_nodes_i, opens, abstractedNodes] = get_sign_int(varargin)
            opens = {};
            abstractedNodes = {};
            external_nodes_i = {};
            bodyElts{1} = LustreEq(...
                VarIdExpr('y'), ...
                IteExpr.nestedIteExpr(...
                {BinaryExpr(BinaryExpr.GT, VarIdExpr('x'), IntExpr('0')), ...
                BinaryExpr(BinaryExpr.LT, VarIdExpr('x'), IntExpr('0'))}, ...
                {IntExpr('1'), IntExpr('-1'), IntExpr('0')})...
                );
            node = LustreNode();
            node.setName('sign_int');
            node.setInputs(LustreVar('x', 'int'));
            node.setOutputs(LustreVar('y', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        
        function [node, external_nodes_i, opens, abstractedNodes] = get_sign_real(varargin)
            opens = {};
            abstractedNodes = {};
            external_nodes_i = {};
            bodyElts{1} = LustreEq(...
                VarIdExpr('y'), ...
                IteExpr.nestedIteExpr(...
                {BinaryExpr(BinaryExpr.GT, VarIdExpr('x'), RealExpr('0.0')), ...
                BinaryExpr(BinaryExpr.LT, VarIdExpr('x'), RealExpr('0.0'))}, ...
                {RealExpr('1.0'), RealExpr('-1.0'), RealExpr('0.0')})...
                );
            node = LustreNode();
            node.setName('sign_real');
            node.setInputs(LustreVar('x', 'real'));
            node.setOutputs(LustreVar('y', 'real'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        %% Bitwise operators
        function [node, external_nodes, opens, abstractedNodes] = getBitwiseSigned(op, n)
            opens = {};
            abstractedNodes = {};
            extNode = sprintf('int_to_int%d',n);
            UnsignedNode =  sprintf('_%s_Bitwise_Unsigned_%d',op, n);
            external_nodes = {strcat('LustDTLib_', extNode),...
                strcat('LustMathLib_', UnsignedNode)};
            
            node_name = sprintf('_%s_Bitwise_Signed_%d', op, n);
            v2_pown = 2^(n);
%             format = 'node %s (x, y: int)\nreturns(z:int);\nvar x2, y2:int;\nlet\n\t';
%             format = [format, 'x2 = if x < 0 then %d + x else x;\n\t'];
%             format = [format, 'y2 = if y < 0 then %d + y else y;\n\t'];
%             format = [format, 'z = %s(%s(x2, y2));\ntel\n\n'];
%             node = sprintf(format, node_name, v2_pown, v2_pown, extNode, UnsignedNode);
            bodyElts{1} = LustreEq(...
                VarIdExpr('x2'), ...
                IteExpr(...
                    BinaryExpr(BinaryExpr.LT, VarIdExpr('x'), IntExpr('0')), ...
                    BinaryExpr(BinaryExpr.PLUS, IntExpr(v2_pown),VarIdExpr('x')), ...
                    VarIdExpr('x'))...
                );
            bodyElts{end + 1} = LustreEq(...
                VarIdExpr('y2'), ...
                IteExpr(...
                    BinaryExpr(BinaryExpr.LT, VarIdExpr('y'), IntExpr('0')), ...
                    BinaryExpr(BinaryExpr.PLUS, IntExpr(v2_pown),VarIdExpr('y')), ...
                    VarIdExpr('y'))...
                );
            bodyElts{end + 1} = LustreEq(...
                VarIdExpr('z'), ...
                NodeCallExpr(extNode, ...
                            NodeCallExpr(UnsignedNode, ...
                                   {VarIdExpr('x2'), VarIdExpr('y2')}))...
                );
            node = LustreNode();
            node.setName(node_name);
            node.setInputs({LustreVar('x', 'int'), LustreVar('y', 'int')});
            node.setOutputs(LustreVar('z', 'int'));
            node.setLocalVars({LustreVar('x2', 'int'), LustreVar('y2', 'int')})
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        
        %AND
        function [node, external_nodes, opens, abstractedNodes] = getANDBitwiseUnsigned(n)
            opens = {};
            abstractedNodes = {};
            external_nodes = {};
            
            args = cell(1, n);
            %code{1} = sprintf('(x mod 2)*(y mod 2)');
            args{1} = BinaryExpr(...
                BinaryExpr.MULTIPLY, ...
                BinaryExpr(BinaryExpr.MOD, VarIdExpr('x'), IntExpr(2)), ...
                BinaryExpr(BinaryExpr.MOD, VarIdExpr('y'), IntExpr(2)));
            for i=1:n-1
                v2_pown = 2^i;
                %code{end+1} = sprintf('%d*((x / %d) mod 2)*((y / %d) mod 2)', v2_pown, v2_pown, v2_pown);
                %((x / %d) mod 2)
                x_term = BinaryExpr(...
                    BinaryExpr.MOD, ...
                    BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('x'), IntExpr(v2_pown)),...
                    IntExpr(2));
                %((y / %d) mod 2)
                y_term = BinaryExpr(...
                    BinaryExpr.MOD, ...
                    BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('y'), IntExpr(v2_pown)),...
                    IntExpr(2));
                args{i + 1} = BinaryExpr.BinaryMultiArgs(...
                    BinaryExpr.MULTIPLY, ...
                    {IntExpr(v2_pown), x_term, y_term});
            end
            %code = MatlabUtils.strjoin(code, ' \n\t+ ');
            rhs = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS, args);
            node_name = strcat('_AND_Bitwise_Unsigned_', num2str(n));
            
            %             format = 'node %s (x, y: int)\nreturns(z:int);\nlet\n\t';
            %             format = [format, 'z = %s;\ntel\n\n'];
            %             node = sprintf(format, node_name, code);
            bodyElts = LustreEq(...
                VarIdExpr('z'), ...
                rhs);
            node = LustreNode();
            node.setName(node_name);
            node.setInputs({LustreVar('x', 'int'), LustreVar('y', 'int')});
            node.setOutputs(LustreVar('z', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end 
        %NAND
        function [node, external_nodes, opens, abstractedNodes] = getNANDBitwiseUnsigned(n)
            opens = {};
            abstractedNodes = {};
            notNode = sprintf('_NOT_Bitwise_Unsigned_%d', n);
            UnsignedNode =  sprintf('_AND_Bitwise_Unsigned_%d', n);
            external_nodes = {strcat('LustMathLib_', notNode),...
                strcat('LustMathLib_', UnsignedNode)};
            
            node_name = sprintf('_NAND_Bitwise_Unsigned_%d', n);
            %             format = 'node %s (x, y: int)\nreturns(z:int);\nlet\n\t';
            %             format = [format, 'z = %s(%s(x, y));\ntel\n\n'];
            %             node = sprintf(format, node_name, notNode, UnsignedNode);
            bodyElts{1} = LustreEq(...
                VarIdExpr('z'), ...
                NodeCallExpr(notNode, ...
                            NodeCallExpr(UnsignedNode, ...
                                   {VarIdExpr('x'), VarIdExpr('y')}))...
                );
            node = LustreNode();
            node.setName(node_name);
            node.setInputs({LustreVar('x', 'int'), LustreVar('y', 'int')});
            node.setOutputs(LustreVar('z', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        %NOR
        function [node, external_nodes, opens, abstractedNodes] = getNORBitwiseUnsigned(n)
            opens = {};
            abstractedNodes = {};
            notNode = sprintf('_NOT_Bitwise_Unsigned_%d', n);
            UnsignedNode =  sprintf('_OR_Bitwise_Unsigned_%d', n);
            external_nodes = {strcat('LustMathLib_', notNode),...
                strcat('LustMathLib_', UnsignedNode)};
            
            node_name = sprintf('_NOR_Bitwise_Unsigned_%d', n);
            %             format = 'node %s (x, y: int)\nreturns(z:int);\nlet\n\t';
            %             format = [format, 'z = %s(%s(x, y));\ntel\n\n'];
            %             node = sprintf(format, node_name, notNode, UnsignedNode);
            bodyElts{1} = LustreEq(...
                VarIdExpr('z'), ...
                NodeCallExpr(notNode, ...
                            NodeCallExpr(UnsignedNode, ...
                                   {VarIdExpr('x'), VarIdExpr('y')}))...
                );
            node = LustreNode();
            node.setName(node_name);
            node.setInputs({LustreVar('x', 'int'), LustreVar('y', 'int')});
            node.setOutputs(LustreVar('z', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        %OR
        function [node, external_nodes, opens, abstractedNodes] = getORBitwiseUnsigned(n)
            opens = {};
            abstractedNodes = {};
            external_nodes = {};
            
            %code = {};
            %code{1} = sprintf('( ((x mod 2) + (y mod 2) + (x mod 2)*(y mod 2))  mod 2)');
            args = cell(1, n);
            args{1} =   ...
                BinaryExpr(BinaryExpr.MOD,...
                   BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS, ...
                    {BinaryExpr(BinaryExpr.MOD, VarIdExpr('x'), IntExpr(2)), ...
                     BinaryExpr(BinaryExpr.MOD, VarIdExpr('y'), IntExpr(2)), ...
                     BinaryExpr(...
                        BinaryExpr.MULTIPLY, ...
                        BinaryExpr(BinaryExpr.MOD, VarIdExpr('x'), IntExpr(2)), ...
                        BinaryExpr(BinaryExpr.MOD, VarIdExpr('y'), IntExpr(2)))...
                        }),...
                   IntExpr(2));
            for i=1:n-1
                v2_pown = 2^i;
                %code{end+1} = sprintf('%d*(((((x / %d) mod 2) + ((y / %d) mod 2) + ((x / %d) mod 2)*((y / %d) mod 2))) mod 2)',...
                %    v2_pown, v2_pown, v2_pown, v2_pown, v2_pown);
                x_term = BinaryExpr(...
                    BinaryExpr.DIVIDE, VarIdExpr('x'), IntExpr(v2_pown));
                y_term = BinaryExpr(...
                    BinaryExpr.DIVIDE, VarIdExpr('y'), IntExpr(v2_pown));
                args{i + 1} =   ...
                    BinaryExpr(...
                        BinaryExpr.MULTIPLY, ...
                        IntExpr(v2_pown), ...
                        BinaryExpr(BinaryExpr.MOD,...
                            BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS, ...
                                {BinaryExpr(BinaryExpr.MOD, x_term, IntExpr(2)), ...
                                 BinaryExpr(BinaryExpr.MOD, y_term, IntExpr(2)), ...
                                 BinaryExpr(...
                                    BinaryExpr.MULTIPLY, ...
                                    BinaryExpr(BinaryExpr.MOD, x_term, IntExpr(2)), ...
                                    BinaryExpr(BinaryExpr.MOD, y_term, IntExpr(2)))...
                                    }),...
                             IntExpr(2))...
                            );
            end
            %code = MatlabUtils.strjoin(code, ' \n\t+ ');
            rhs = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS, args);
            node_name = strcat('_OR_Bitwise_Unsigned_', num2str(n));
            
            %             format = 'node %s (x, y: int)\nreturns(z:int);\nlet\n\t';
            %             format = [format, 'z = %s;\ntel\n\n'];
            %             node = sprintf(format, node_name, code);
            bodyElts{1} = LustreEq(VarIdExpr('z'), rhs);
            node = LustreNode();
            node.setName(node_name);
            node.setInputs({LustreVar('x', 'int'), LustreVar('y', 'int')});
            node.setOutputs(LustreVar('z', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        %XOR
        function [node, external_nodes, opens, abstractedNodes] = getXORBitwiseUnsigned(n)
            opens = {};
            abstractedNodes = {};
            external_nodes = {};
            
            %code = {};
            %code{1} = sprintf('((x + y) mod 2)');
            args = cell(1, n);
            args{1} =   ...
                BinaryExpr(BinaryExpr.MOD,...
                   BinaryExpr(...
                        BinaryExpr.PLUS, ...
                        VarIdExpr('x'), ...
                        VarIdExpr('y')...
                   ),...
                   IntExpr(2));
            for i=1:n-1
                v2_pown = 2^i;
                %code{end+1} = sprintf('%d*(((x / %d) + (y / %d)) mod 2)', v2_pown, v2_pown, v2_pown);
                x_term = BinaryExpr(...
                    BinaryExpr.DIVIDE, VarIdExpr('x'), IntExpr(v2_pown));
                y_term = BinaryExpr(...
                    BinaryExpr.DIVIDE, VarIdExpr('y'), IntExpr(v2_pown));
                args{i + 1} =   ...
                    BinaryExpr(...
                        BinaryExpr.MULTIPLY, ...
                        IntExpr(v2_pown), ...
                        BinaryExpr(BinaryExpr.MOD,...
                             BinaryExpr(BinaryExpr.PLUS, x_term, y_term),...
                             IntExpr(2))...
                    );
            end
            %code = MatlabUtils.strjoin(code, ' \n\t+ ');
            rhs = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS, args);
            node_name = strcat('_XOR_Bitwise_Unsigned_', num2str(n));
            
            % format = 'node %s (x, y: int)\nreturns(z:int);\nlet\n\t';
            % format = [format, 'z = %s;\ntel\n\n'];
            % node = sprintf(format, node_name, code);
            bodyElts{1} = LustreEq(VarIdExpr('z'), rhs);
            node = LustreNode();
            node.setName(node_name);
            node.setInputs({LustreVar('x', 'int'), LustreVar('y', 'int')});
            node.setOutputs(LustreVar('z', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        
        
        function [node, external_nodes, opens, abstractedNodes] = getNOTBitwiseUnsigned(n)
            opens = {};
            abstractedNodes = {};
            external_nodes = {};
            node_name = strcat('_NOT_Bitwise_Unsigned_', num2str(n));
            v2_pown = 2^n - 1;
            %format = 'node %s (x: int)\nreturns(y:int);\nlet\n\t';
            %format = [format, 'y=  %d - x ;\ntel\n\n'];
            %node = sprintf(format, node_name,v2_pown);
            bodyElts{1} = LustreEq(...
                VarIdExpr('y'), ...
                BinaryExpr(BinaryExpr.MINUS, IntExpr(v2_pown), VarIdExpr('x'))...
                );
            node = LustreNode();
            node.setName(node_name);
            node.setInputs(LustreVar('x', 'int'));
            node.setOutputs(LustreVar('y', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        function [node, external_nodes, opens, abstractedNodes] = getNOTBitwiseSigned()
            opens = {};
            abstractedNodes = {};
            external_nodes = {};
            node_name = strcat('_NOT_Bitwise_Signed');
            %format = 'node %s (x: int)\nreturns(y:int);\nlet\n\t';
            %format = [format, 'y=   - x - 1;\ntel\n\n'];
            %node = sprintf(format, node_name);
            bodyElts{1} = LustreEq(...
                VarIdExpr('y'), ...
                BinaryExpr(BinaryExpr.MINUS, ...
                    UnaryExpr(UnaryExpr.NEG ,VarIdExpr('x')),...
                    IntExpr(1) )...
                );
            node = LustreNode();
            node.setName(node_name);
            node.setInputs(LustreVar('x', 'int'));
            node.setOutputs(LustreVar('y', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        
        %AND
        function [node, external_nodes_i, opens, abstractedNodes] = get__AND_Bitwise_Unsigned_8(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getANDBitwiseUnsigned(8);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__AND_Bitwise_Unsigned_16(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getANDBitwiseUnsigned(16);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__AND_Bitwise_Unsigned_32(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getANDBitwiseUnsigned(32);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__AND_Bitwise_Signed_8(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('AND', 8);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__AND_Bitwise_Signed_16(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('AND', 16);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__AND_Bitwise_Signed_32(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('AND', 32);
        end
        %NAND
        function [node, external_nodes_i, opens, abstractedNodes] = get__NAND_Bitwise_Unsigned_8(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getNANDBitwiseUnsigned(8);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__NAND_Bitwise_Unsigned_16(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getNANDBitwiseUnsigned(16);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__NAND_Bitwise_Unsigned_32(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getNANDBitwiseUnsigned(32);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__NAND_Bitwise_Signed_8(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('NAND', 8);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__NAND_Bitwise_Signed_16(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('NAND', 16);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__NAND_Bitwise_Signed_32(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('NAND', 32);
        end
       
        %OR
        function [node, external_nodes_i, opens, abstractedNodes] = get__OR_Bitwise_Unsigned_8(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getORBitwiseUnsigned(8);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__OR_Bitwise_Unsigned_16(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getORBitwiseUnsigned(16);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__OR_Bitwise_Unsigned_32(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getORBitwiseUnsigned(32);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__OR_Bitwise_Signed_8(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('OR', 8);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__OR_Bitwise_Signed_16(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('OR', 16);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__OR_Bitwise_Signed_32(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('OR', 32);
        end
        %NOR
        function [node, external_nodes_i, opens, abstractedNodes] = get__NOR_Bitwise_Unsigned_8(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getNORBitwiseUnsigned(8);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__NOR_Bitwise_Unsigned_16(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getNORBitwiseUnsigned(16);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__NOR_Bitwise_Unsigned_32(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getNORBitwiseUnsigned(32);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__NOR_Bitwise_Signed_8(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('NOR', 8);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__NOR_Bitwise_Signed_16(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('NOR', 16);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__NOR_Bitwise_Signed_32(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('NOR', 32);
        end
       
        %XOR
        function [node, external_nodes_i, opens, abstractedNodes] = get__XOR_Bitwise_Unsigned_8(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getXORBitwiseUnsigned(8);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__XOR_Bitwise_Unsigned_16(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getXORBitwiseUnsigned(16);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__XOR_Bitwise_Unsigned_32(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getXORBitwiseUnsigned(32);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__XOR_Bitwise_Signed_8(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('XOR', 8);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__XOR_Bitwise_Signed_16(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('XOR', 16);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__XOR_Bitwise_Signed_32(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getBitwiseSigned('XOR', 32);
        end
        
        %NOT
        function [node, external_nodes_i, opens, abstractedNodes] = get__NOT_Bitwise_Signed(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getNOTBitwiseSigned();
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__NOT_Bitwise_Unsigned_8(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getNOTBitwiseUnsigned(8);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__NOT_Bitwise_Unsigned_16(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getNOTBitwiseUnsigned(16);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get__NOT_Bitwise_Unsigned_32(varargin)
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.getNOTBitwiseUnsigned(32);
        end
        %% Integer division
        
        % The following functions assume "/" and "mod" in Lustre as in
        % euclidean division for integers.
        
        function [node, external_nodes_i, opens, abstractedNodes] = get_int_div_Ceiling(varargin)
            opens = {};
            abstractedNodes = {};
            external_nodes_i = {strcat('LustMathLib_', 'abs_int')};
            %             format = '--Rounds positive and negative numbers toward positive infinity\n ';
            %             format = [format,  'node int_div_Ceiling (x, y: int)\nreturns(z:int);\nlet\n\t'];
            %             format = [format, 'z= if y = 0 then (if x>0 then 2147483647 else -2147483648)\n\t'];
            %             format = [format, 'else if x mod y = 0 then x/y\n\t'];
            %             format = [format, 'else if (abs_int(y) > abs_int(x) and x*y>0) then 1 \n\t'];
            %             format = [format, 'else if (abs_int(y) > abs_int(x) and x*y<0) then 0 \n\t'];
            %             format = [format, 'else if (x>0 and y < 0) then x/y \n\t'];
            %             format = [format, 'else if (x<0 and y > 0) then (-x)/(-y) \n\t'];
            %             format = [format, 'else if (x<0 and y < 0) then (-x)/(-y) + 1 \n\t'];
            %             format = [format, 'else x/y + 1;\ntel\n\n'];
            %             node = sprintf(format);
            
            %y = 0
            conds{1} = BinaryExpr(BinaryExpr.EQ, VarIdExpr('y'), IntExpr(0));
            %if x>0 then 2147483647 else -2147483648
            thens{1} = IteExpr(...
                BinaryExpr(BinaryExpr.GT, VarIdExpr('x'), IntExpr(0)),...
                IntExpr(2147483647), IntExpr(-2147483648),...
                true);
            % x mod y = 0
            conds{2} = BinaryExpr(...
                BinaryExpr.EQ, ...
                BinaryExpr(BinaryExpr.MOD, VarIdExpr('x'), VarIdExpr('y')), ...
                IntExpr(0));
            % x/y
            thens{2} = BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('x'), VarIdExpr('y'));
            %(abs_int(y) > abs_int(x) and x*y>0)
            conds{3} = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr(BinaryExpr.GT, ...
                           NodeCallExpr('abs_int', VarIdExpr('y')),...
                           NodeCallExpr('abs_int', VarIdExpr('x'))), ...
                BinaryExpr(BinaryExpr.GT, ...
                           BinaryExpr(BinaryExpr.MULTIPLY, VarIdExpr('x'), VarIdExpr('y')),...
                           IntExpr(0))...
                );
            % 1
            thens{3} = IntExpr(1);
            %(abs_int(y) > abs_int(x) and x*y<0)
            conds{4} = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr(BinaryExpr.GT, ...
                           NodeCallExpr('abs_int', VarIdExpr('y')),...
                           NodeCallExpr('abs_int', VarIdExpr('x'))), ...
                BinaryExpr(BinaryExpr.LT, ...
                           BinaryExpr(BinaryExpr.MULTIPLY, VarIdExpr('x'), VarIdExpr('y')),...
                           IntExpr(0))...
                );
            % 0
            thens{4} = IntExpr(0);
            % (x>0 and y < 0)
            conds{5} = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr(BinaryExpr.GT, ...
                           VarIdExpr('x'),...
                           IntExpr(0)), ...
                BinaryExpr(BinaryExpr.LT, ...
                           VarIdExpr('y'),...
                           IntExpr(0))...
                );
            %x/y
            thens{5} = BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('x'), VarIdExpr('y'));
            % (x<0 and y > 0)
            conds{6} = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr(BinaryExpr.LT, ...
                           VarIdExpr('x'),...
                           IntExpr(0)), ...
                BinaryExpr(BinaryExpr.GT, ...
                           VarIdExpr('y'),...
                           IntExpr(0))...
                );
            %(-x)/(-y)
            thens{6} = BinaryExpr(...
                BinaryExpr.DIVIDE, ...
                UnaryExpr(UnaryExpr.NEG, VarIdExpr('x')), ...
                UnaryExpr(UnaryExpr.NEG, VarIdExpr('y')));
            
            % (x < 0 and y < 0)
            conds{7} = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr(BinaryExpr.LT, ...
                           VarIdExpr('x'),...
                           IntExpr(0)), ...
                BinaryExpr(BinaryExpr.LT, ...
                           VarIdExpr('y'),...
                           IntExpr(0))...
                );
            %(-x)/(-y) + 1
            thens{7} = BinaryExpr(BinaryExpr.PLUS,...
                BinaryExpr(...
                    BinaryExpr.DIVIDE, ...
                    UnaryExpr(UnaryExpr.NEG, VarIdExpr('x')), ...
                    UnaryExpr(UnaryExpr.NEG, VarIdExpr('y'))),...
                IntExpr(1));
            %x/y + 1
            thens{8} = BinaryExpr(BinaryExpr.PLUS,...
                BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('x'), VarIdExpr('y')),...
                IntExpr(1));
            bodyElts{1} = LustreEq(...
                VarIdExpr('z'), ...
                IteExpr.nestedIteExpr(conds, thens)...
                );
            node = LustreNode();
            node.setMetaInfo('Rounds positive and negative numbers toward positive infinity');
            node.setName('int_div_Ceiling');
            node.setInputs({LustreVar('x', 'int'), LustreVar('y', 'int')});
            node.setOutputs(LustreVar('z', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        %Floor: Rounds positive and negative numbers toward negative infinity.
        function [node, external_nodes_i, opens, abstractedNodes] = get_int_div_Floor(varargin)
            opens = {};
            abstractedNodes = {};
            external_nodes_i = {strcat('LustMathLib_', 'abs_int')};
            % format = '--Rounds positive and negative numbers toward negative infinity\n ';
            % format = [format,  'node int_div_Floor (x, y: int)\nreturns(z:int);\nlet\n\t'];
            % format = [format, 'z= if y = 0 then if x>0 then 2147483647 else -2147483648\n\t'];
            % format = [format, 'else if x mod y = 0 then x/y\n\t'];
            % format = [format, 'else if (abs_int(y) > abs_int(x) and x*y>0) then 0 \n\t'];
            % format = [format, 'else if (abs_int(y) > abs_int(x) and x*y<0) then -1 \n\t'];
            % format = [format, 'else if (x>0 and y < 0) then x/y - 1\n\t'];
            % format = [format, 'else if (x<0 and y > 0) then (-x)/(-y) - 1\n\t'];
            % format = [format, 'else if (x<0 and y < 0) then (-x)/(-y)\n\t'];
            % format = [format, 'else x/y;\ntel\n\n'];
            % node = sprintf(format);
             %y = 0
            conds{1} = BinaryExpr(BinaryExpr.EQ, VarIdExpr('y'), IntExpr(0));
            %if x>0 then 2147483647 else -2147483648
            thens{1} = IteExpr(...
                BinaryExpr(BinaryExpr.GT, VarIdExpr('x'), IntExpr(0)),...
                IntExpr(2147483647), IntExpr(-2147483648),...
                true);
            % x mod y = 0
            conds{2} = BinaryExpr(...
                BinaryExpr.EQ, ...
                BinaryExpr(BinaryExpr.MOD, VarIdExpr('x'), VarIdExpr('y')), ...
                IntExpr(0));
            % x/y
            thens{2} = BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('x'), VarIdExpr('y'));
            %(abs_int(y) > abs_int(x) and x*y>0)
            conds{3} = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr(BinaryExpr.GT, ...
                           NodeCallExpr('abs_int', VarIdExpr('y')),...
                           NodeCallExpr('abs_int', VarIdExpr('x'))), ...
                BinaryExpr(BinaryExpr.GT, ...
                           BinaryExpr(BinaryExpr.MULTIPLY, VarIdExpr('x'), VarIdExpr('y')),...
                           IntExpr(0))...
                );
            % 0
            thens{3} = IntExpr(0);
            %(abs_int(y) > abs_int(x) and x*y<0)
            conds{4} = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr(BinaryExpr.GT, ...
                           NodeCallExpr('abs_int', VarIdExpr('y')),...
                           NodeCallExpr('abs_int', VarIdExpr('x'))), ...
                BinaryExpr(BinaryExpr.LT, ...
                           BinaryExpr(BinaryExpr.MULTIPLY, VarIdExpr('x'), VarIdExpr('y')),...
                           IntExpr(0))...
                );
            % -1
            thens{4} = IntExpr(-1);
            % (x>0 and y < 0)
            conds{5} = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr(BinaryExpr.GT, ...
                           VarIdExpr('x'),...
                           IntExpr(0)), ...
                BinaryExpr(BinaryExpr.LT, ...
                           VarIdExpr('y'),...
                           IntExpr(0))...
                );
            %x/y - 1
            thens{5} = BinaryExpr(...
                    BinaryExpr.MINUS, ...
                    BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('x'), VarIdExpr('y')), ...
                    IntExpr(1));
            % (x<0 and y > 0)
            conds{6} = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr(BinaryExpr.LT, ...
                           VarIdExpr('x'),...
                           IntExpr(0)), ...
                BinaryExpr(BinaryExpr.GT, ...
                           VarIdExpr('y'),...
                           IntExpr(0))...
                );
            %(-x)/(-y) - 1
            thens{6} = BinaryExpr(...
                    BinaryExpr.MINUS, ...
                    BinaryExpr(...
                        BinaryExpr.DIVIDE, ...
                        UnaryExpr(UnaryExpr.NEG, VarIdExpr('x')), ...
                        UnaryExpr(UnaryExpr.NEG, VarIdExpr('y'))), ...
                    IntExpr(1));
            
            % (x < 0 and y < 0)
            conds{7} = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr(BinaryExpr.LT, ...
                           VarIdExpr('x'),...
                           IntExpr(0)), ...
                BinaryExpr(BinaryExpr.LT, ...
                           VarIdExpr('y'),...
                           IntExpr(0))...
                );
            %(-x)/(-y) 
            thens{7} = BinaryExpr(...
                    BinaryExpr.DIVIDE, ...
                    UnaryExpr(UnaryExpr.NEG, VarIdExpr('x')), ...
                    UnaryExpr(UnaryExpr.NEG, VarIdExpr('y')));
            %x/y
            thens{8} = BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('x'), VarIdExpr('y'));
            bodyElts{1} = LustreEq(...
                VarIdExpr('z'), ...
                IteExpr.nestedIteExpr(conds, thens)...
                );
            node = LustreNode();
            node.setMetaInfo('Rounds positive and negative numbers toward negative infinity');
            node.setName('int_div_Floor');
            node.setInputs({LustreVar('x', 'int'), LustreVar('y', 'int')});
            node.setOutputs(LustreVar('z', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get_int_div_Nearest(varargin)
            opens = {};
            abstractedNodes = {};
            external_nodes_i = {'LustMathLib_int_div_Ceiling'};
            % format = '--Rounds number to the nearest representable value. If a tie occurs, rounds toward positive infinity\n ';
            % format = [format,  'node int_div_Nearest (x, y: int)\nreturns(z:int);\nlet\n\t'];
            % format = [format, 'z= if y = 0 then if x>0 then 2147483647 else -2147483648\n\t'];
            % format = [format, 'else if x mod y = 0 then x/y\n\t'];
            %                    else if (((x mod y) * 2) = y) then
            %                       int_div_Ceiling(x,y)
            % format = [format, 'else if (y > 0) and ((x mod y)*2 >= y ) then x/y+1 \n\t'];
            % format = [format, 'else if (y < 0) and ((x mod y)*2 >= (-y))  then x/y-1 \n\t'];
            % format = [format, 'else x/y;\ntel\n\n'];
            % node = sprintf(format);
            conds = {};
            thens = {};
            %y = 0
            conds{1} = BinaryExpr(BinaryExpr.EQ, VarIdExpr('y'), IntExpr(0));
            %if x>0 then 2147483647 else -2147483648
            thens{1} = IteExpr(...
                BinaryExpr(BinaryExpr.GT, VarIdExpr('x'), IntExpr(0)),...
                IntExpr(2147483647), IntExpr(-2147483648),...
                true);
            % x mod y = 0
            conds{end + 1} = BinaryExpr(...
                BinaryExpr.EQ, ...
                BinaryExpr(BinaryExpr.MOD, VarIdExpr('x'), VarIdExpr('y')), ...
                IntExpr(0));
            % x/y
            thens{end + 1} = BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('x'), VarIdExpr('y'));
            %(((x mod y) * 2) = y)
            conds{end + 1} = BinaryExpr(BinaryExpr.EQ, ...
                           BinaryExpr(BinaryExpr.MULTIPLY, ...
                                      BinaryExpr(BinaryExpr.MOD, ...
                                                 VarIdExpr('x'), ...
                                                 VarIdExpr('y')),...
                                      IntExpr(2)),...
                           VarIdExpr('y'));
            %int_div_Ceiling(x,y)
            thens{end + 1} = NodeCallExpr('int_div_Ceiling',...
                {VarIdExpr('x'), VarIdExpr('y')});
            %(y > 0) and ((x mod y)*2 >= y )
            conds{end + 1} = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr(BinaryExpr.GT, ...
                           VarIdExpr('y'),...
                           IntExpr(0)), ...
                BinaryExpr(BinaryExpr.GT, ...
                           BinaryExpr(BinaryExpr.MULTIPLY, ...
                                      BinaryExpr(BinaryExpr.MOD, ...
                                                 VarIdExpr('x'), ...
                                                 VarIdExpr('y')),...
                                      IntExpr(2)),...
                           VarIdExpr('y'))...
                );
            % x/y + 1
            thens{end + 1} = BinaryExpr(...
                    BinaryExpr.PLUS, ...
                    BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('x'), VarIdExpr('y')), ...
                    IntExpr(1));
            %(y < 0) and ((x mod y)*2 >= (-y))
            conds{end + 1} = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr(BinaryExpr.LT, ...
                           VarIdExpr('y'),...
                           IntExpr(0)), ...
                BinaryExpr(BinaryExpr.GT, ...
                           BinaryExpr(BinaryExpr.MULTIPLY, ...
                                      BinaryExpr(BinaryExpr.MOD, ...
                                                 VarIdExpr('x'), ...
                                                 VarIdExpr('y')),...
                                      IntExpr(2)),...
                           UnaryExpr(UnaryExpr.NEG,VarIdExpr('y')))...
                );
            % x/y - 1
            thens{end + 1} = BinaryExpr(...
                    BinaryExpr.MINUS, ...
                    BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('x'), VarIdExpr('y')), ...
                    IntExpr(1));    
            %x/y
            thens{end + 1} = BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('x'), VarIdExpr('y'));
            bodyElts{1} = LustreEq(...
                VarIdExpr('z'), ...
                IteExpr.nestedIteExpr(conds, thens)...
                );
            node = LustreNode();
            node.setMetaInfo('Rounds number to the nearest representable value. If a tie occurs, rounds toward positive infinity');
            node.setName('int_div_Nearest');
            node.setInputs({LustreVar('x', 'int'), LustreVar('y', 'int')});
            node.setOutputs(LustreVar('z', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        
        function [node, external_nodes_i, opens, abstractedNodes] = get_int_div_Zero(varargin)
            opens = {};
            abstractedNodes = {};
            external_nodes_i = {strcat('LustMathLib_', 'abs_int')};
            % format = '--Rounds positive and negative numbers toward positive infinity\n ';
            % format = [format,  'node int_div_Zero (x, y: int)\nreturns(z:int);\nlet\n\t'];
            % format = [format, 'z= if y = 0 then if x>0 then 2147483647 else -2147483648\n\t'];
            % format = [format, 'else if x mod y = 0 then x/y\n\t'];
            % format = [format, 'else if (abs_int(y) > abs_int(x)) then 0 \n\t'];
            % format = [format, 'else if (x>0) then x/y \n\t'];
            % format = [format, 'else (-x)/(-y);\ntel\n\n'];
            % node = sprintf(format);
            %y = 0
            conds{1} = BinaryExpr(BinaryExpr.EQ, VarIdExpr('y'), IntExpr(0));
            %if x>0 then 2147483647 else -2147483648
            thens{1} = IteExpr(...
                BinaryExpr(BinaryExpr.GT, VarIdExpr('x'), IntExpr(0)),...
                IntExpr(2147483647), IntExpr(-2147483648),...
                true);
            % x mod y = 0
            conds{2} = BinaryExpr(...
                BinaryExpr.EQ, ...
                BinaryExpr(BinaryExpr.MOD, VarIdExpr('x'), VarIdExpr('y')), ...
                IntExpr(0));
            % x/y
            thens{2} = BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('x'), VarIdExpr('y'));
            % (abs_int(y) > abs_int(x))
            conds{3} =  BinaryExpr(BinaryExpr.GT, ...
                           NodeCallExpr('abs_int', VarIdExpr('y')),...
                           NodeCallExpr('abs_int', VarIdExpr('x')));
            % 0
            thens{3} = IntExpr(0);
            % (x>0)
            conds{4} =  BinaryExpr(BinaryExpr.GT, ...
                            VarIdExpr('x'),...
                            IntExpr(0));
            % x/y
            thens{4} = BinaryExpr(BinaryExpr.DIVIDE, VarIdExpr('x'), VarIdExpr('y'));
            % (-x)/(-y)
            thens{5} = BinaryExpr(...
                    BinaryExpr.DIVIDE, ...
                    UnaryExpr(UnaryExpr.NEG, VarIdExpr('x')), ...
                    UnaryExpr(UnaryExpr.NEG, VarIdExpr('y')));
            bodyElts{1} = LustreEq(...
                VarIdExpr('z'), ...
                IteExpr.nestedIteExpr(conds, thens)...
                );
            node = LustreNode();
            node.setMetaInfo('Rounds positive and negative numbers toward positive infinity');
            node.setName('int_div_Zero');
            node.setInputs({LustreVar('x', 'int'), LustreVar('y', 'int')});
            node.setOutputs(LustreVar('z', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        
        %% fmod, rem, mod
        function [node, external_nodes_i, opens, abstractedNodes] = get_fmod(varargin)
            opens = {'lustrec_math'};
            abstractedNodes = {'fmod'};
            external_nodes_i = {};
            node = '';
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get_rem_int_int(varargin)
            opens = {};
            abstractedNodes = {};
            external_nodes_i = {strcat('LustMathLib_', 'abs_int')};
            % format = 'node rem_int_int (x, y: int)\nreturns(z:int);\nlet\n\t';
            % format = [format, 'z = if (y = 0 or x = 0) then 0\n\t\telse\n\t\t (x mod y) - (if (x mod y <> 0 and x <= 0) then abs_int(y) else 0);\ntel\n\n'];
            % node = sprintf(format);
            cond = BinaryExpr(...
                BinaryExpr.OR, ...
                BinaryExpr(BinaryExpr.EQ, VarIdExpr('y'), IntExpr(0)), ...
                BinaryExpr(BinaryExpr.EQ, VarIdExpr('x'), IntExpr(0)));
            cond2 = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr( BinaryExpr.NEQ,...
                            BinaryExpr(BinaryExpr.MOD, VarIdExpr('x'), VarIdExpr('y')),...
                            IntExpr(0)), ...
                BinaryExpr(BinaryExpr.LTE, VarIdExpr('x'), IntExpr(0)));
            elseExp =  BinaryExpr(...
                BinaryExpr.MINUS, ...
                BinaryExpr(BinaryExpr.MOD, VarIdExpr('x'), VarIdExpr('y')),...
                IteExpr(cond2, ...
                        NodeCallExpr('abs_int',  VarIdExpr('y')),...
                        IntExpr(0),...
                        true)...
                 );
            rhs = IteExpr(cond, IntExpr(0), elseExp);
            bodyElts{1} = LustreEq(...
                VarIdExpr('z'), ...
                rhs...
                );
            node = LustreNode();
            node.setName('rem_int_int');
            node.setInputs({LustreVar('x', 'int'), LustreVar('y', 'int')});
            node.setOutputs(LustreVar('z', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        function [node, external_nodes_i, opens, abstractedNodes] = get_mod_int_int(varargin)
            opens = {};
            abstractedNodes = {};
            external_nodes_i = {strcat('LustMathLib_', 'abs_int')};
            % format = 'node mod_int_int (x, y: int)\nreturns(z:int);\nlet\n\t';
            % format = [format, 'z = if (y = 0 or x = 0) then x\n\t\telse\n\t\t (x mod y) - (if (x mod y <> 0 and y <= 0) then (if y > 0 then y else -y) else 0);\ntel\n\n'];
            % node = sprintf(format);
             cond = BinaryExpr(...
                BinaryExpr.OR, ...
                BinaryExpr(BinaryExpr.EQ, VarIdExpr('y'), IntExpr(0)), ...
                BinaryExpr(BinaryExpr.EQ, VarIdExpr('x'), IntExpr(0)));
            cond2 = BinaryExpr(...
                BinaryExpr.AND, ...
                BinaryExpr( BinaryExpr.NEQ,...
                            BinaryExpr(BinaryExpr.MOD, VarIdExpr('x'), VarIdExpr('y')),...
                            IntExpr(0)), ...
                BinaryExpr(BinaryExpr.LTE, VarIdExpr('y'), IntExpr(0)));
            elseExp =  BinaryExpr(...
                BinaryExpr.MINUS, ...
                BinaryExpr(BinaryExpr.MOD, VarIdExpr('x'), VarIdExpr('y')),...
                IteExpr(cond2, ...
                        NodeCallExpr('abs_int',  VarIdExpr('y')),...
                        IntExpr(0),...
                        true)...
                 );
            rhs = IteExpr(cond, VarIdExpr('x'), elseExp);
            bodyElts{1} = LustreEq(...
                VarIdExpr('z'), ...
                rhs...
                );
            node = LustreNode();
            node.setName('mod_int_int');
            node.setInputs({LustreVar('x', 'int'), LustreVar('y', 'int')});
            node.setOutputs(LustreVar('z', 'int'));
            node.setBodyEqs(bodyElts);           
            node.setIsMain(false);
        end
        
        
        
        %% Matrix inversion
        function [node, external_nodes_i, opens, abstractedNodes] = get__inv_M_2x2(backend, varargin)
            % support 2x2 matrix inversion            
            n = 2;            
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.get_inverse_code(backend,n);            
        end
        
        function [node, external_nodes_i, opens, abstractedNodes] = get__inv_M_3x3(backend,varargin)
            % support 3x3 matrix inversion 
            % 3x3 matrix inverse formulations:
            % http://mathworld.wolfram.com/MatrixInverse.html
            n = 3;            
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.get_inverse_code(backend,n);            
        end
        
        function [node, external_nodes_i, opens, abstractedNodes] = get__inv_M_4x4(backend,varargin)
            % support 4x4 matrix inversion
            % http://semath.info/src/inverse-cofactor-ex4.html
            n = 4;
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.get_inverse_code(backend,n); 
        end
        
        function [node, external_nodes_i, opens, abstractedNodes] = get__inv_M_5x5(backend,varargin)
            % only KIND2 contract for 5x5 matrix inversion
            n = 5;
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.get_inverse_code(backend,n); 
        end        

        function [node, external_nodes_i, opens, abstractedNodes] = get__inv_M_6x6(backend,varargin)
            % only KIND2 contract for 6x6 matrix inversion
            n = 6;
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.get_inverse_code(backend,n); 
        end 
        
        function [node, external_nodes_i, opens, abstractedNodes] = get__inv_M_7x7(backend,varargin)
            % only KIND2 contract for 7x7 matrix inversion
            n = 7;
            [node, external_nodes_i, opens, abstractedNodes] = LustMathLib.get_inverse_code(backend,n); 
        end 
        
        function [node, external_nodes_i, opens, abstractedNodes] = get_inverse_code(backend,n)
            % support 2x2 matrix inversion
            % support 3x3 matrix inversion
            % support 4x4 matrix inversion
            % contract for 2x2 to 7x7 matrix inversion
            opens = {};
            abstractedNodes = {};
            external_nodes_i ={};
            node_name = sprintf('_inv_M_%dx%d',n,n);
            node = LustreNode();
            node.setName(node_name);
            node.setIsMain(false);
            vars = {};
            body = {};
            
            % inputs & outputs
            % a: inputs, ai: outputs
            a = cell(n,n);
            ai = cell(n,n);
            for i=1:n
                for j=1:n
                    a{i,j} = VarIdExpr(sprintf('a%d%d',i,j));
                    ai{i,j} = VarIdExpr(sprintf('ai%d%d',i,j));
                end
            end
            inputs = cell(1,n*n);
            outputs = cell(1,n*n);
            inline_a = cell(1,n*n);
            inline_ai = cell(1,n*n);            
            counter = 0;
            for j=1:n
                for i=1:n
                    counter = counter + 1;
                    inline_a{counter} = a{i,j};
                    inline_ai{counter} = ai{i,j};                    
                    inputs{counter} = LustreVar(a{i,j},'real');
                    outputs{counter} = LustreVar(ai{i,j},'real');
                end
            end
            if BackendType.isKIND2(backend)
                contractBody = LustMathLib.getContractBody_nxn_inverstion(n,inline_a,inline_ai);
                contract = LustreContract();
                contract.setBody(contractBody);
                node.setLocalContract(contract);
            end
            % inversion and contract
            if  n > 4
                node.setIsImported(true);
            elseif n==4 && BackendType.isKIND2(backend)
                node.setIsImported(true);
            else
                Lustre_inversion = 0;
                if n == 2 || n == 3 || n ==4
                    Lustre_inversion = 1;
                end
                if Lustre_inversion == 1
                    vars = cell(1,n*n+1);
                    det = VarIdExpr('det');
                    vars{1} = LustreVar(det,'real');
                    % adj: adjugate
                    adj = cell(n,n);
                    for i=1:n
                        for j=1:n
                            adj{i,j} = VarIdExpr(sprintf('adj%d%d',i,j));
                            vars{(i-1)*n+j+1} = LustreVar(adj{i,j},'real');
                        end
                    end
                    
                    body = LustMathLib.get_Det_Adjugate_Code(n,det,a,adj);
                    
                    % define inverse
                    for i=1:n
                        for j=1:n
                            body{end+1} = LustreEq(ai{i,j},BinaryExpr(BinaryExpr.DIVIDE,adj{i,j},det));
                        end
                    end
                else
                    display_msg(...
                        sprintf('Matrix inversion for higher than 4x4 matrix is not supported in LustMathLib'), ...
                        MsgType.ERROR, 'LustMathLib', '');
                end
            end
            
            % set node
            node.setInputs(inputs);
            node.setOutputs(outputs);
            node.setBodyEqs(body);
            node.setLocalVars(vars);            
            
        end
        
        function body = get_Det_Adjugate_Code(n,det,a,adj)
            body = {};
            body{1} = AssertExpr(BinaryExpr(BinaryExpr.NEQ, ...
                det, RealExpr('0.0')));
            if n == 2
                % det
                term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,1},a{2,2});
                term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,2},a{2,1});
                body{end + 1} = LustreEq(det,BinaryExpr(BinaryExpr.MINUS,term1,term2));
                
                % adjugate & inverse
                body{end+1} = LustreEq(adj{1,1},a{2,2});
                body{end+1} = LustreEq(adj{1,2},UnaryExpr(UnaryExpr.NEG,a{1,2}));
                body{end+1} = LustreEq(adj{2,1},UnaryExpr(UnaryExpr.NEG,a{2,1}));
                body{end+1} = LustreEq(adj{2,2},a{1,1});              
            elseif n == 3
                % define det
                term1 =  BinaryExpr(BinaryExpr.MULTIPLY,a{1,1},adj{1,1});
                term2 =  BinaryExpr(BinaryExpr.MULTIPLY,a{1,2},adj{2,1});
                term4 = BinaryExpr(BinaryExpr.PLUS,term1,term2);
                term3 =  BinaryExpr(BinaryExpr.MULTIPLY,a{1,3},adj{3,1});
                body{end + 1} = LustreEq(det,BinaryExpr(BinaryExpr.PLUS,term4,term3));
                
                % define adjugate
                term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,2},a{3,3});
                term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,3},a{3,2});
                body{end+1} = LustreEq(adj{1,1},BinaryExpr(BinaryExpr.MINUS,term1,term2));
                
                term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,3},a{3,1});
                term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,1},a{3,3});
                body{end+1} = LustreEq(adj{2,1},BinaryExpr(BinaryExpr.MINUS,term1,term2));
                
                term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,1},a{3,2});
                term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{3,1},a{2,2});
                body{end+1} = LustreEq(adj{3,1},BinaryExpr(BinaryExpr.MINUS,term1,term2));
                
                term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,3},a{3,2});
                term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{3,3},a{1,2});
                body{end+1} = LustreEq(adj{1,2},BinaryExpr(BinaryExpr.MINUS,term1,term2));
                
                term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,1},a{3,3});
                term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,3},a{3,1});
                body{end+1} = LustreEq(adj{2,2},BinaryExpr(BinaryExpr.MINUS,term1,term2));
                
                term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,2},a{3,1});
                term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{3,2},a{1,1});
                body{end+1} = LustreEq(adj{3,2},BinaryExpr(BinaryExpr.MINUS,term1,term2));
                
                term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,2},a{2,3});
                term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,2},a{1,3});
                body{end+1} = LustreEq(adj{1,3},BinaryExpr(BinaryExpr.MINUS,term1,term2));
                
                term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,3},a{2,1});
                term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,3},a{1,1});
                body{end+1} = LustreEq(adj{2,3},BinaryExpr(BinaryExpr.MINUS,term1,term2));
                
                term1 = BinaryExpr(BinaryExpr.MULTIPLY,a{1,1},a{2,2});
                term2 = BinaryExpr(BinaryExpr.MULTIPLY,a{2,1},a{1,2});
                body{end+1} = LustreEq(adj{3,3},BinaryExpr(BinaryExpr.MINUS,term1,term2));
                
            elseif n  == 4

                
                
                % define det
                term1 =  BinaryExpr(BinaryExpr.MULTIPLY,a{1,1},adj{1,1});
                term2 =  BinaryExpr(BinaryExpr.MULTIPLY,a{2,1},adj{1,2});
                term3 =  BinaryExpr(BinaryExpr.MULTIPLY,a{3,1},adj{1,3});
                term4 =  BinaryExpr(BinaryExpr.MULTIPLY,a{4,1},adj{1,4});
                term5 =  BinaryExpr(BinaryExpr.PLUS,term1,term2);
                term6 =  BinaryExpr(BinaryExpr.PLUS,term3,term4);
                body{end + 1} = LustreEq(det,BinaryExpr(BinaryExpr.PLUS,term5,term6));             
                
                % define adjugate
                %   adj11
                list{1} = {a{2,2},a{3,3},a{4,4}};
                list{2} = {a{2,3},a{3,4},a{4,2}};
                list{3} = {a{2,4},a{3,2},a{4,3}};
                list{4} = {a{2,4},a{3,3},a{4,2}};
                list{5} = {a{2,3},a{3,2},a{4,4}};
                list{6} = {a{2,2},a{3,4},a{4,3}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{1,1},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %   adj12
                list{1} = {a{1,4},a{3,3},a{4,2}};
                list{2} = {a{1,3},a{3,2},a{4,4}};
                list{3} = {a{1,2},a{3,4},a{4,3}};
                list{4} = {a{1,2},a{3,3},a{4,4}};
                list{5} = {a{1,3},a{3,4},a{4,2}};
                list{6} = {a{1,4},a{3,2},a{4,3}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{1,2},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %   adj13
                list{1} = {a{1,2},a{2,3},a{4,4}};
                list{2} = {a{1,3},a{2,4},a{4,2}};
                list{3} = {a{1,4},a{2,2},a{4,3}};
                list{4} = {a{1,4},a{2,3},a{4,2}};
                list{5} = {a{1,3},a{2,2},a{4,4}};
                list{6} = {a{1,2},a{2,4},a{4,3}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{1,3},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %     adj14
                list{1} = {a{1,4},a{2,3},a{3,2}};
                list{2} = {a{1,3},a{2,2},a{3,4}};
                list{3} = {a{1,2},a{2,4},a{3,3}};
                list{4} = {a{1,2},a{2,3},a{3,4}};
                list{5} = {a{1,3},a{2,4},a{3,2}};
                list{6} = {a{1,4},a{2,2},a{3,3}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{1,4},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %    adj21
                list{1} = {a{2,4},a{3,3},a{4,1}};
                list{2} = {a{2,3},a{3,1},a{4,4}};
                list{3} = {a{2,1},a{3,4},a{4,3}};
                list{4} = {a{2,1},a{3,3},a{4,4}};
                list{5} = {a{2,3},a{3,4},a{4,1}};
                list{6} = {a{2,4},a{3,1},a{4,3}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{2,1},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %    adj22
                list{1} = {a{1,1},a{3,3},a{4,4}};
                list{2} = {a{1,3},a{3,4},a{4,1}};
                list{3} = {a{1,4},a{3,1},a{4,3}};
                list{4} = {a{1,4},a{3,3},a{4,1}};
                list{5} = {a{1,3},a{3,1},a{4,4}};
                list{6} = {a{1,1},a{3,4},a{4,3}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{2,2},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %    adj23
                list{1} = {a{1,4},a{2,3},a{4,1}};
                list{2} = {a{1,3},a{2,1},a{4,4}};
                list{3} = {a{1,1},a{2,4},a{4,3}};
                list{4} = {a{1,1},a{2,3},a{4,4}};
                list{5} = {a{1,3},a{2,4},a{4,1}};
                list{6} = {a{1,4},a{2,1},a{4,3}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{2,3},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %    adj24
                list{1} = {a{1,1},a{2,3},a{3,4}};
                list{2} = {a{1,3},a{2,4},a{3,1}};
                list{3} = {a{1,4},a{2,1},a{3,3}};
                list{4} = {a{1,4},a{2,3},a{3,1}};
                list{5} = {a{1,3},a{2,1},a{3,4}};
                list{6} = {a{1,1},a{2,4},a{3,3}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{2,4},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %    adj31
                list{1} = {a{2,1},a{3,2},a{4,4}};
                list{2} = {a{2,2},a{3,4},a{4,1}};
                list{3} = {a{2,4},a{3,1},a{4,2}};
                list{4} = {a{2,4},a{3,2},a{4,1}};
                list{5} = {a{2,2},a{3,1},a{4,4}};
                list{6} = {a{2,1},a{3,4},a{4,2}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{3,1},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %    adj32
                list{1} = {a{1,4},a{3,2},a{4,1}};
                list{2} = {a{1,2},a{3,1},a{4,4}};
                list{3} = {a{1,1},a{3,4},a{4,2}};
                list{4} = {a{1,1},a{3,2},a{4,4}};
                list{5} = {a{1,2},a{3,4},a{4,1}};
                list{6} = {a{1,4},a{3,1},a{4,2}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{3,2},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %    adj33
                list{1} = {a{1,1},a{2,2},a{4,4}};
                list{2} = {a{1,2},a{2,4},a{4,1}};
                list{3} = {a{1,4},a{2,1},a{4,2}};
                list{4} = {a{1,4},a{2,2},a{4,1}};
                list{5} = {a{1,2},a{2,1},a{4,4}};
                list{6} = {a{1,1},a{2,4},a{4,2}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{3,3},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %     adj34
                list{1} = {a{1,4},a{2,2},a{3,1}};
                list{2} = {a{1,2},a{2,1},a{3,4}};
                list{3} = {a{1,1},a{2,4},a{3,2}};
                list{4} = {a{1,1},a{2,2},a{3,4}};
                list{5} = {a{1,2},a{2,4},a{3,1}};
                list{6} = {a{1,4},a{2,1},a{3,2}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{3,4},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %   adj41
                list{1} = {a{2,3},a{3,2},a{4,1}};
                list{2} = {a{2,2},a{3,1},a{4,3}};
                list{3} = {a{2,1},a{3,3},a{4,2}};
                list{4} = {a{2,1},a{3,2},a{4,3}};
                list{5} = {a{2,2},a{3,3},a{4,1}};
                list{6} = {a{2,3},a{3,1},a{4,2}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{4,1},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %    adj42
                list{1} = {a{1,1},a{3,2},a{4,3}};
                list{2} = {a{1,2},a{3,3},a{4,1}};
                list{3} = {a{1,3},a{3,1},a{4,2}};
                list{4} = {a{1,3},a{3,2},a{4,1}};
                list{5} = {a{1,2},a{3,1},a{4,3}};
                list{6} = {a{1,1},a{3,3},a{4,2}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{4,2},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                %    adj43
                list{1} = {a{1,3},a{2,2},a{4,1}};
                list{2} = {a{1,2},a{2,1},a{4,3}};
                list{3} = {a{1,1},a{2,3},a{4,2}};
                list{4} = {a{1,1},a{2,2},a{4,3}};
                list{5} = {a{1,2},a{2,3},a{4,1}};
                list{6} = {a{1,3},a{2,1},a{4,2}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{4,3},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                
                % adj44
                list{1} = {a{1,1},a{2,2},a{3,3}};
                list{2} = {a{1,2},a{2,3},a{3,1}};
                list{3} = {a{1,3},a{2,1},a{3,2}};
                list{4} = {a{1,3},a{2,2},a{3,1}};
                list{5} = {a{1,2},a{2,1},a{3,3}};
                list{6} = {a{1,1},a{2,3},a{3,2}};
                
                terms = cell(1,6);
                for i=1:6
                    terms{i} = BinaryExpr.BinaryMultiArgs(BinaryExpr.MULTIPLY,list{i});
                end
                
                termPos = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{1},terms{2},terms{3}});
                termNeg = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,{terms{4},terms{5},terms{6}});
                body{end+1} = LustreEq(adj{4,4},BinaryExpr(BinaryExpr.MINUS,termPos,termNeg));
                               
            else
                display_msg(...
                    sprintf('Option Matrix(*) with divid is not supported in block LustMathLib'), ...
                    MsgType.ERROR, 'LustMathLib', '');
                return;
            end
        end
        
        function contractBody = getContractBody_nxn_inverstion(n,inputs,outputs)
            % guarantee code     A*A_inv = I
            % A*A_inv(ij) = 1.0 if i==j, = 0.0 if i!=j
            contractBody = cell(1, n*n);
            codeIndex = 0;
            zero = RealExpr(0.0);
            one = RealExpr(1.0);
            
            for i=1:n      %i is row of result matrix
                for j=1:n      %j is column of result matrix
                    terms = cell(1,n);
                    for k=1:n
                        A_index = sub2ind([n,n],i,k);
                        A_inv_index = sub2ind([n,n],k,j);

                        terms{k} = BinaryExpr(BinaryExpr.MULTIPLY, ...
                                        inputs{1,A_index},...
                                        outputs{1,A_inv_index});
                    end
                    lhs = BinaryExpr.BinaryMultiArgs(BinaryExpr.PLUS,terms);
                    if i==j
                        rhs = one;
                    else
                        rhs = zero;
                    end                    
                    codeIndex = codeIndex + 1;
                    contractBody{codeIndex} = ContractGuaranteeExpr('',BinaryExpr(BinaryExpr.EQ,lhs, rhs));
                end
                
            end            
        end
        
    end
    
end


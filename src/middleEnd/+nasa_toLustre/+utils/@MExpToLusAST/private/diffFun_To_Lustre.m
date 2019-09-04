function [code, exp_dt, dim, extra_code] = diffFun_To_Lustre(tree, args)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2019 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Francois Conzelmann <francois.conzelmann@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    dimension = 1;
    recursive = 1;
    code = {};
    op = nasa_toLustre.lustreAst.BinaryExpr.MINUS;
    [x, exp_dt, x_dim, extra_code] = nasa_toLustre.utils.MExpToLusAST.expression_To_Lustre(tree.parameters(1), args);
    
    if length(x_dim) > 2 % TODO support multi-dimension input
        ME = MException('COCOSIM:TREE2CODE', ...
            'Function diff in expression "%s" first argument is %d-dimension, more than 2 is not supported.',...
            tree.text, numel(x_dim));
        throw(ME);
    end
    
    if x_dim(1) == 1
        dimension = 2;
    end
    
    if length(tree.parameters) > 1
        if strcmp(tree.parameters{2}.type, 'constant')
            [n, ~, ~, extra_code_i] = nasa_toLustre.utils.MExpToLusAST.expression_To_Lustre(tree.parameters(2), args);
            extra_code = MatlabUtils.concat(extra_code, extra_code_i);
            recursive = n{1}.value;
        else
            ME = MException('COCOSIM:TREE2CODE', ...
                'Function diff in expression "%s" second argument must be a constant.',...
                tree.text);
            throw(ME);
        end
    end
    
    if length(tree.parameters) > 2
        if strcmp(tree.parameters{2}.type, 'constant')
            [n, ~, ~, extra_code_i] = nasa_toLustre.utils.MExpToLusAST.expression_To_Lustre(tree.parameters(3), args);
            extra_code = MatlabUtils.concat(extra_code, extra_code_i);
            dimension = n{1}.value;
        else
            ME = MException('COCOSIM:TREE2CODE', ...
                'Function diff in expression "%s" third argument must be a constant.',...
                tree.text);
            throw(ME);
        end
    end
    
    if recursive == 1
        x_reshape = reshape(x, x_dim);
        
        if dimension == 1
            dim = [x_dim(1)-1, x_dim(2)];
            for i=1:dim(1)
                for j=1:dim(2)
                    exp = nasa_toLustre.lustreAst.BinaryExpr.BinaryMultiArgs(op, x_reshape(i:(i+1), j));
                    code{i, j} = nasa_toLustre.lustreAst.UnaryExpr(...
                        nasa_toLustre.lustreAst.UnaryExpr.NEG, exp);
                end
            end
        elseif dimension == 2
            dim = [x_dim(1), x_dim(2)-1];
            for i=1:dim(1)
                for j=1:dim(2)
                    exp = nasa_toLustre.lustreAst.BinaryExpr.BinaryMultiArgs(op, x_reshape(i, j:(j+1)));
                    code{i, j} = nasa_toLustre.lustreAst.UnaryExpr(...
                        nasa_toLustre.lustreAst.UnaryExpr.NEG, exp);
                end
            end
        else
            ME = MException('COCOSIM:TREE2CODE', ...
                'Function diff in expression "%s" do not support value above 2 as second argument',...
                tree.text, numel(x_dim));
            throw(ME);
        end
        
        code = reshape(code, [prod(dim) 1]);
    else
        x_text = tree.parameters{1}.text;
        expr = sprintf("diff(%s, 1, %d)", x_text, dimension);
        if length(tree.parameters) <= 2
            for i= 2:recursive
                expr = sprintf("diff(%s, 1)", expr);
            end
        else
            for i= 2:recursive
                expr = sprintf("diff(%s, 1, %d)", expr, dimension);
            end
        end
        
        new_tree = MatlabUtils.getExpTree(expr);
        
        [code, exp_dt, dim, extra_code] = nasa_toLustre.utils.MExpToLusAST.expression_To_Lustre(new_tree, args);
    end
    
end



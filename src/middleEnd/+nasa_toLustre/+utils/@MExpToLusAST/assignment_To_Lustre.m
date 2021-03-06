%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
% Notices:
%
% Copyright @ 2020 United States Government as represented by the 
% Administrator of the National Aeronautics and Space Administration.  All 
% Rights Reserved.
%
% Disclaimers
%
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY 
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING,
% BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL CONFORM 
% TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS 
% FOR A PARTICULAR PURPOSE, OR FREEDOM FROM INFRINGEMENT, ANY WARRANTY THAT
% THE SUBJECT SOFTWARE WILL BE ERROR FREE, OR ANY WARRANTY THAT 
% DOCUMENTATION, IF PROVIDED, WILL CONFORM TO THE SUBJECT SOFTWARE. THIS 
% AGREEMENT DOES NOT, IN ANY MANNER, CONSTITUTE AN ENDORSEMENT BY 
% GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT OF ANY RESULTS, RESULTING 
% DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY OTHER APPLICATIONS RESULTING 
% FROM USE OF THE SUBJECT SOFTWARE.  FURTHER, GOVERNMENT AGENCY DISCLAIMS 
% ALL WARRANTIES AND LIABILITIES REGARDING THIRD-PARTY SOFTWARE, IF PRESENT 
% IN THE ORIGINAL SOFTWARE, AND DISTRIBUTES IT "AS IS."
%
% Waiver and Indemnity:  RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS 
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, 
% AS WELL AS ANY PRIOR RECIPIENT.  IF RECIPIENT'S USE OF THE SUBJECT 
% SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES, EXPENSES OR 
% LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM PRODUCTS BASED 
% ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT SOFTWARE, RECIPIENT 
% SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED STATES GOVERNMENT, ITS 
% CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT, TO THE 
% EXTENT PERMITTED BY LAW.  RECIPIENT'S SOLE REMEDY FOR ANY SUCH MATTER 
% SHALL BE THE IMMEDIATE, UNILATERAL TERMINATION OF THIS AGREEMENT.
% 
% Notice: The accuracy and quality of the results of running CoCoSim 
% directly corresponds to the quality and accuracy of the model and the 
% requirements given as inputs to CoCoSim. If the models and requirements 
% are incorrectly captured or incorrectly input into CoCoSim, the results 
% cannot be relied upon to generate or error check software being developed. 
% Simply stated, the results of CoCoSim are only as good as
% the inputs given to CoCoSim.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [code, assignment_dt, dim, extra_code] = assignment_To_Lustre(tree, args)

    global VISITED_VARIABLES MFUNCTION_EXTERNAL_NODES;
    if isempty(VISITED_VARIABLES)
        VISITED_VARIABLES = containers.Map();
    end
    code = {};
    dim = [];
    extra_code = {};
    if_cond = args.if_cond;
    assignment_dt = nasa_toLustre.utils.MExpToLusDT.expression_DT(tree, args);
    
    %% Get left and right expressions
    try
        args.expected_lusDT = assignment_dt;
        
        args.isLeft = true;
        [left, left_exp_dt, dim, left_extra_code] = nasa_toLustre.utils.MExpToLusAST.expression_To_Lustre(...
            tree.leftExp, args);
        
        args.isLeft = false;
        args.expected_dim = dim;
        [right, ~, ~, right_extra_code] = nasa_toLustre.utils.MExpToLusAST.expression_To_Lustre(...
            tree.rightExp, args);
        extra_code = coco_nasa_utils.MatlabUtils.concat(left_extra_code, right_extra_code);
    catch me
        display_msg(...
            sprintf('Expression "%s" is not handled in Block %s. The code will be abstracted.',...
            tree.text, HtmlItem.addOpenCmd(args.blk.Origin_path)),...
            MsgType.WARNING, 'MExpToLusAST.assignment_To_Lustre', '');
        
        display_msg(me.getReport(), MsgType.DEBUG, 'MExpToLusAST.assignment_To_Lustre', '');
        
        [assignment_node] = nasa_toLustre.utils.MF2LusUtils.abstract_statements_block(...
            tree, args, 'Expression');
        if isempty( assignment_node )
            return;
        end
        [call, oututs_Ids] = assignment_node.nodeCall();
        if length(oututs_Ids) > 1
            oututs_Ids = nasa_toLustre.lustreAst.TupleExpr(oututs_Ids);
        end
        code{1} = nasa_toLustre.lustreAst.LustreEq(oututs_Ids, call);
        assignment_node = assignment_node.pseudoCode2Lustre(args.data_map);
        MFUNCTION_EXTERNAL_NODES{end+1} = assignment_node;
        return;
    end
    %% Solve the issue of u(j) = x; => u_1 = if j == 1 then x else u_1; ....
    if strcmp(tree.leftExp.type, 'fun_indexing')
        conds = nasa_toLustre.lustreAst.IteExpr.getCondsThens(left{1});
        if ~isempty(conds)
            [left, right, status] = ArrayIndexNotConstant(left, right, tree);
            if status
                ME = MException('COCOSIM:TREE2CODE', ...
                    'Array index on the left hand of the expression "%s" should be a constant.',...
                    tree.text);
                throw(ME);
            end
        end
    end
    
    %% Solve the issue of node call with many outputs
    %e.g. [z,y] = f(x), v = f(x) where v is vector
    if length(left) > 1 && length(right) == 1 ...
            && isa(right{1}, 'nasa_toLustre.lustreAst.NodeCallExpr')
        left = {nasa_toLustre.lustreAst.TupleExpr(left)};
    end
    
    %% Solve the issue of many outputs equals to a scalar
    %e.g. X(1:3) = 0.0
    if length(left) > 1 && length(right) == 1
        [left, right] = nasa_toLustre.utils.MExpToLusAST.inlineOperands(left, right, tree);
    end
    
    
    
    
    
    %% add if condition if the code is inside an if
    if args.isMatlabFun && ~isempty(if_cond)
        if length(left) == 1 ...
                && isa(left{1}, 'nasa_toLustre.lustreAst.TupleExpr')
            left_args = left{1}.getArgs();
        else
            left_args = left;
        end
        init = cell(1, length(left_args));
        for i=1:length(left_args)
            if  isKey(VISITED_VARIABLES, left_args{i}.getId())
                init{i} = left_args{i};
            else % if first time
                if strcmp(left_exp_dt, 'int')
                    init{i} = nasa_toLustre.lustreAst.IntExpr(0);
                elseif strcmp(left_exp_dt, 'bool')
                    init{i} = nasa_toLustre.lustreAst.BoolExpr(false);
                else
                    init{i} = nasa_toLustre.lustreAst.RealExpr('0.0');
                end
            end
        end
        if length(right) == length(init)
            for i=1:length(init)
                right{i} = nasa_toLustre.lustreAst.IteExpr(if_cond, right{i}, init{i});
            end
        elseif length(right) == 1
            % case of node call exp
            right{1} =  nasa_toLustre.lustreAst.IteExpr(if_cond, right{1}, ...
                nasa_toLustre.lustreAst.TupleExpr(init));
        else
            %TODO
            ME = MException('COCOSIM:TREE2CODE', ...
                'Parser error: unexpected size of right expression in "%s".',...
                tree.text);
            throw(ME);
        end
    end
    
    %% update VISITED_VARIABLES
    
    if args.isMatlabFun
        if length(left) == 1 ...
                && isa(left{1}, 'nasa_toLustre.lustreAst.TupleExpr')
            left_args = left{1}.getArgs();
        else
            left_args = left;
        end
        for i=1:length(left_args)
            if ~isKey(VISITED_VARIABLES, left_args{i}.getId())
                VISITED_VARIABLES(left_args{i}.getId()) = left_args{i};
            end
        end
    end
    
    %% Creat code
    if  numel(left) == numel(right)
        eqts = cell(numel(left), 1);
        for i=1:numel(left)
            eqts{i} = nasa_toLustre.lustreAst.LustreEq(left{i}, right{i});
        end
        code{1} = nasa_toLustre.lustreAst.ConcurrentAssignments(eqts);
    else
        ME = MException('COCOSIM:TREE2CODE', ...
            'Assignement "%s" has incompatible dimensions. Left width is %d where the right width is %d',...
            tree.text, numel(left), numel(right));
        throw(ME);
    end
    
end

function [new_left, new_right, status] = ArrayIndexNotConstant(left, right, tree)
    %e.g. u(index) = exp
    % u_1 = if index = 1 then exp else u_1;
    % u_2 = if index = 2 then exp else u_2;
    status = 0;
    %code = {};
    [left, right] = nasa_toLustre.utils.MExpToLusAST.inlineOperands(left, right, tree);
    %eqts = {};
    new_left = {};
    new_right = {};
    for i=1:numel(left)
        [conds, thens] = nasa_toLustre.lustreAst.IteExpr.getCondsThens(left{i});
        if isempty(conds)
            %eqts{end+1} = nasa_toLustre.lustreAst.LustreEq(left{i}, right{i});
            new_left{end+1} = left{i};
            new_right{end+1} = right{i};
        else
            new_thens = thens;
            for j=1:numel(new_thens)
                [varId, status] = getVarID(new_thens{j});
                if status
                    return;
                end
                % replace varId by the right expression
                if numel(conds) >= j
                    c = conds{j};
                else
                    c = nasa_toLustre.lustreAst.UnaryExpr(nasa_toLustre.lustreAst.UnaryExpr.NOT, ...
                        nasa_toLustre.lustreAst.BinaryExpr.BinaryMultiArgs(nasa_toLustre.lustreAst.BinaryExpr.OR, conds));
                end
                %eqts{end+1} = nasa_toLustre.lustreAst.LustreEq(varId, nasa_toLustre.lustreAst.IteExpr(c, right{i}, varId));
                new_left{end+1} = varId;
                new_right{end+1} = nasa_toLustre.lustreAst.IteExpr(c, right{i}, varId);
            end
        end
    end
    %code{1} = nasa_toLustre.lustreAst.ConcurrentAssignments(eqts);
end

function [varId, status] = getVarID(then)
    status = 0;
    varId = {};
    if isa(then, 'nasa_toLustre.lustreAst.VarIdExpr')
        varId = then;
    else
        status = 1;
    end
end

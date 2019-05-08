function extNode =  get_wrapper_node(...
    ~,blk,interpolationExtNode,blkParams)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Trinh, Khanh V <khanh.v.trinh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Interpolation_using_PreLookup
   
    % node header
    wrapper_header.NodeName = ...
        sprintf('%s_Interp_nD_wrapper_node',blkParams.blk_name);
    
    % node outputs, only y_out
    wrapper_header.output = interpolationExtNode.outputs;   
    wrapper_header.output_name{1} = nasa_toLustre.lustreAst.VarIdExpr(...
        wrapper_header.output{1}.id);

    numAdjDims = blkParams.NumberOfAdjustedTableDimensions;     
    wrapper_header.inputs = cell(1,2*numAdjDims); 
    wrapper_header.inputs_name = cell(1,2*numAdjDims); 
    fraction_name = cell(1,numAdjDims); 
    for i=1:numAdjDims
        % wrapper header
        wrapper_header.inputs_name{(i-1)*2+1} = ...
            nasa_toLustre.lustreAst.VarIdExpr(sprintf('k_dim_%d',i));
        wrapper_header.inputs{(i-1)*2+1} = ...
            nasa_toLustre.lustreAst.LustreVar(...
            wrapper_header.inputs_name{(i-1)*2+1},'int');   
        wrapper_header.inputs_name{(i-1)*2+2} = ...
            nasa_toLustre.lustreAst.VarIdExpr(...
            sprintf('fraction_dim_%d',i));
        fraction_name{i} = wrapper_header.inputs_name{(i-1)*2+2};
        wrapper_header.inputs{(i-1)*2+2} = ...
            nasa_toLustre.lustreAst.LustreVar(...
            wrapper_header.inputs_name{(i-1)*2+2},'real');           
    end
       
    body_all = {};
    vars_all = {};
    
    % doing subscripts to index in Lustre.  Need subscripts, and
    % dimension jump.            
    [body, vars,Ast_dimJump] = ...
        nasa_toLustre.blocks.Lookup_nD_To_Lustre.addDimJumpCode(...
        blkParams); 
    body_all = [body_all  body];
    vars_all = [vars_all  vars];
    
    % preparing inputs for Interp_Using_Pre_ext_node.
    % ki in Simulink is 0 based, indices in 
    % Lustre _Interp_Using_Pre_ext_node are 1 based.  Correction
    % to ki(s) are made here.  In addition correction to ki(s) 
    % to handle Simulink convention for the setting of 
    % "use last breakpoint for input at or above upper limit".
    % note that Simulink will allow for ki input to be larger than number
    % of breakpoints, in this case, Simulink just use the highest
    % breakpoint
    bound_nodes_expression = cell(numAdjDims,2); 
    bound_nodes_for_dim_name = cell(numAdjDims,2);
    vars = cell(1,2*numAdjDims); 
    body = cell(1,2*numAdjDims); 
    for i=1:numAdjDims
        % correction for zero based (simulink inputs) to one based
        % (_Interp_Using_Pre_ext_node)
        bound_nodes_for_dim_name{i,1} = ...
            nasa_toLustre.lustreAst.VarIdExpr(sprintf(...
            'bound_node_low_dim_%d',i));
        bound_nodes_for_dim_name{i,2} = ...
            nasa_toLustre.lustreAst.VarIdExpr(sprintf(...
            'bound_node_high_dim_%d',i)); 
        vars{(i-1)*2+1} = nasa_toLustre.lustreAst.LustreVar(...
                bound_nodes_for_dim_name{i,1},'int');
        vars{(i-1)*2+2} = nasa_toLustre.lustreAst.LustreVar(...
                bound_nodes_for_dim_name{i,2},'int');             
        if strcmp(blkParams.ValidIndexMayReachLast, 'on')                        
            epsilon = ...
                nasa_toLustre.blocks.Lookup_nD_To_Lustre.calculate_eps(...
                blkParams.Table(1,1), 1);
            cond_1 =  ...            % f is 1
                nasa_toLustre.lustreAst.BinaryExpr(...
                nasa_toLustre.lustreAst.BinaryExpr.GTE, ...
                wrapper_header.inputs_name{(i-1)*2+2},nasa_toLustre.lustreAst.RealExpr(1.), [], ...
                LusBackendType.isLUSTREC(blkParams.lus_backend), epsilon);
            tableSize = size(blkParams.Table);
            curDimMaxIndex = tableSize(i) -1;
            cond_2 = nasa_toLustre.lustreAst.BinaryExpr(...
                nasa_toLustre.lustreAst.BinaryExpr.GTE, ...
                wrapper_header.inputs_name{(i-1)*2+1},...
                nasa_toLustre.lustreAst.IntExpr(curDimMaxIndex)); 
            cond = nasa_toLustre.lustreAst.BinaryExpr(...
                nasa_toLustre.lustreAst.BinaryExpr.AND,cond_1,cond_2);
            % bound node low
            then_index = nasa_toLustre.lustreAst.IntExpr(curDimMaxIndex);
            else_index = nasa_toLustre.lustreAst.BinaryExpr(...
                nasa_toLustre.lustreAst.BinaryExpr.PLUS,...
                wrapper_header.inputs_name{(i-1)*2+1},...
                nasa_toLustre.lustreAst.IntExpr(1));      
            rhs1 = nasa_toLustre.lustreAst.IteExpr(cond,...
                then_index,else_index);              
            bound_nodes_expression{i,1} = rhs1;  
            % bound node high
            then_index = nasa_toLustre.lustreAst.IntExpr(curDimMaxIndex+1);
            else_index = nasa_toLustre.lustreAst.BinaryExpr(...
                nasa_toLustre.lustreAst.BinaryExpr.PLUS,...
                wrapper_header.inputs_name{(i-1)*2+1},...
                nasa_toLustre.lustreAst.IntExpr(2));      
            rhs2 = nasa_toLustre.lustreAst.IteExpr(cond,...
                then_index,else_index);              
            bound_nodes_expression{i,2} = rhs2;  
        else                        
            bound_nodes_expression{i,1} = ...
                nasa_toLustre.lustreAst.BinaryExpr(...
                nasa_toLustre.lustreAst.BinaryExpr.PLUS,...
                wrapper_header.inputs_name{(i-1)*2+1},...
                nasa_toLustre.lustreAst.IntExpr(1));
            bound_nodes_expression{i,2} = ...
                nasa_toLustre.lustreAst.BinaryExpr(...
                nasa_toLustre.lustreAst.BinaryExpr.PLUS,...
                wrapper_header.inputs_name{(i-1)*2+1},...
                nasa_toLustre.lustreAst.IntExpr(2));
        end   

        body{(i-1)*2+1} = nasa_toLustre.lustreAst.LustreEq(...
                bound_nodes_for_dim_name{i,1},...
                bound_nodes_expression{i,1});
        body{(i-1)*2+2} = nasa_toLustre.lustreAst.LustreEq(...
                bound_nodes_for_dim_name{i,2},...
                bound_nodes_expression{i,2});            
    end
    body_all = [body_all  body];
    vars_all = [vars_all  vars];    

    if  blkParams.directLookup
        
        [body, vars] = ...
            nasa_toLustre.blocks.Lookup_nD_To_Lustre.addDirectLookupNodeCode(...
            blkParams,bound_nodes_expression,{}, {},...
            Ast_dimJump,fraction_name);        
        body_all = [body_all  body];
        vars_all = [vars_all  vars];

        bodyf{1} = nasa_toLustre.lustreAst.LustreEq(...
            wrapper_header.output_name{1}, ...
            nasa_toLustre.lustreAst.NodeCallExpr(...
            interpolationExtNode.name, ...
            blkParams.direct_sol_inline_index_VarIdExpr));
        body_all = [body_all  bodyf];
    else
        % for interpolation/extrapolation method, inputs are index and
        % weight of each bounding node
        numAdjDims = blkParams.NumberOfAdjustedTableDimensions;
        numBoundNodes = 2^blkParams.NumberOfAdjustedTableDimensions;
        
        % calculating linear shape function value for multidimensional
        % interpolation from fi of each dimension 
        shapeNodeSign = ...
            nasa_toLustre.blocks.Lookup_nD_To_Lustre.getShapeBoundingNodeSign(...
            numAdjDims);
        N_shape_node = cell(1,numBoundNodes);
        body = cell(1,numBoundNodes);
        vars = cell(1,numBoundNodes);
        
        for i=1:numBoundNodes
            N_shape_node{i} = nasa_toLustre.lustreAst.VarIdExpr(...
                sprintf('N_shape_%d',i));
            vars{i} = nasa_toLustre.lustreAst.LustreVar(...
                N_shape_node{i},'real');
            numerator_terms = cell(1,numAdjDims);
            for j=1:numAdjDims
                if shapeNodeSign(i,j)==-1
                    numerator_terms{j} = ...
                        nasa_toLustre.lustreAst.BinaryExpr(...
                        nasa_toLustre.lustreAst.BinaryExpr.MINUS,...
                        nasa_toLustre.lustreAst.RealExpr(1.),...
                        wrapper_header.inputs_name{(j-1)*2+2});   % 1-fraction
                else
                    numerator_terms{j} = ...
                        wrapper_header.inputs_name{(j-1)*2+2};   % fraction
                end
            end
            numerator = ...
                nasa_toLustre.lustreAst.BinaryExpr.BinaryMultiArgs(...
                nasa_toLustre.lustreAst.BinaryExpr.MULTIPLY,...
                numerator_terms);
            body{i} = nasa_toLustre.lustreAst.LustreEq(...
                N_shape_node{i},numerator);
        end
        body_all = [body_all  body];
        vars_all = [vars_all  vars];
        
        % define args for interpolation call
        interpolation_call_inputs_args = cell(1,2*numBoundNodes);
        for i=1:numBoundNodes
            interpolation_call_inputs_args{(i-1)*2+1} = bounding_nodes{i};
            interpolation_call_inputs_args{(i-1)*2+2} = N_shape_node{i};
        end
        
    % call interpolation
        bodyf{1} = nasa_toLustre.lustreAst.LustreEq(...
            wrapper_header.output_name{1}, ...
            nasa_toLustre.lustreAst.NodeCallExpr(...
            interpolationExtNode.name, ...
            interpolation_call_inputs_args));

        body_all = [body_all  bodyf];        
    end

    extNode = nasa_toLustre.lustreAst.LustreNode();
    extNode.setName(wrapper_header.NodeName)
    extNode.setInputs(wrapper_header.inputs);
    extNode.setOutputs( wrapper_header.output);
    extNode.setLocalVars(vars_all);
    extNode.setBodyEqs(body_all);
    extNode.setMetaInfo('external node code wrapper for doing Interpolation using PreLookup');

end


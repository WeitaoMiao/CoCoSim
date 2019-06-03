classdef PP2Utils
    %PP2Utils Summary of this class goes here
    %   Detailed explanation goes here
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
    properties
    end
    
    methods(Static)
        %% detecte if it is already pre-processed
        already_pp = isAlreadyPP(model_path)
        %%
        [Phi, Gamma] = c2d(a, b ,t)
        
        [] = replace_DTF_block(blk, U_dims_blk,num,denum )
        
        [num, status] = getTfNumerator(model,blk,numStr,ppName)
        
        [denum, status] = getTfDenum(model,blk, ppName)
        
        [failed] = replace_one_block(block,new_block)
        
        %%
        [pp_valid, pp_sim_failed, pp_failed] = validatePP(orig_model_full_path, options)
    end
    
end


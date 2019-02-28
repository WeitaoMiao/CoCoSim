function b = ignored(blk)
    % Return if the block has not a class that handle its translation.
    % e.g Inport block is trivial and does not need a code, its name is given
    % in the node signature.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % add blocks that will be ignored because they are supported
    % somehow implicitly or not important for Code generation and Verification.
    blksIgnored = {'Terminator', 'Scope', 'Display', ...
         'ResetPort',  ...
        'ToWorkspace', 'DataTypeDuplicate', ...
        'Data Type Propagation'};
    % the list of block without outputs but should be translated to
    % Lustre.
    blksWithNoOutputsButNotIgnored = {...
        'Outport',...
        'Design Verifier Assumption', ...
        'Design Verifier Proof Objective', ...
        'Assertion', ...
        'VerificationSubsystem'};
    type = blk.BlockType;
    try
        masktype = blk.MaskType;
    catch
        masktype = '';
    end
    hasNoOutpot = ...
        isfield(blk, 'CompiledPortWidths') && isempty(blk.CompiledPortWidths.Outport);
    b = ismember(type, blksIgnored) ...
        || ismember(masktype, blksIgnored)...
        || ...
        (~ismember(type, blksWithNoOutputsButNotIgnored) ...
        && ~ismember(masktype, blksWithNoOutputsButNotIgnored) ...
        && hasNoOutpot);
end


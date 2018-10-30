function [b, status, type, masktype, isIgnored] = getWriteType(sub_blk)
% getWriteType returns the handle of class corresponding to blockType/MaskType
% of the block in parameter.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

status = 0;
isIgnored = 0;
masktype = '';
sfblockType = '';
b = [];
if ~isfield(sub_blk, 'BlockType')
    status = 1;
    return;
end
type = sub_blk.BlockType;
if Block_To_Lustre.ignored(sub_blk)
    status = 1;
    isIgnored = 1;
    return;
end
if isfield(sub_blk, 'Mask') && strcmp(sub_blk.Mask, 'on')
    masktype = sub_blk.MaskType;
    fun_name = [Block_To_Lustre.blkTypeFormat(masktype) '_To_Lustre'];
    if exist(fun_name, 'file') ~= 2
        type = sub_blk.BlockType;
        fun_name = [Block_To_Lustre.blkTypeFormat(type) '_To_Lustre'];
    end
elseif isfield(sub_blk, 'SFBlockType')
    sfblockType = sub_blk.SFBlockType;
    fun_name = [Block_To_Lustre.blkTypeFormat(sfblockType) '_To_Lustre'];
    if exist(fun_name, 'file') ~= 2
        type = sub_blk.BlockType;
        fun_name = [Block_To_Lustre.blkTypeFormat(type) '_To_Lustre'];
    end
else
    type = sub_blk.BlockType;
    fun_name = [Block_To_Lustre.blkTypeFormat(type) '_To_Lustre'];
end
if exist(fun_name, 'file') ~= 2
    status = 1;
    if ~isempty(masktype)
        msg = sprintf('Block "%s" with BlockType "%s" and MaskType "%s" is not supported', sub_blk.Origin_path, type, masktype);
    elseif ~isempty(sfblockType)
        msg = sprintf('Block "%s" with BlockType "%s" and SFBlockType "%s" is not supported', sub_blk.Origin_path, type, sfblockType);
    else
        msg = sprintf('Block "%s" with BlockType "%s" is not supported', sub_blk.Origin_path, type);
    end
    display_msg(msg, MsgType.ERROR, 'getWriteType', '');
    return;
else
    h = str2func(fun_name);
    b = h();
end

end
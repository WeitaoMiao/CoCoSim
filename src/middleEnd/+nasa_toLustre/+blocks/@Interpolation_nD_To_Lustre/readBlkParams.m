function blkParams = readBlkParams(~,parent,blk,blkParams)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Trinh, Khanh V <khanh.v.trinh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Interpolation_nD_To_Lustre

    blkParams.lookupTableType = nasa_toLustre.utils.LookupType.Interpolation_nD;

    % read blk
    [blkParams.NumberOfTableDimensions, ~, ~] = ...
        nasa_toLustre.blocks.Constant_To_Lustre.getValueFromParameter(...
        parent, blk, blk.NumberOfTableDimensions);
    blkParams.RequireIndexFractionAsBus = blk.RequireIndexFractionAsBus;
        
    blkParams.tableIsInputPort = false;
    blkParams.TableSource = blk.TableSource;
    blkParams.TableSpecification = blk.TableSpecification;
    
    if strcmp(blk.TableSource, 'Dialog')
        if strcmp(blk.TableSpecification, 'Explicit values')
            % cast table data
            [T, ~, ~] = ...
                nasa_toLustre.blocks.Constant_To_Lustre.getValueFromParameter(...
                parent, blk, blk.Table);
            validDT = {'double', 'single', 'int8', 'int16', ...
                'int32', 'uint8', 'uint16', 'uint32', 'boolean'};
            if ismember(blk.CompiledPortDataTypes.Outport{1}, validDT)
                if strcmp(blk.TableDataTypeStr, 'Inherit: Same as output')
                    % don't cast if double or single and
                    % dimensions 3 and above working
                    if blkParams.NumberOfTableDimensions >=  3
                        blkParams.Table = T;
                    else
                        blkParams.Table = eval(sprintf('%s([%s])',...
                            blk.CompiledPortDataTypes.Outport{1}, mat2str(T)));
                    end
                elseif strcmp(blk.TableDataTypeStr, 'double') ...
                        || strcmp(blk.TableDataTypeStr, 'single') ...
                        || MatlabUtils.contains(blk.TableDataTypeStr, 'int')
                    blkParams.Table = eval(sprintf('%s([%s])',...
                        blk.TableDataTypeStr, mat2str(T)));
                else
                    blkParams.Table = T;
                end
            else
                blkParams.Table = T;
            end
        else % 'Lookup table object'
            
        end
    else    % Input port
        blkParams.tableIsInputPort = true;
        if strcmp(blk.TableSpecification, 'Explicit values')
            
        else  % 'Lookup table object'
            
        end
    end

    blkParams.InterpMethod = blk.InterpMethod;
    blkParams.ExtrapMethod = blk.ExtrapMethod;
    blkParams.directLookup = 0;
    if strcmp(blkParams.InterpMethod,'Flat') || strcmp(blkParams.InterpMethod,'Nearest')
        blkParams.directLookup = 1;
        blkParams.yIsBounded = 1;
    end
    if strcmp(blkParams.ExtrapMethod,'Clip')
        blkParams.yIsBounded = 1;
    end
    
    blkParams.NumSelectionDims = blk.NumSelectionDims;
    [blkParams.NumSelectionDims, ~, ~] = ...
        nasa_toLustre.blocks.Constant_To_Lustre.getValueFromParameter(...
        parent, blk, blk.NumSelectionDims);
    
    blkParams.RndMeth = blk.RndMeth;
    blkParams.SaturateOnIntegerOverflow = blk.SaturateOnIntegerOverflow;
    
    % tableMin, tableMax for contract
    blkParams.tableMin = min(blkParams.Table(:));
    blkParams.tableMax = max(blkParams.Table(:));
    
    blkParams.ValidIndexMayReachLast = blk.ValidIndexMayReachLast;
    
    % calculate dimJump and boundNodeOrder
    blkParams = ...
        nasa_toLustre.blocks.Lookup_nD_To_Lustre.addCommonData2BlkParams(...
        blkParams);    

end


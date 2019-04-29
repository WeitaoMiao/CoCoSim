classdef Inport_To_Lustre < nasa_toLustre.frontEnd.Block_To_Lustre
    %Inport_To_Lustre
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
    end
    
    methods
        
        function  write_code(obj, parent, blk, xml_trace, varargin)
            % No need for code for Inport as it is generated in the node
            % header
            
            
            %% We add assumptions on the inport values interval if it is
            % mentioned by the user in OutMin/OutMax in Inport dialog box.
            [outputs, ~] =nasa_toLustre.utils.SLX2LusUtils.getBlockOutputsNames(parent, blk);
            outputDataType = blk.CompiledPortDataTypes.Outport{1};
            lus_dt =nasa_toLustre.utils.SLX2LusUtils.get_lustre_dt(outputDataType);
            addAsAssertExpr = true;
            DEDUtils.OutMinMaxCheckCode(obj, parent, blk, outputs, lus_dt, xml_trace, addAsAssertExpr);
            
        end
        
        function options = getUnsupportedOptions(obj, parent, blk, ...
                lus_backend, coco_backend, varargin)
            
            % Outport in first level should not be of type enumeration in
            % case of Validation backend with Lustrec.
            if CoCoBackendType.isVALIDATION(coco_backend) ...
                    && LusBackendType.isLUSTREC(lus_backend) ...
                    && strcmp(parent.BlockType, 'block_diagram')
                if isempty(blk.CompiledPortDataTypes)
                    isEnum = false;
                else
                    [~, ~, ~, ~, isEnum] = ...
                       nasa_toLustre.utils.SLX2LusUtils.get_lustre_dt(blk.CompiledPortDataTypes.Outport{1});
                end
                if isEnum
                    obj.addUnsupported_options(sprintf('Inport %s with Enumeration Type %s is not supported in root level for Validation with Lustrec.', ...
                        HtmlItem.addOpenCmd(blk.Origin_path),...
                        blk.CompiledPortDataTypes.Outport{1}));
                end
            end
            options = obj.unsupported_options;
        end
        %%
        function is_Abstracted = isAbstracted(varargin)
            is_Abstracted = false;
        end
    end
    
end


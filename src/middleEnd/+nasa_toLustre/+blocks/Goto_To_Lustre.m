classdef Goto_To_Lustre < nasa_toLustre.frontEnd.Block_To_Lustre
    % Goto_To_Lustre: The Goto block passes its input to its corresponding From blocks.
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
            L = nasa_toLustre.ToLustreImport.L;
            import(L{:})
            [outputs, outputs_dt] =nasa_toLustre.utils.SLX2LusUtils.getBlockOutputsNames(parent, blk, [], xml_trace);
            inputs{1} =nasa_toLustre.utils.SLX2LusUtils.getBlockInputsNames(parent, blk, 1);
            codes = cell(1, numel(outputs));
            for i=1:numel(outputs)
                    codes{i} = LustreEq(outputs{i}, inputs{1}{i});
            end
            obj.setCode( codes );
            obj.addVariable(outputs_dt);
            
        end
        %%
        function options = getUnsupportedOptions(obj, varargin)
            options = obj.unsupported_options;
        end
        %%
        function is_Abstracted = isAbstracted(varargin)
            is_Abstracted = false;
        end
    end
    
end


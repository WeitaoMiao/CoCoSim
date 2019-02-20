classdef InitialCondition_To_Lustre < nasa_toLustre.frontEnd.Block_To_Lustre
    % InitialCondition_To_Lustre
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
            obj.addVariable(outputs_dt);
            slx_dt = blk.CompiledPortDataTypes.Outport{1};
            lus_outputDataType =nasa_toLustre.utils.SLX2LusUtils.get_lustre_dt(slx_dt);
            inputs =nasa_toLustre.utils.SLX2LusUtils.getBlockInputsNames(parent, blk);
            [Value, ~, status] = ...
                Constant_To_Lustre.getValueFromParameter(parent, blk, blk.Value);
            if status
                display_msg(sprintf('Variable %s in block %s not found neither in Matlab workspace or in Model workspace',...
                    blk.Value, HtmlItem.addOpenCmd(blk.Origin_path)), ...
                    MsgType.ERROR, 'Constant_To_Lustr', '');
                return;
            end
            %inline value
            max_width = blk.CompiledPortWidths.Outport;
            if numel(Value) < max_width
                Value = arrayfun(@(x) Value(1), (1:max_width));
            end
            % out = if t=0 then IC else in;
            codes = arrayfun(@(i) ...
                LustreEq(outputs{i}, ...
                IteExpr(...
                BinaryExpr(BinaryExpr.EQ, VarIdExpr(SLX2LusUtils.nbStepStr()), IntExpr(0)), ...
                SLX2LusUtils.num2LusExp(Value(i),lus_outputDataType, slx_dt),...
                inputs{i})), ...
                (1:numel(outputs)), 'un', 0);
            obj.setCode( codes );
            
        end
        
        function options = getUnsupportedOptions(obj, varargin)
            options = obj.unsupported_options;
        end
        %%
        function is_Abstracted = isAbstracted(varargin)
            is_Abstracted = false;
        end
    end
    
    
    
end


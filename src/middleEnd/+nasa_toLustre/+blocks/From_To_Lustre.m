classdef From_To_Lustre < nasa_toLustre.frontEnd.Block_To_Lustre
    %From_To_Lustre
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
            goToPath = find_system(parent.Origin_path,'SearchDepth',1,...
                'LookUnderMasks', 'all', 'BlockType','Goto','GotoTag',blk.GotoTag);
            if ~isempty(goToPath)
                GotoHandle = get_param(goToPath{1}, 'Handle');
            else
                display_msg(sprintf('From block %s has no GoTo', HtmlItem.addOpenCmd(blk.Origin_path)),...
                    MsgType.WARNING, 'From_To_Lustre', '');
                return;
            end
            gotoBlk = get_struct(parent, GotoHandle);
            [goto_outputs, ~] =nasa_toLustre.utils.SLX2LusUtils.getBlockOutputsNames(parent, gotoBlk);
            codes = cell(1, numel(outputs));
            for j=1:numel(outputs)
                codes{j} = LustreEq( outputs{j}, goto_outputs{j});
            end
            obj.setCode( codes );
            obj.addVariable(outputs_dt);
            
            
        end
        %%
        function options = getUnsupportedOptions(obj, parent, blk, varargin)
            goToPath = find_system(parent.Origin_path,'SearchDepth',1,...
                'LookUnderMasks', 'all', 'BlockType','Goto','GotoTag',blk.GotoTag);
            if isempty(goToPath)
                obj.addUnsupported_options(...
                    sprintf('From block %s has no GoTo', HtmlItem.addOpenCmd(blk.Origin_path)));
            end
            options = obj.unsupported_options;
            
        end
        %%
        function is_Abstracted = isAbstracted(varargin)
            is_Abstracted = false;
        end
    end
    
end


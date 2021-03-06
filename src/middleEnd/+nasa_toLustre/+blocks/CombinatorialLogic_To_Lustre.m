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
classdef CombinatorialLogic_To_Lustre < nasa_toLustre.frontEnd.Block_To_Lustre
    %CombinatorialLogic_To_Lustre

    
    properties
    end
    
    methods
        
        function  write_code(obj, parent, blk, xml_trace, ~, ~, main_sampleTime, varargin)
            
            
            
            [outputs, outputs_dt] =nasa_toLustre.utils.SLX2LusUtils.getBlockOutputsNames(parent, blk, [], xml_trace, main_sampleTime);
            outputDataType = blk.CompiledPortDataTypes.Outport{1};
            out_lus_dt = nasa_toLustre.utils.SLX2LusUtils.get_lustre_dt(outputDataType);
            obj.addVariable(outputs_dt);
            [inputs] =nasa_toLustre.utils.SLX2LusUtils.getBlockInputsNames(parent, blk);
            slx_inport_dt = blk.CompiledPortDataTypes.Inport(1);
            [lus_inport_dt] = nasa_toLustre.utils.SLX2LusUtils.get_lustre_dt(slx_inport_dt);
            
            % transform input to 1 or 0 of type int
            if ~strcmp(lus_inport_dt, 'int')
                % transfor first to bool
                [external_lib, conv_format] =nasa_toLustre.utils.SLX2LusUtils.dataType_conversion(slx_inport_dt, 'bool');
                if ~isempty(conv_format)
                    obj.addExternal_libraries(external_lib);
                    inputs = cellfun(@(x) ...
                        nasa_toLustre.utils.SLX2LusUtils.setArgInConvFormat(conv_format,x),...
                        inputs, 'un', 0);
                end
                % transform to int
                [external_lib, conv_format] =nasa_toLustre.utils.SLX2LusUtils.dataType_conversion('bool', 'int');
                if ~isempty(conv_format)
                    obj.addExternal_libraries(external_lib);
                    inputs = cellfun(@(x) ...
                        nasa_toLustre.utils.SLX2LusUtils.setArgInConvFormat(conv_format,x),...
                        inputs, 'un', 0);
                end
            end
            
            [TruthTable, ~, status] = ...
                nasa_toLustre.blocks.Constant_To_Lustre.getValueFromParameter(parent,...
                blk, blk.TruthTable);
            if status
                display_msg(sprintf('Variable %s in block %s not found neither in Matlab workspace or in Model workspace',...
                    blk.TruthTable, HtmlItem.addOpenCmd(blk.Origin_path)), ...
                    MsgType.ERROR, 'Constant_To_Lustre', '');
                return;
            end
            
            %row index = 1 + u(m)*2^0 + u(m-1)*2^1 + ... + u(1)*2^m-1
            indexVar = nasa_toLustre.lustreAst.VarIdExpr(strcat(outputs{1}.getId(), '_rowIndex'));
            obj.addVariable(nasa_toLustre.lustreAst.LustreVar(indexVar, 'int'));
            m = length(inputs);
            coeff = 2.^(m-1:-1:0);
            product_terms = arrayfun(@(i) ...
                nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.MULTIPLY, inputs{i},  nasa_toLustre.lustreAst.IntExpr(coeff(i))), (1:m), 'un', 0);
            product_terms{end+1} = nasa_toLustre.lustreAst.IntExpr(1);
            indexValue = nasa_toLustre.lustreAst.BinaryExpr.BinaryMultiArgs(nasa_toLustre.lustreAst.BinaryExpr.PLUS, product_terms);
            obj.addCode(nasa_toLustre.lustreAst.LustreEq(indexVar, indexValue));
            
            %Go over Table
            nb_rows = length(TruthTable(:,1));
            conds = arrayfun(@(i)  nasa_toLustre.lustreAst.BinaryExpr(nasa_toLustre.lustreAst.BinaryExpr.EQ, indexVar, nasa_toLustre.lustreAst.IntExpr(i)), (1:nb_rows-1), 'un', 0);
            for outIdx=1:length(outputs)
                thens = arrayfun(@(i) ...
                    nasa_toLustre.utils.SLX2LusUtils.num2LusExp(TruthTable(i, outIdx), ...
                    out_lus_dt, outputDataType), (1:nb_rows), 'un', 0);
                
                obj.addCode(nasa_toLustre.lustreAst.LustreEq(outputs{outIdx}, ...
                    nasa_toLustre.lustreAst.IteExpr.nestedIteExpr(conds, thens)));
            end
            
        end
        
        function options = getUnsupportedOptions(obj, varargin)
            % add your unsuported options list here
            options = obj.unsupported_options;
            
        end
        %%
        function is_Abstracted = isAbstracted(varargin)
            is_Abstracted = false;
        end
    end
    
end


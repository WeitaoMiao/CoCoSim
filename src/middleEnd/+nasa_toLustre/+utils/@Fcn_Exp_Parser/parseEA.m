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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tree, expr, isAssignement] = parseEA(expr)
    isAssignement = 0;
    [sym1, expr] = nasa_toLustre.utils.Fcn_Exp_Parser.parseEN(expr);

    %x++
    [match, expr] = nasa_toLustre.utils.Fcn_Exp_Parser.parsePlusPlus(expr);
    if ~isempty(match)
        %the case of x++
        tree = {'=', sym1, {'Plus',sym1, '1.0'}};
        isAssignement = 1;
        return;
    end

    %x--
    [match, expr] = nasa_toLustre.utils.Fcn_Exp_Parser.parseMinusMinus(expr);
    if ~isempty(match)
        %the case of x--
        tree = {'=', sym1, {'Minus',sym1, '1.0'}};
        isAssignement = 1;
        return;
    end

    %sym1 + sym2
    [match, expr] = nasa_toLustre.utils.Fcn_Exp_Parser.parsePlus(expr);
    if ~isempty(match)
        [sym2, expr1, isEQ] = nasa_toLustre.utils.Fcn_Exp_Parser.parseEA(expr);
        if isEQ
            ME = MException('COCOSIM:Fcn_Exp_Parser', ...
                'PARSER ERROR: Assignement is not supported inside an expression in "%s"', ...
                expr);
            throw(ME);
        end
        expr = expr1;
        if ~isempty(sym1)
            tree = {'Plus',sym1,sym2};
        else
            tree = {'Plus','0.0',sym2};
        end
        return;
    end

    %sym1 - sym2
    [match, expr] = nasa_toLustre.utils.Fcn_Exp_Parser.parseMinus(expr);
    if ~isempty(match)
        [sym2, expr1, isEQ] = nasa_toLustre.utils.Fcn_Exp_Parser.parseEA(expr);
        if isEQ
            ME = MException('COCOSIM:Fcn_Exp_Parser', ...
                'PARSER ERROR: Assignement is not supported inside an expression in "%s"', ...
                expr);
            throw(ME);
        end
        expr = expr1;
        if ~isempty(sym1)
            tree = {'Minus',sym1,sym2};
        else
            tree = {'Minus','0.0',sym2};
        end
        return;
    end

    % > < <= >=, == !=, && ||
    [match, expr] = nasa_toLustre.utils.Fcn_Exp_Parser.parseRO(expr);
    if ~isempty(match)
        [sym2, expr1, isEQ] = nasa_toLustre.utils.Fcn_Exp_Parser.parseEA(expr);
        if isEQ
            ME = MException('COCOSIM:Fcn_Exp_Parser', ...
                'PARSER ERROR: Assignement is not supported inside an expression in "%s"', ...
                expr);
            throw(ME);
        end
        expr = expr1;
        tree = {match,sym1,sym2};
        return;
    end

    % sym1 = sym2
    [match, expr] = nasa_toLustre.utils.Fcn_Exp_Parser.parseEQ(expr);
    if ~isempty(match)
        [sym2, expr1, isEQ] = nasa_toLustre.utils.Fcn_Exp_Parser.parseEA(expr);
        if isEQ
            ME = MException('COCOSIM:Fcn_Exp_Parser', ...
                'PARSER ERROR: Assignement is not supported inside an expression in "%s"', ...
                expr);
            throw(ME);
        end
        expr = expr1;
        tree = {match,sym1,sym2};
        return;
    end

    % return sym1
    tree = sym1;

end

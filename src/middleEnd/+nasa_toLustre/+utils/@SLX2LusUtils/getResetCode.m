
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [resetCode, status] = getResetCode(...
        resetType, resetDT, resetInput, zero )
    L = nasa_toLustre.ToLustreImport.L;
    import(L{:})
    status = 0;
    if strcmp(resetDT, 'bool')
        b = resetInput;
    else
        %b = sprintf('(%s > %s)',resetInput , zero);
        b = BinaryExpr(BinaryExpr.GT, resetInput, zero);
    end
    if strcmpi(resetType, 'rising')
        resetCode = ...
            BinaryExpr(BinaryExpr.ARROW, ...
                       BooleanExpr('false'),...
                       BinaryExpr(BinaryExpr.AND,...
                                  b, ...
                                  UnaryExpr(UnaryExpr.NOT, ...
                                            UnaryExpr(UnaryExpr.PRE, b)...
                                            )...
                                 )...
                      );
                  %                 resetCode = sprintf(...
                  %                     'false -> (%s and not pre %s)'...
                  %                     ,b ,b );

    elseif strcmpi(resetType, 'falling')
        %resetCode = sprintf(...
        %    'false -> (not %s and pre %s)'...
        %    ,b ,b);
        resetCode = ...
            BinaryExpr(BinaryExpr.ARROW, ...
                       BooleanExpr('false'),...
                       BinaryExpr(BinaryExpr.AND,...
                                  UnaryExpr(UnaryExpr.NOT, b), ...
                                  UnaryExpr(UnaryExpr.PRE, b)...
                                 )...
                      );
    elseif strcmpi(resetType, 'either')
        %                 resetCode = sprintf(...
        %                     'false -> ((%s and not pre %s) or (not %s and pre %s)) '...
        %                     ,b ,b ,b ,b);
        resetCode = ...
            BinaryExpr(BinaryExpr.ARROW, ...
                       BooleanExpr('false'),...
                       BinaryExpr(BinaryExpr.OR,...
                                  BinaryExpr(BinaryExpr.AND,...
                                              b, ...
                                              UnaryExpr(UnaryExpr.NOT, ...
                                                        UnaryExpr(UnaryExpr.PRE, b)...
                                                        )...
                                             ),...
                                  BinaryExpr(BinaryExpr.AND,...
                                              UnaryExpr(UnaryExpr.NOT, b), ...
                                              UnaryExpr(UnaryExpr.PRE, b)...
                                             )...
                                  )...
                      );
    elseif strcmpi(resetType, 'level')

        if strcmp(resetDT, 'bool')
            b = resetInput;
        else
            %b = sprintf('(%s <> %s)',resetInput , zero);
            b = BinaryExpr(BinaryExpr.NEQ, resetInput, zero);
        end
        % Reset in either of these cases:
        % when the reset signal is nonzero at the current time step
        % when the reset signal value changes from nonzero at the previous time step to zero at the current time step
        %                 resetCode = sprintf(...
        %                     'false -> (%s or (pre %s and not %s)) '...
        %                     ,b ,b ,b);
        resetCode = ...
            BinaryExpr(BinaryExpr.ARROW, ...
                       BooleanExpr('false'),...
                       BinaryExpr(BinaryExpr.OR,...
                                  b,...
                                  BinaryExpr(BinaryExpr.AND,...
                                            UnaryExpr(UnaryExpr.PRE, b),...
                                            UnaryExpr(UnaryExpr.NOT, b) ...
                                            )...
                                  )... 
                      );
    elseif strcmpi(resetType, 'level hold')

        if strcmp(resetDT, 'bool')
            b = resetInput;
        else
            %b = sprintf('(%s <> %s)',resetInput , zero);
            b = BinaryExpr(BinaryExpr.NEQ, resetInput, zero);
        end
        %Reset when the reset signal is nonzero at the current time step
        %                 resetCode = sprintf(...
        %                     'false -> b);
        resetCode = ...
            BinaryExpr(BinaryExpr.ARROW, ...
                       BooleanExpr('false'),...
                       b);              

    else
        resetCode = VarIdExpr('');
        status = 1;
        return;
    end
end

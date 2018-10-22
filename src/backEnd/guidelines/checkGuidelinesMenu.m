%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function schema = checkGuidelinesMenu(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'Check model against guidelines';
    schema.statustip = 'Check model against guidelines ';
    schema.autoDisableWhen = 'Busy';
    
    schema.callback = @checkGuidelinesCallback;
end

function checkGuidelinesCallback(callbackInfo)
    model_full_path = MenuUtils.get_file_name(gcs);    
    check_guidelines(model_full_path);
end
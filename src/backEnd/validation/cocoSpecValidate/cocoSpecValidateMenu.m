function schema = cocoSpecValidateMenu(callbackInfo)
schema = sl_container_schema;
schema.label = 'CoCoSpec compiler using ...';
schema.statustip = 'Validate CoCoSpec compiler';
schema.autoDisableWhen = 'Busy';

schema.childrenFcns = {@Validate1};%, @Validate2, @Validate3};
end

function schema = Validate1(callbackInfo)
schema = sl_action_schema;
schema.label = 'Validation by random tests';
schema.callback = @V1Callback;
end

function V1Callback(callbackInfo)
clear;
msgbox('Coming soon');
end
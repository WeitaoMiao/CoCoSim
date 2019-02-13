%% copy all required functions in one script
function [script, failed] = getAllRequiredFunctionsInOneScript(blk)
    L = nasa_toLustre.ToLustreImport.L;
    import(L{:})
    failed = false;
    script = blk.Script;
    blk_name = SLX2LusUtils.node_name_format(blk);
    func_path = fullfile(pwd, strcat(blk_name, '.m'));
    fid = fopen(func_path, 'w');
    if fid < 0
        display_msg(sprintf('Could not open file "%s" for writing', func_path), ...
            MsgType.DEBUG, 'getMFunctionCode', '');
        failed = true;
        return;
    end
    fprintf(fid, script);
    fclose(fid);
    fList = matlab.codetools.requiredFilesAndProducts(func_path);
    if numel(fList) > 1
        for i=2:length(fList)
            script = sprintf('%s\n%s', script, fileread(fList{i}));
        end
    end

    try delete(func_path), catch, end
end
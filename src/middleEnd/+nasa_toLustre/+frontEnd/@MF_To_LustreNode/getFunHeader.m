function [fun_node] = getFunHeader(func, blk, data_map)
    L = nasa_toLustre.ToLustreImport.L;
    import(L{:})
    
    data_set = data_map.values();
    scopes = cellfun(@(x) x.Scope, data_set, 'UniformOutput', 0);
    Inputs = data_set(strcmp(scopes, 'Input'));
    Outputs = data_set(strcmp(scopes, 'Output'));
    node_inputs = SF2LusUtils.getDataVars(...
        SF2LusUtils.orderObjects(Inputs, 'Port'));
    node_outputs = SF2LusUtils.getDataVars(...
        SF2LusUtils.orderObjects(Outputs, 'Port'));
    blk_name = SLX2LusUtils.node_name_format(blk);
    comment = LustreComment(...
        sprintf('Function %s inside Matlab Function block: %s',func.name, blk.Origin_path), true);
    node_name = strcat(blk_name, '_', func.name);
    fun_node = LustreNode(...
        comment, ...
        node_name,...
        node_inputs, ...
        node_outputs, ...
        {}, ...
        {}, ...
        {}, ...
        false);
end


function [node, external_nodes_i, opens, abstractedNodes] = get_int_to_int8_saturate(varargin)
    [node, external_nodes_i, opens, abstractedNodes] = nasa_toLustre.utils.LustDTLib.getIntToIntSaturate('int8');
end
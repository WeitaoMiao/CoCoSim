classdef ImportLusUtils
    %IMPORTLUSUTILS Summary of this class goes here
    %   Detailed explanation goes here
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright (c) 2017 United States Government as represented by the
    % Administrator of the National Aeronautics and Space Administration.
    % All Rights Reserved.
    % Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties

    end
    
    methods(Static)
        
        %new_model_path = importLustreSpec(model_path, contract_path)
        % Inputs:
        % model_path : the path of Simulink model
        % lus_json_path : the Json that contains the lustre represenation
        % generated by Lustrec.
        % Outputs:
        % new_model_path: the path of the new Simulink model that has the 
        % Spec of the associated model.
        
        [new_model_path, status] = importLustreSpec(...
                model_path,...
                lus_json_path,...
                cocosim_trace_file, ...
                createNewFile)     
        %%
        input_block_name = get_input_block_name_from_variable(xRoot, node, var_name, Sim_file_name,new_model_name)
               
        %%
        link_block_with_its_cocospec( cocospec_bloc_path, input_block_name, simulink_block_name, parent_block_name, index, isBaseName)
    
        set_mask_parameters(observer_path)

        %% Returns the Display parameter value for the Observer block
        [display] = get_observer_display()

        [desc] = get_obs_description()

        %% Retrieve the Callback parameter value
        [call] = get_obs_callback()

    end
end


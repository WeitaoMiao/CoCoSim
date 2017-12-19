function [new_ir, status] = stateflow_IR_pp(old_ir, print_in_file, output_dir)
% stateflow_IR_pp pre-process internal representation of stateflow. For
% example change Simulink datatypes (int32, ...) to lustre datatypes (int,
% real, bool).
% This function call SFIR_PP_config to choose which functions to call and
% in which order
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
status = 0;
if nargin < 2 || isempty(output_dir)
    output_dir = pwd;
end
MatlabUtils.mkdir(output_dir);
if nargin < 3 || isempty(print_in_file)
    print_in_file = 0;
end

if nargin ==0 || isempty(old_ir)
    display_msg('please provide Stateflow IR while calling stateflow_IR_pp',...
        MsgType.ERROR, 'stateflow_IR_pp', '');
    return;
elseif ischar(old_ir);
    % extract IR first.
    new_ir =  stateflow_IR( old_ir , print_in_file, output_dir);
elseif ~isa(old_ir, 'Program')
    display_msg('please provide Stateflow IR while calling stateflow_IR_pp',...
        MsgType.ERROR, 'stateflow_IR_pp', '');
    return;
else
    new_ir = old_ir;
end


%% Order functions
global ordered_sfIR_pp_functions;
if isempty(ordered_sfIR_pp_functions)
    SFIR_PP_config;
end

% transform Program to struct
new_ir = SFIRUtils.objToStruct(new_ir);
%% sort functions calls
oldDir = pwd;
for i=1:numel(ordered_sfIR_pp_functions)
    [dirname, func_name, ~] = fileparts(ordered_sfIR_pp_functions{i});
    cd(dirname);
    fh = str2func(func_name);
    try
        display_msg(['runing ' func2str(fh)], MsgType.INFO, 'Stateflow_IRPP', '');
        [new_ir, status] = fh(new_ir);
        if status
            
             display_msg('Stateflow_IR_PP has been interrupted', MsgType.ERROR, 'Stateflow_IRPP', '');
             cd(oldDir);
             return;
        end
    catch me
        display_msg(['can not run ' func2str(fh)], MsgType.ERROR, 'Stateflow_IRPP', '');
        display_msg(me.getReport(), MsgType.DEBUG, 'Stateflow_IRPP', '');
    end
    
end
cd(oldDir);
%%  Exporting the IR

if print_in_file
    try
        json_text = json_encode(new_ir);
        json_text = regexprep(json_text, '\\/','/');
        fname = fullfile(output_dir, strcat(SFIRPPUtils.adapt_root_name(new_ir.name),'_SFIR_pp_tmp.json'));
        fname_formatted = fullfile(output_dir, strcat(SFIRPPUtils.adapt_root_name(new_ir.name),'_SFIR_pp.json'));
        fid = fopen(fname, 'w');
        if fid==-1
            display_msg(['Couldn''t create file ' fname], MsgType.ERROR, 'Stateflow_IRPP', '');
        else
            fprintf(fid,'%s\n',json_text);
            fclose(fid);
            cmd = ['cat ' fname ' | python -mjson.tool > ' fname_formatted];
            try
                [status, output] = system(cmd);
                if status~=0
                    display_msg(['file is not formatted ' output], MsgType.ERROR, 'Stateflow_IRPP', '');
                    fname_formatted = fname;
                end
            catch
                fname_formatted = fname;
            end
            display_msg(['IR has been written in ' fname_formatted], MsgType.RESULT, 'Stateflow_IRPP', '');
        end
    catch ME
        display_msg(['Couldn''t export Stateflow to IR'], MsgType.WARNING, 'Stateflow_IRPP', '');
        display_msg(ME.getReport(), MsgType.DEBUG, 'Stateflow_IRPP', '');
    end
end


display_msg('Done with the pre-processing', MsgType.INFO, 'Stateflow_IRPP', '');
end
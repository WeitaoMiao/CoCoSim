%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% Author: Hamza Bourbouh <hamza.bourbouh@nasa.gov>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function start_cocosim(  )
%START_COCOSIM starts cocosim and configure the tools needed by CoCoSim in
%Matlab workspace.

disp('**********************************')
disp('  WELCOME TO COCOSIM (NASA Ames)  ')
disp('**********************************')
disp('... Starting cocoSim configuration')
cocosim_config;
sl_refresh_customizations;
disp('... Configuration is Done');
[cocoSim_root, ~, ~] = fileparts(mfilename('fullpath'));
example_path = fullfile(cocoSim_root, 'examples', 'contract', 'absolute.slx');
fprintf('\n\t Click <a href="matlab: open %s">here</a> to start with a simple verification example.\n', example_path);
end


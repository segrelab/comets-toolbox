function comets_output = runCometsOnDirectory(run_COMETS_folder)
%run_COMETS Run COMETS without a GUI from MATLAB
%
%comets_output = run_COMETS(run_COMETS_folder)
%
%REQUIRED INPUTS
% run_COMETS_folder: Path to folder that contains:
%	 global_params.txt
%    package_params.txt
%    comets_script.txt
%    COMETS layout (e.g. Ecoli_colony_layout.txt)
%    COMETS models (e.g. EC_ijo1366_model.txt)
%
%OUTPUT
% comets_output: COMETS output to screen
%
% Meghan Thommes 02/29/2016

%% Add COMETS Java Classpath to MATLAB
[path_status,comets_path] = system('echo %COMETS_HOME%'); % determine COMETS path
comets_path = strtrim(comets_path); % remove leading and trailing white space
if path_status ~= 0 || ~isdir(comets_path) % command 'echo %COMETS_HOME%' unsuccessful
    error('COMETS_HOME environmental variable not set')
end
javaclasspath(comets_path); % add COMETS classpath to MATLAB

%% Set up Working Directory with COMETS Files
scr_status = copyfile([comets_path '\comets_w64_scr.bat'],[run_COMETS_folder '\comets_w64_scr.bat']);
if scr_status == 0
    if ~isdir(run_COMETS_folder) % working directory does not exist
        error('working directory does not exist')
    elseif exist([comets_path '\comets_w64_scr.bat'],'file') ~= 2 % script bat file not found
        error('comets_w64_scr.bat not found in COMETS path')
    end
end
cd(run_COMETS_folder) % change to working directory

%% Run COMETS Script
[status,comets_output] = system('comets_w64_scr.bat'); % run COMETS script
delete([run_COMETS_folder '\comets_w64_scr.bat']); % remove script bat file from folder

end
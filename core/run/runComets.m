function cometsOutput = runComets( layout, directory )
%RUNCOMETS create the files necessary for a COMETS run, and execute it from
%the command line. If a directory name is provided it will be created,
%otherwise files will be placed in the current directory
currentdir = pwd;
if nargin < 2
    directory = pwd;
end
if ~exist(directory)
    mkdir(directory);
end
cd(directory);

createCometsFiles(layout,pwd);%create layout,model,script & param files

disp(['Executing COMETS in the directory ' pwd]);
cometsOutput = runCometsOnDirectory(pwd);%run

%return to initial directory
cd(currentdir);

end


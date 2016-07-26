function runComets( layout, directory )
%RUNCOMETS create the files necessary for a COMETS run, and execute it from
%the command line. If a directory name is provided it will be created,
%otherwise files will be placed in the current directory

if nargin < 2
    directory = pwd;
end
if ~exist(directory)
    mkdir(directory);
end
cd(directory);

writeCometsLayout(layout,pwd);%create layout & model files
createCometsFiles(layout,pwd);%create script & param files

runCometsOnDirectory(pwd);%run

end


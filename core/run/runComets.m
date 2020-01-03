function cometsOutput = runComets( layout, directory )
%RUNCOMETS create the files necessary for a COMETS run, and execute it from
%the command line. If a directory name is provided it will be created,
%otherwise files will be placed in the current directory
currentdir = pwd;
if nargin < 2
    directory = pwd;
end
if ~exist(directory,'dir')
    mkdir(directory);
end
cd(directory);

createCometsFiles(layout,pwd);%create layout,model,script & param files

%clear out files with name conflicts for the output files
%this should help avoid issues where a silently failed run results in 
%scripts loading old results
logfilenames = {};
if layout.params.writeMediaLog
    logfilenames = [logfilenames layout.params.mediaLogName];
end
if layout.params.writeBiomassLog
    logfilenames = [logfilenames layout.params.biomassLogName];
end
if layout.params.writeTotalBiomassLog
    logfilenames = [logfilenames layout.params.totalBiomassLogName];
end
if layout.params.writeFluxLog
    logfilenames = [logfilenames layout.params.fluxLogName];
end
for i = 1:length(logfilenames)
    n = logfilenames{i};
    if exist(n,'file')
        disp(['Log file ' n ' already exists! Deleting it before COMETS execution...']);
        delete(n);
    end
end     

disp(['Executing COMETS in the directory ' pwd]);
cometsOutput = runCometsOnDirectory(pwd);%run

%return to initial directory
cd(currentdir);

end


function comets_output = runCometsOnDirectory(run_COMETS_folder)
%run_COMETS Run COMETS without a GUI from MATLAB
%
%comets_output = run_COMETS(run_COMETS_folder)
%
%REQUIRED INPUTS
% run_COMETS_folder: Path to folder that contains:
%    comets_script.txt
%    COMETS layout (e.g. Ecoli_colony_layout.txt)
%    COMETS models (e.g. EC_ijo1366_model.txt)
%
%OUTPUT
% comets_output: COMETS output to screen
%
% Meghan Thommes 02/29/2016
%
% Update 3 Jan 2017, mquintin:
%   -If a file named comets_w64_scr.bat already exists in the run folder,
%    use it instead of the one in COMETS_HOME
%   -If no copy of comets_w64_scr.bat can be found, create a new one.
%   -If multiple versions of comets*.jar exist, use the most recent one
%
% TODO: Update this to not rely on .bat files, so it works on Linux

%% Add COMETS Java Classpath to MATLAB
cometshome = getenv('COMETS_HOME');
if isempty(cometshome)
   error('COMETS_HOME environmental variable not set')
end
javaclasspath(cometshome); % add COMETS classpath to MATLAB
    

%% Set up Working Directory with COMETS Files
tempscript = 0; %we delete the script after running if it's copied from COMETS_HOME

execfile = 'comets_w64_scr.sh';
if ispc
    execfile = 'comets_w64_scr.bat';
end

if exist([run_COMETS_folder filesep execfile],'file') ~= 2 % script bat file not in current folder
    %get it from comets_path
    scr_status = copyfile([cometshome filesep execfile],[run_COMETS_folder filesep execfile]);
    if scr_status == 0 %unable to copy
        if ~isdir(run_COMETS_folder) % working directory does not exist
            error('working directory does not exist')
        elseif exist([run_COMETS_folder filesep execfile],'file') ~= 2 % script bat file not found
            %error('comets_w64_scr.bat not found in COMETS path')
            warning([execfile ' not found in %s or in %s. Creating new file...'],run_COMETS_folder,cometshome)
            
            %get the name of the most recently created COMETS jar file in COMETS_HOME
            jars = [dir([cometshome filesep 'comets*.jar']); dir([cometshome filesep 'bin' filesep 'comets*.jar'])];
            [tmp, idx] = sort(datetime({jars.date}));
            jarname = jars(idx(length(idx))).name;
                
            fileid = fopen([run_COMETS_folder filesep execfile],'w');
            %fprintf(fileid,'%s%s%s',['java -Xmx2048m -classpath ' cometshome '//'],jarname,[';C:/Users/mquintin/workspace/lib/jmatio.jar;' cometshome '/lib/jmatio.jar;' cometshome '/lib/x64/glpk-java.jar;' cometshome '/lib/jogamp-all-platforms/jar/jogl-all.jar;' cometshome '/lib/jogamp-all-platforms/jar/gluegen.jar;' cometshome '/lib/jogamp-all-platforms/jar/gluegen-rt.jar;' cometshome '/lib/jogamp-all-platforms/jar/gluegen-rt-natives-windows-amd64.jar;' cometshome '/lib/jogamp-all-platforms/jar/jogl-all-natives-windows-amd64.jar;%GUROBI_HOME%/lib/gurobi.jar -Djava.library.path=' cometshome '/lib;' cometshome '/lib/x64;%GUROBI_HOME%;%GUROBI_HOME%/lib/;%GUROBI_HOME%/bin edu.bu.segrelab.comets.Comets -loader edu.bu.segrelab.comets.fba.FBACometsLoader -script comets_script.txt']);
            execstr = ['java -Xmx2048m -classpath %COMETS_HOME%/' jarname ';%COMETS_HOME%/bin/' jarname ';%COMETS_HOME%/lib/glpk-java.jar;%COMETS_HOME%/lib/jogamp-all-platforms/jar/jogl-all.jar;%COMETS_HOME%/lib/jogamp-all-platforms/jar/gluegen.jar;%COMETS_HOME%/lib/jogamp-all-platforms/jar/gluegen-rt.jar;%COMETS_HOME%/lib/jogamp-all-platforms/jar/gluegen-rt-natives-windows-amd64.jar;%COMETS_HOME%/lib/jogamp-all-platforms/jar/jogl-all-natives-windows-amd64.jar;%COMETS_HOME%/lib/jmatio.jar;%COMETS_HOME%/lib/jamtio.jar;%GUROBI_HOME%/lib/gurobi.jar -Djava.library.path=%COMETS_HOME%/;%COMETS_HOME%/lib/;%GUROBI_HOME%/lib/;%GUROBI_HOME%/bin edu.bu.segrelab.comets.Comets -loader edu.bu.segrelab.comets.fba.FBACometsLoader -script comets_script.txt'];
            fprintf(fileid,'%s%s%s',execstr);
            fclose(fileid);
        end
    else
        tempscript = 1;
    end
end
cd(run_COMETS_folder) % change to working directory

%% Run COMETS Script
[status,comets_output] = system(execfile); % run COMETS script
if tempscript
    delete([run_COMETS_folder filesep execfile]); % remove script bat file from folder
end

end
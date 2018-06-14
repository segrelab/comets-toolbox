function tab = parseFluxLog( logFilePath )
%PARSEFLUXLOG load the Comets flux log at the given path into a Table
%
% $Author: mquintin $	$Date: 3/24/2017 $	$Revision: 0.1 $
% Last edit: mquintin 3/24/2017
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2017

if nargin < 1
    logFilePath = 'log_flux.m';
end

s = strsplit(logFilePath,'.');
if strcmpi(s{end},'m') %MATLAB script
    %Dimensions of the fluxes struct are {Timestep}, {X}, {Y}, {Model}, (Rxn)
    varnames = {'t' 'x' 'y' 'model' 'rxn' 'flux'};
    tab = table();
    
    
    %The log is a script that loads a struct named "fluxes"
    run(logFilePath)
    if ~exist('fluxes','var')
        error(['Failed to load the log file ' logFilePath]);
    end
    
    %this is probably super inefficient...
    for t=1:length(fluxes)
        for x = 1:length(fluxes{t})
            for y = 1:length(fluxes{t}{x})
                for m = 1:length(fluxes{t}{x}{y})
                    for r = 1:length(fluxes{t}{x}{y}{m})
                        f = fluxes{t}{x}{y}{m}(r);
                        tab = [tab; {t, x, y, m, r, f}];
                    end
                end
            end
        end
    end
    tab.Properties.VariableNames = varnames;

    
else %COMETS format:
        %timestep\n
        %x y speciesnum1 flux1 flux2 .... fluxn \n
        %x y speciesnum2 flux1 flux2
    
    %first, find out how many timesteps there are
    nsteps = 0;
    fid1 = fopen(logFilePath,'r'); % open csv file for reading
    numfluxes = 0;
    xmax = 0;
    ymax = 0;
    nspecies = 0;
    while ~feof(fid1)
        line = fgets(fid1); %# read line by line
        splitline = strsplit(strtrim(line));
        if length(splitline) == 1 %line denotes the timestep
            nsteps = nsteps + 1;
            numfluxes = 0;
        else
            if nsteps < 2 %these should always be the same, so we only need
                          %to check them once
                numfluxes = numfluxes + length(splitline) - 3;
                xmax = max(xmax, str2num(splitline{1}));
                ymax = max(ymax, str2num(splitline{2}));
                nspecies = max(nspecies, str2num(splitline{3}));
            end
        end
    end
    fclose(fid1);
    
    %initialize the table
    varnames = {'t' 'x' 'y' 'model' 'rxn' 'flux'};
    nrows = nsteps * xmax * ymax * numfluxes;
    tab = table();
    tab.t = zeros(nrows,1);
    tab.x = zeros(nrows,1);
    tab.y = zeros(nrows,1);
    tab.model = zeros(nrows,1);
    tab.rxn = zeros(nrows,1);
    tab.flux = zeros(nrows,1);
    
    currow = 1;
    curtime = 0;
    fid2 = fopen(logFilePath,'r'); % open csv file for reading
    while ~feof(fid2)
        line = fgets(fid2); %# read line by line
        splitline = strsplit(strtrim(line));
        if length(splitline) == 1 %line denotes the timestep
            curtime = str2num(splitline{1});
        elseif length(splitline) > 1 %line is a list of fluxes
            x = str2num(splitline{1});
            y = str2num(splitline{2});
            m = str2num(splitline{3});
            f = str2double(splitline(4:end));
            len = length(f);
            
            tab.t(currow:currow+len-1) = curtime;
            tab.x(currow:currow+len-1) = x;
            tab.y(currow:currow+len-1) = y;
            tab.model(currow:currow+len-1) = m;
            
            tab.rxn(currow:currow+len-1) = (1:len);
            tab.flux(currow:currow+len-1) = f;
            
            currow = currow + len;
        end
    end
    fclose(fid2);
end
    
    
end
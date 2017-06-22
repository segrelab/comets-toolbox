function tab = parseFluxLog( logFilePath )
%PARSEFLUXLOG load the Comets flux log at the given path into a Table
%
% $Author: mquintin $	$Date: 3/24/2017 $	$Revision: 0.1 $
% Last edit: mquintin 3/24/2017
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2017

if nargin < 1
    logFilePath = 'log_flux.m';
end

%The log is a script that loads a struct named "fluxes"
run(logFilePath)
if ~exist('fluxes','var')
    error(['Failed to load the log file ' logFilePath]);
end

%Dimensions of the fluxes struct are {Timestep}, {X}, {Y}, {Model}, (Rxn)
varnames = {'t' 'x' 'y' 'model' 'rxn' 'flux'};
tab = table();

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

end


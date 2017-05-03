function tab = parseMediaLog(logFilePath)
% PARSEMEDIALOG load the Comets media log at the given path into a Table
%
% $Author: mquintin $	$Date: 3/24/2017 $	$Revision: 0.1 $
% Last edit: mquintin 3/24/2017
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2017

if nargin < 1
    logFilePath = 'log_media.m';
end

if ~exist(logFilePath,'file')
    error(['Could not find the log file ' logFilePath]);
end

tab = table();

if exist(logFilePath,'file') %the log file exists
    clear -regexp ^media_\d+$;

    %The log file creates a series of objects called media_T, where T is
    %the timestep.
    %Names start at media_0 for the first step
    run(logFilePath);
        
    objs = whos;
    mnames = {objs.name};
    
    for i = 1:length(mnames)
        mname = mnames{i};
        if regexp(mname,'^media_\d+$')
            splitstr = regexp(mname,'_','split');
            cycle = str2num(splitstr{2}) + 1; %logs start at media_0
            m = eval(mname);
            m = full([m{1:end}]);
            %media(cycle,1:length(m)) = m;
                        
            for j = 1:length(m)
                tab = [tab; {cycle, j, m(j)}];
            end
            
        end
    end
    
    clear -regexp ^media_\d+$;
end

tab.Properties.VariableNames = {'t' 'met' 'amt'};
tab = sortrows(tab,'t');

end
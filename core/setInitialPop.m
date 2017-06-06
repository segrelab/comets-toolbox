function layout = setInitialPop(layout, format, pop, resize)
%SETINITIALPOP Automatically generates initial population placements for
%the models in a given Layout.
% 
% [Layout] = SETINITIALPOP(Layout, [string])
%   layout : a CometsLayout object
%   format : optional string denoting the layout scheme to use. default
%   'colonies'
%   [pop] : optional array of doubles denoting population of each model.
%   default 10^-5. Units = grams.
%   resize : is the script allowed to resize the layout? default true
%
%   The format string should be one of ['1x1' 'colonies'] 
% 
% Examples: 
% 
% Provide sample usage code here
% 
% See also: List related files here

% $Author: mquintin $	$Date: 2016/08/26 16:08:10 $	$Revision: 0.1 $
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016

if nargin < 2
    format = 'colonies';
end

%allow calling the format with a number
formatstrs = {'1x1' 'colonies'};
if (isnumeric(format) && (format > 0) && (format <= length(formatstrs)))
    format = formatstrs{format};
end

nmodels = length(layout.models);
if nmodels < 1
    error('No models included in the given layout.');
end

%set size of colonies within populated grid cells
dpop = 1e-9; %default population value
if nargin < 3
    pop = [];
end
while length(pop) < nmodels
    pop = [pop dpop];
end

if nargin < 4
    resize = true;
end


%build depending on the format
%remember Layout.initiapop has dimensions: nmodels by x by y
newpop = [];
switch lower(format)
    case '1x1' %all organisms in a single grid cell
        if nmodels > 1
            layout.params.allowCellOverlap = true;
        end
        if resize
            layout = resizeLayout(layout,1,1);
        end
        x = layout.xdim;
        y = layout.ydim;
        for i=1:nmodels
            newpop(i,ceil(x/2),ceil(y/2)) = pop(i);
        end        
    case 'colonies' %spatially separated initial populations
        if resize
            layout = resizeLayout(layout,100,100);
        end
        x = layout.xdim;
        y = layout.ydim;
        switch nmodels
            case 1
                newpop(1,ceil(x/2),ceil(y/2)) = pop(1); %centered
            case 2
                newpop(1,ceil(x/3),ceil(y/2)) = pop(1); %left-center
                newpop(2,ceil(2*x/3),ceil(y/2)) = pop(2); %right-center
            case 3
                newpop(1,ceil(x/2),ceil(y/3)) = pop(1); %center-top
                newpop(2,ceil(x/3),ceil(2*y/3)) = pop(2); %left-bottom
                newpop(3,ceil(2*x/3),ceil(2*y/3)) = pop(3); %right-bottom
            case 4
                newpop(1,ceil(x/3),ceil(y/3)) = pop(1); %left-top
                newpop(2,ceil(2*x/3),ceil(y/3)) = pop(2); %right-top
                newpop(3,ceil(x/3),ceil(2*y/3)) = pop(3); %left-bottom
                newpop(4,ceil(2*x/3),ceil(2*y/3)) = pop(4); %right-bottom
            otherwise
                error(['setInitialPop is currently capable of handling '...
                    'only up to four models in a ''colonies'' layout.']);
        end
    otherwise
        error(['The format in the second argument of setInitialPop '...
            'should be one of: ' formatstrs]);
end
layout.initial_pop = newpop;

end

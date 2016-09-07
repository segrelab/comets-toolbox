function [idx] = stridx(varargin)
%STRIDX(str, {str}, [allowSubstr]) Get the indexes of the query string in the given cell array.
% 
% If the third argument is set to 'false', only exact matches at the start 
% of the cell will be returned. Otherwise the query is case-insensitive and
% searches for the query string as a substring of the contents of the cell
% 
% Examples: 
% stridx('a', {'a' 'ba' 'BA'}) == [1 2 3]
% stridx('a', {'a' 'ba' 'BA'}, false) == [1]
% 

% $Author: mquintin $	$Date: 2016/09/02 13:42:57 $	$Revision: 0.1 $
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016

q = varargin{1};
arr = varargin{2};
caseopt = 'ignorecase';
matchstart = false;
if nargin > 2 
    matchstart = ~varargin{3};
end   
if matchstart
    caseopt = 'matchcase';
end

posn = regexp(arr,q,caseopt,'once');

if matchstart
    %this may look awkward, but one-line solutions tend to break on empty
    %cells
    posn = cellfun(@(x) any(x(:)==1),posn,'UniformOutput',false);
    idx = find([posn{:}]);
else
    idx = find(~cellfun('isempty',posn));
end
end

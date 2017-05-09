function [idx] = stridx(query, list, allowSubstr)
%STRIDX(str, {str}, [true]) Get the indexes of the query string in the given cell array.
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

if ~exist('allowSubstr','var') || isempty(allowSubstr) || allowSubstr
    caseopt = 'ignorecase';
    matchstart = false;
else
    matchstart = true;
    caseopt = 'matchcase';
end

if iscell(query)
    if length(query)==1
        query = query{1};
    else
        error('The query argument to stridx() should be a char array');
    end
end

q = regexptranslate('escape',query); %treat the string as literal
posn = regexp(list,q,caseopt,'once');

if matchstart %not substring
    %this may look awkward, but one-line solutions tend to break on empty
    %cells
    posn = cellfun(@(x) any(x(:)==1),posn,'UniformOutput',false);
    idx = find([posn{:}]);
    
    %result must be the same length as query
    lengths = cellfun('length',list);
    validlength = lengths==length(query);
    idx = intersect(idx,find(validlength));
else %substing ok
    idx = find(~cellfun('isempty',posn));
end
end

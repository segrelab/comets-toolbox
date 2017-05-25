function [model, failed, failedflag] = normalizeMetNames(model)
%NORMALIZEMETS Replace the model.mets with a standardized name and format
% 
% [OUTPUTARGS] = NORMALIZEMETNAMES(INPUTARGS) 
%   model: A COBRA model
%   failed: cell array of the met names which did not have a match in
%   the alias DB
%   failedflag: logical array denoting for each met wether it did not have
%   a match in the alias DB (1 = no match found)
% 
% Examples: 
% 
% Provide sample usage code here
% 
% See also: List related files here

% $Author: mquintin $	$Date: 2016/10/28 12:59:12 $	$Revision: 0.2 $
% Copyright: Daniel Segr�, Boston University Bioinformatics Program 2016

% Changelog: 
% 5/23/2017: add compatability with names that denote compartment by using 
% an underscore


%convert names in the form "some_metabolite_c" to "some_metabolite[c]" in
%order to be compatible with parseMetNames. Note we're not directly
%modifying parseMetNames because we shouldn't touch Cobra functions
mets = model.mets;
for i = 1:length(mets)
    met = mets{i};
    if ~isempty(regexp(met,'_'))
        %Greedy search, so there should only be two tokens
        %regardless of the number of underscores in the string
        [tokens,tmp] = regexp(met,'(.+)_(.+)','tokens','match');
        %Now replace the name in bracketed format
        mets{i} = [tokens{1}{1} '[' tokens{1}{2} ']'];
    end
end


%call COBRA to strip the compartment if in the form "metName[c]" or "metName(c)"
[basemetnames, compsymbols] = parseMetNames(mets);

newmetnames = cell(length(basemetnames),1);
failed = cell(length(basemetnames),1);
failedflag = zeros(length(basemetnames),1);

dbpath = which('metabolites\metnames.db');
mksqlite('open',dbpath);

for i = 1:length(basemetnames)
    met = basemetnames{i};
    %use LIKE instead of == to ignore case
    res = mksqlite('select official from PSEUDONYM where pseudonym like ?',met);
    if ~isempty(res) %match found
        %if ischar(res.official)
        %    newmetnames{i} = res.official;
        %elseif iscell(res.official)
        %    newmetnames{i} = res.official{1};
        %else %something weird happened. Default to failing
        %    newmetnames{i} = met;
        %    failedflag(i) = 1;
        %    failed{i} = met;
        %end
        
        %the above is temporarily removed due to strange behavior in
        %mksqlite when multiple values are returned. I expected
        %res.official to contain a single value, either a string or a cell
        %array. Instead it contains multiple values: a string for each
        %returned record. So, I'll wrap them in a cell array and pull out
        %the first. 
        %Note that this means multiple returns (which shouldn't occur, but 
        %aren't enforced not to occur by the DB) will be hidden
        
        newname = {res.official};
        newmetnames{i} = newname{1};
        
    else %no match found
        %try searching on the model.metNames field instead
        [tempbase, tempcomp] = parseMetNames(model.metNames(i));
        res = mksqlite('select official from PSEUDONYM where pseudonym like ?',tempbase{1});
        if ~isempty(res)
            newname = {res.official};
            newmetnames{i} = newname{1};
            if strcmp('',compsymbols{i})
                compsymbols{i} = tempcomp{1};
            end
        else %still no match
            newmetnames{i} = met;
            failedflag(i) = 1;
            failed{i} = met;
        end
    end
end
mksqlite('close');

%trim the 'failed' cell array
failed = failed(~cellfun('isempty',failed));

%reattach compartment symbols
for i = 1:length(newmetnames)
    if ~strcmp('',compsymbols{i})
        newmetnames{i} = [newmetnames{i} '[' compsymbols{i} ']'];
    end
end

%apply change to the model
model.mets = newmetnames;
end

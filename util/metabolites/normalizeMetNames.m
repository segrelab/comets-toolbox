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

% $Author: mquintin $	$Date: 2016/10/28 12:59:12 $	$Revision: 0.1 $
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016


%call COBRA to strip the compartment if in the form "metName[c]" or "metName(c)"
[basemetnames, compsymbols] = parseMetNames(model.mets);

newmetnames = cell(length(basemetnames),1);
failed = cell(length(basemetnames),1);
failedflag = zeros(length(basemetnames),1);

mksqlite('open','metnames.db');
for i = 1:length(basemetnames)
    met = basemetnames{i};
    res = mksqlite('select official from PSEUDONYM where pseudonym == ?',met);
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
        newmetnames{i} = met;
        failedflag(i) = 1;
        failed{i} = met;
    end
end
mksqlite('close');

%trim the 'failed' cell array
failed = failed(~cellfun('isempty',failed));

%reattach compartment symbols
for i = 1:length(newmetnames)
    newmetnames{i} = [newmetnames{i} '[' compsymbols{i} ']'];
end

%apply change to the model
model.mets = newmetnames;
end

function [model, failed, failedflag] = normalizeMetNames(model)
%NORMALIZEMETNAMES Replace the model.mets with a standardized name and format
% 
% [OUTPUTARGS] = NORMALIZEMETNAMES(INPUTARGS) 
%   model: A COBRA model
%   failed: cell array of the met names which did not have a match in
%   the alias DB
%   failedflag: logical array denoting for each met wether it did not have
%   a match in the alias DB (1 = no match found)
% 
% This script searches the SQLite database metnames.db for a cannonical
% name matching the names in model.mets.
% If any metabolite doesn't return a match, the db is searched using the 
% corresponding value in model.metNames.
% If neither returns a match, the original value in model.mets is used and
% the metabolite is marked as 'failed'
% 
% $Author: mquintin $	$Date: 2016/10/28 12:59:12 $	$Revision: 0.2 $
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016

% Changelog: 
% 5/23/2017: add compatability with names that denote compartment by using 
% an underscore

%To do:
%Add warning/fail when the number of unique metIDs is changed

%convert names in the form "some_metabolite_c" to "some_metabolite[c]" in
%order to be compatible with parseMetNames. Note we're not directly
%modifying parseMetNames because we shouldn't touch Cobra functions
mets = model.mets;
for i = 1:length(mets)
    met = mets{i};
    if (isempty(regexp(met,'[\[\(]', 'once')) && ~isempty(regexp(met,'_', 'once')))
        %Greedy search, so there should only be two tokens
        %regardless of the number of underscores in the string
        [tokens,tmp] = regexp(met,'(.+)_(.+)','tokens','match');
        %Now replace the name in bracketed format
        mets{i} = [tokens{1}{1} '[' tokens{1}{2} ']'];
    end
end


%call COBRA to strip the compartment if in the form "metName[c]" or "metName(c)"
[basemetnames, compsymbols] = parseMetNames2(mets);

newmetnames = cell(length(basemetnames),1);
failed = cell(length(basemetnames),1);
failedflag = zeros(length(basemetnames),1);

dbpath = which(['metabolites' filesep 'metnames.db']);
mksqlite('open',dbpath);

for i = 1:length(basemetnames)
    met = basemetnames{i};
    %use LIKE instead of == to ignore case
    res = mksqlite('select official from PSEUDONYM where pseudonym == ?',strtrim(met));
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
        [fullbase, fullcomp] = parseMetNames2(model.metNames(i));
        res = mksqlite('select official from PSEUDONYM where pseudonym == ?',strtrim(fullbase{1}));
        if ~isempty(res)
            newname = {res.official};
            newmetnames{i} = newname{1};
            if strcmp('',compsymbols{i})
                compsymbols{i} = fullcomp{1};
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

%Extended from COBRA parseMetNames in order to support compartments with
%multi-character abbreviations
function [baseMetNames, compSymbols] = parseMetNames2(metNames)
if ~iscell(metNames)
    metNames = {metNames};
end

try
    data = cellfun(@(x) regexp(x,'^(?<metNames>.*)\[(?<compSymbols>[^\[*]*)\]$','names'),metNames);
catch
    %If the above doesn't work, its likely, that we either have an odd
    %compartment symbol (e.g. (), or that we have a non compartmented
    %entry.
    %Lets see if we have a ()compartment symbol
    try
        data = cellfun(@(x) regexp(x,'^(?<metNames>.*)\((?<compSymbols>[^\[*]*)\)$','names'),metNames);
    catch
        %No, we don't lets assume, we only have a metabolite name
        data = cellfun(@(x) regexp(x,'^(?<metNames>.*)[\(\[]*(?<compSymbols>.*)[^\[\(]*[\]\)]*$','names'),metNames);
    end
end
baseMetNames = columnVector({data.metNames});
compSymbols = columnVector({data.compSymbols});
end

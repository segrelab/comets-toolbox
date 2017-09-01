function [indexList, nameList] = findMetsFromRxns(model, rxnList, varargin)
%FINDMETSFROMRXNS returns a list of metabolites which participate in at
%least one of the given reactions
% 
% [indexList, nameList] = FINDMETSFROMRXNS(model, rxnList) % INPUTS:
%     model:      COBRA model structure
%     rxnList:    A list of reaction
%                 indexes OR a cell array of reaction names 
%     inAllRxns:    false (default): return mets that participate in ANY of
%                               the given reactions
%                   true: return mets that participate in ALL given
%                               reactions
%
% $Author: mquintin $	$Date: 2017/09/01 12:12:04 $	$Revision: 0.1 $
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2017

if isa(rxnList,'char')
    rxnList = {rxnList};
end
if isa(rxnList,'cell')
    rxnList = findRxnIDs(model,rxnList);
end

%confirm rxnList is now a list of numbers
if ~isa(rxnList,'double')
    error('Argument rxnList for findMetsFromRxns should be a list of reaction names or indexes.');
end

%set inAllRxns
inAllRxns = false;
if (length(varargin) > 0)
    if islogical(varargin{1})
        inAllRxns = varargin{1};
    end
end

%get the values
subS = model.S(:,rxnList); %all mets X rxns
subS = subS ~= 0; %convert to logical- is a value set here?
count = sum(subS,2); %collapse rxns
target = 1;
if inAllRxns 
    [nmets,nrxns] = size(subS);
    target = nrxns;
end
indexList = find(count >= target);
nameList = model.mets(indexList);

end

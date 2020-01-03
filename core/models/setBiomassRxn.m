function [model, status] = setBiomassRxn( model, rxnNames, val)
%SETBIOMASRXN Set a logical vector in a COBRA model structure to indicate
%if a reaction should be used to calculate the biomass flux. If no such
%reactions are indicated, COMETS will default to using the objective
%reaction for this.
%Arguments:
% model: a Cobra model struct
% rxnName: the String name of a reaction as in model.rxns, or in 
%             model.rxnNames if not found in rxns.
%          Or a cell array of reaction names
%          Alternatively, the index of a reaction or an array of indexes
%       If an empty list {} or [] is given, the biomassRxn vector will be
%       removed from the model.
% val: Optional value to set, treated as a logical ("does this reaction make
%           biomass?"). Default = true
%
%Returns a modified model struct, and status = 1 if successful or 0 if the
%reaction could not be found.
%
% $Author: mquintin $	$Date: 2017/02/01 $	$Revision: 0.1 $
% Last edit: mquintin 01/02/2017
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016
%
status = 0;

idx = -1;

%default to setting the indicated reactions' biomass status to true
if nargin < 3 || val
    val = 1;
else
    val = 0;
end



%parse the reaction names
if ischar(rxnNames) %a single reaction name
    rxnNames = {rxnNames};
end
if iscell(rxnNames) %string names given
    idx = zeros(length(rxnNames));
    for i = 1:length(rxnNames)
        j = stridx(rxnNames{i},model.rxns,false);
        if isempty(j)
            j = stridx(rxnNames{i},model.rxnNames,false);
        end
        if ~isempty(j)
            idx(i) = j(1);
            status = 1;
        end
    end
end

if isnumeric(rxnNames) %works for a single index or an array
    idx = rxnNames;
end

%handle cases where the value is being reset
if isempty(rxnNames) && isfield(model,'biomassRxn')
    model = rmfield(model,'biomassRxn');
    if sum(model.c) < 1
        warning(['After removing the Biomass Reaction, the model ' ...
            getModelName(model) ' has no Objective Reaction set.']);
    end
end

%initialize or grow the vector if necessary
%if ~isempty(rxnNames) && ~isfield(model,'biomassRxn')
%    model.biomassRxn = zeros(1,length(model.rxns));
%elseif ~isempty(rxnNames) && length(model.biomassRxn) < length(model.rxns)
%    model.biomassRxn(length(model.biomassRxn)+1:length(model.rxns)) = 0;
%end

%set the value
for i=1:length(idx)
    j = idx(i);
    model.biomassRxn(j) = val;
end

end


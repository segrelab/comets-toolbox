function [model, status] = setKm( model, rxnNames, km )
%SETKM Set the KM of a reaction in a format to be included in a COMETS
%model file.
%Arguments:
% model: a Cobra model struct
% rxnName: the String name of a reaction as in model.rxns, or in 
%             model.rxnNames if not found in rxns.
%          Or a cell array of reaction names
%          Alternatively, the index of a reaction or an array of indexes
% km: the Double value to set
%     or 'default', 'd' or NaN to reset the value to the default
%
%Returns a modified model struct, and status = 1 if successful or 0 if the
%reaction could not be found.
%
% $Author: mquintin $	$Date: 2016/30/12 $	$Revision: 0.1 $
% Last edit: mquintin 12/30/2016
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016
%
status = 0;

idx = -1;

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
if isnan(km) || strcmpi('d',km) || strcmpi('default',km)
    km = NaN;
end

%initialize or grow the KM vector if necessary
if ~isfield(model,'km')
    model.km = NaN(1,length(model.rxns));
elseif length(model.km) < length(model.rxns)
    model.km(length(model.km)+1:length(model.rxns)) = NaN;
end

%set the value
for i=1:length(idx)
    j = idx(i);
    model.km(j) = km;
end

end


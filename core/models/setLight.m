function [model, status] = setLight( model, rxnNames, absorption)
%SETLIGHT Set the Light parameters of reactions related to uptake of photons in a format to be included in a COMETS
%model file.
%Arguments:
% model: a Cobra model struct
% the model organism and the biomass dry weight
% rxnName: the String name of a reaction as in model.rxns, or in 
%             model.rxnNames if not found in rxns.
%          Or a cell array of reaction names
% absorption: the Double value of the absorption coefficient(s) or a list
% of coefficients of equal length as the number of reactions in rxnNames
%
%Returns a modified model struct, and status = 1 if successful or 0 if the
%reaction could not be found.
%
% $Author: Snorre Sulheim $ $Date: 1/28/2020 $	$Revision: 0.1 $
% Last edit: Snorre Sulheim 1/28/2020
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016
%

status = 0;
idx = -1;

%parse the reaction names
if ischar(rxnNames) %a single reaction name
    rxnNames = {rxnNames};
end

if isnumeric(absorption)
        absorption = [absorption];
end

if length(rxnNames) ~= length(absorption)
    error('The number of reactions have to be equal to the number of absorption coefficients');
end

if iscell(rxnNames) %string names given
    idx = zeros(length(rxnNames));
    for i = 1:length(rxnNames)
        j = stridx(rxnNames{i},model.rxns,false);
        if ~isempty(j)
            idx(i) = j(1);
            status = 1;
        end
    end
end


% Add the information to the model object
model.absorption = NaN(length(model.rxns),1);

%set the value
for i=1:length(idx)
    j = idx(i);
    model.absorption(j) = absorption(i);
end

end
function [model, status] = setLight( model, rxnNames, absorption)
% SETLIGHT Set the Light parameters of reactions related to uptake of photons in a format to be included in a COMETS
% model file. The light absorption is modelled as a linear function 
% f(z) =  a + b*X, where a is given in m^-1 and b in m*2/gDW. a is then
% typically the attenuation coefficent of the medium when no biomass
% (chlorophyll is present), and a common value would be the absorption
% coefficient of pure water. b is the biomass (chlorophyll) dependent
% absorption. 
%
% Arguments:
% model: a Cobra model struct
% the model organism and the biomass dry weight
% rxnName: the String name of a reaction as in model.rxns, or in 
%             model.rxnNames if not found in rxns.
%          Or a cell array of reaction names
% absorption: A N x 2 matrix with absorption coefficients. The first column 
% should contain the baseline (intercept) absorption coefficient (in m^-1), 
% and the second column the chlorophyll-dependent absorption. The number of
% rows N must match the number of reactions given in rxnNames
%
% Returns a modified model struct, and status = 1 if successful or 0 if the
% reaction could not be found.
%
% $Author: Snorre Sulheim $ $Date: 1/28/2020 $	$Revision: 0.2 $
% Last edit: Snorre Sulheim 3/9/2020
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016
%

status = 0;
idx = -1;

%parse the reaction names
if ischar(rxnNames) %a single reaction name
    rxnNames = {rxnNames};
end

if ~ismatrix(absorption)
    error('The absorption coefficients must be passed as a N x 2 matrix');
end

absorption_size = size(absorption);

if (absorption_size(2) ~= 2)
    error('The absorption coefficients matrix must have 2 columns');
end

if length(rxnNames) ~= absorption_size(1)
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
model.absorption = NaN(length(model.rxns),2);

%set the value
for i=1:length(idx)
    j = idx(i);
    model.absorption(j,:) = absorption(i,:);
end

end
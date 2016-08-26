function [outputArgs] = compartmentalize(varargin)
%COMPARTMENTALIZE Add a compartment to the model which contains all
%external media
%
% usage: [layout model] = COMPARTMENTALIZE(layout, model)
%   layout: a CometsLayout optionally containing the model to be altered
%   model: a COBRA model 
%   Returns a CometsLayout which has replaced the specified model with a
%   transformed one if it was already present in the layout, as well as the
%   transformed model
%
% [layout model] = COMPARTMENTALIZE(layout, modelname)
%   layout: a CometsLayout which must contain the named model modelname:
%   the String contained in one model's descriiption field 
%   Returns a CometsLayout which has replaced the specified model with a
%   transformed one, as well as the transformed model
%
% [layout] = COMPARTMENTALIZE(layout)
%   layout: a CometsLayout containing at least one model Returns a
%   CometsLayout in which all models have been transformed


% $Author: mquintin $	$Date: 2016/08/24 16:54:48 $	$Revision: 0.1 $
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016

if nargin == 1
    layout = varargin{1};
    for i = 1:length(layout.models)
        model = layout.models{i};
        [l, m] = compartmentalizeOneModel(layout, model);
        layout = l;
    end
    outputArgs = layout;
else
    layout = varargin{1};
    model = varargin{2};
    if isstruct(model)
        outputArgs = compartmentalizeOneModel(layout, model);
    elseif ischar(model)
        for i = 1:length(layout.models)
            m = layout.models{i};
            if strmatch(model,m.description)
                model = m;
                break;
            end
        end
        outputArgs = compartmentalizeOneModel(layout, model);
    end
end

end

function [layout, model] = compartmentalizeOneModel(layout, model)
%TODO
end
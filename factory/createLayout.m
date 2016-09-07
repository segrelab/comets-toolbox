function layout = createLayout(varargin)
%CREATELAYOUT intialize a new blank Layout or one using the given models
%and CometsParams
%   createLayout() createLayout(CometsParams) createLayout([CobraModel])
%   createLayout(CometsParams, [CobraModel])

%create a blank layout
layout = CometsLayout();

%parse args to add models and Params
if nargin == 1
    if strcmp(class(varargin{1}),'CometsParams')
        layout = setCometsParams(layout,varargin{1});
    elseif isstruct(varargin{1})
        layout = addModel(layout,varargin{1});
    end
elseif nargin > 1
    for i = 1:nargin
        m = varargin{i};
        if isstruct(m)
            layout = addModel(layout,m);
        end
    end
end
end


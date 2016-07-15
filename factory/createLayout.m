function layout = createLayout(input_args)
%CREATELAYOUT intialize a new blank Layout or one using the given models
%and CometsParams
%   createLayout()
%   createLayout(CometsParams)
%   createLayout([CobraModel])
%   createLayout(CometsParams, [CobraModel])

%create a blank layout
layout = CometsLayout();

%parse args to add models and Params
for arg= input_args
    if strcmp(class(arg),'CometsParams')
        layout = setCometsParams(layout,arg);
    elseif length(arg) > 1
        for model=arg
            layout = addModel(layout,model);
        end
    elseif isstruct(arg)
        layout = addModel(layout,arg);
    end
end

end


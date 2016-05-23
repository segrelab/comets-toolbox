function layout = createLayout(input_args)
%CREATELAYOUT intialize a new blank Layout or one using the given models
%and CometsParams
%   createLayout()
%   createLayout(CometsParams)
%   createLayout([CobraModel])
%   createLayout(CometsParams, [CobraModel])

%create a blank layout
%required fields: models xdim ydim mets media_amt params diffusion_const media_refresh

layout.models = [];
layout.xdim = 1;
layout.ydim = 1;
layout.mets = [];
layout.media_amt = []; %vector 1/met, default 0
layout.params = CometsParams();
layout.diffusion_const = []; %vector 1/met, default in params
layout.global_media_refresh = []; %vector 1/met, default 0
layout.media_refresh = []; %x by y by met, fill with 0


%parse args to add models and Params
for arg= input_args
    if ISA(arg,'CometsParams')
        layout = setCometsParams(layout,arg);
    elseif length(arg) > 1
        for model=arg
            layout = addModel(layout,model);
        end
    elseif isstruct('struct')
        layout = addModel(layout,arg);
    end
end

end


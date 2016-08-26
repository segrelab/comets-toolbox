function [involvedMets,DeadEnds] = drawByRxn(varargin)
%DRAWBYRXN A wrapper for the draw_by_rxn function from Paint4Net, to
%display the full input model
% 
% [involvedMets,DeadEnds] = DRAWBYRXN(model, [solution])
% 
% model: a COBRA model 
% the second argument can be either a boolean, or a
% Cobra optimization solution for the given model. In the case where the
% second argument is not given or evaluates to True, runCbModel() will be
% called to optimize the model
%
% $Author: mquintin $	$Date: 2016/08/22 16:54:42 $	$Revision: 0.1 $
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016

model = varargin{1};
runopt = true;

if nargin > 1
    opt = varargin{2};
    %given an optimization solution
    if  isstruct(opt) & ismember('x',fields(opt))
        opt = opt.x;
    %given the flux vector from an optimization solution
    elseif isvector(opt) & length(opt) == length(model.rxns)
        opt = opt;
    %booleans
    elseif opt == 1 
        runopt = true;
    elseif strcmpi(opt,'true')
        runopt = true;
    else
        runopt = false;
    end
end

if runopt
    s = optimizeCbModel(model);
    [involvedMets,DeadEnds] = draw_by_rxn(model,model.rxns,'true','struc',{''},{''},s.x);
else
    [involvedMets,DeadEnds] = draw_by_rxn(model,model.rxns,'true','struc',{''},{''});
end

end

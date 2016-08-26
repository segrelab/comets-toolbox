function [involvedRxns,involvedMets,DeadEnds] = drawByMet(varargin)
% DRAWBYMET(model, met, [rad], [solution]) Visualize the reaction dynamics
% surrounding the given metabolite, utilizing the draw_by_met function from
% Paint4Net
%  model = a Cobra model met = a String metabolite name (as in model.mets)
%  rad = optional. distance from the metabolite to explore. default = 2
%  solution = optional optimization solution for the given model. In the
%  case where the argument is not given or evaluates to True, runCbModel()
%  will be called to optimize the model

% $Author: mquintin $	$Date: 2016/08/22 16:58:24 $	$Revision: 0.1 $
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016

model = varargin{1};
met = varargin{2};
rad = 2;
runopt = true;
opt = [];
if nargin > 2
    rad = varargin{3};
end
if nargin > 3
    opt = varargin{3};
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
    changeCobraSolver('gurobi5');
    s = optimizeCbModel(model,'max',0,true);
    opt = s.x;
end
if ~isempty(opt)
    [involvedRxns,involvedMets,DeadEnds] = draw_by_met(model,{met},'true',rad,'struc',{''},opt);
else
    [involvedRxns,involvedMets,DeadEnds] = draw_by_met(model,{met},'true',rad,'struc',{''});
end

end


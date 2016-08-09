function found = findExMetNames(varargin)
%FINDEXMETNAMES Return the metNames of all external metabolites in the given 
%model which contain any of the (case-insensitive) strings given in {metsToFind}. 
%If no metabolite names are given, simply return all exchange metabolites
%
% Arguments:
% model   A Cobra-format model struct
% [metsToFind]   Single string or Cell array of strings to search for

model = varargin{1};
if nargin < 2
    metsToFind = '';
elseif nargin == 2
    metsToFind = varargin{2};
else
    metsToFind = {varargin{2:end}};
end

if iscell(metsToFind)
    f = cellfun(@(x) findOneMet(model,x), metsToFind, 'UniformOutput', false);
    found = vertcat(f{:});
else
    found = findOneMet(model,metsToFind);
end
    %return all metNames in the model that match the given one
    function m = findOneMet(model, met)
        rstr = ['.*' met '.*e0']; %regex wildcards
        matches = cellfun(@(x) regexpi(x,rstr,'match'), model.metNames, 'UniformOutput', false);
        m = vertcat(matches{~cellfun('isempty',matches)});
    end

end


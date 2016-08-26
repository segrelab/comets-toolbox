function [outputArgs] = runCometsOnMany(varargin)
%RUNCOMETSONMANY Iteratively runs Comets on multiple model files
%individiually and in combinations up to the specified n. Arugments should
%be given in 'name', value pairs as speficied below.
% 
%Required arguments:
%   one of ['models' | 'files' | 'dir']
%
% [OUTPUTARGS] = RUNCOMETSONMANY(INPUTARGS) 
%   'models',{cobraModels} : Specify a cell array of models to use
%   'files',{files} : Specify a cell array of paths corresponding to Cobra
%               models to load
%   'dir',path : Use all model files in the specified directory
%   'n',[int] : specify the number of models that will be included in
%               layouts. Multiple values mean that communities of each size
%               will be evaluated (for example, 1:3 will evaluate every 
%               singleton, pair, and triple set of models. A value of just 
%               '2' will evaluate only each pair). Default [1 2]
%   'include',[cobraModel | file] : Only evaluate layouts that include the
%               specified model (which may or may not have been included 
%               in the models, files, or dir arguments)
%   'layout',CometsLayout : A CometsLayout to be used as a template for all
%               Comets runs
%   'modelnames',{str} : specify a list of names to use for each model when
%               creating output files
%   'outdir',path : Directory into which output files should be placed
% 
%   TODO: Initial Population
% 

% Examples: 
% 
% Provide sample usage code here
% 
% See also: List related files here

% $Author: mquintin $	$Date: 2016/08/25 14:57:20 $	$Revision: 0.1 $
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016

%TODO: Parallelize the Comets call (use parfor instead of for loops)

models = {};
nmodels = 1:2;

for i=1:2:nargin
    arg = lower(varargin{i});
    val = varargin{i+1};
    switch arg
        case 'models'
            
        case 'files'
            
        case 'dir'
            
        case 'layout'
            
        case 'n'
            nmodels = val;
        case 'include'
            
        case 'modelnames'
            
        case 'outdir'
            
        otherwise
            error(['Unsupported argument ' varargin(i)]);
    end


end

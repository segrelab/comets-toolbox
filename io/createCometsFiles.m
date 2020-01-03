function [ output_args ] = createCometsFiles(layout, directory, layoutFileName, separateParamsFiles, modelFileDir)
%CREATECOMETSFILES(layout, [directory], [layoutFileName], [separateParamsFiles])
%write the comets_script, global_params, and package_params files necessary
%for a COMETS run based on the given CometsLayout
%Args:
% layout: a CometsLayout object
% directory: location to write to (defaults to current directory)
% layoutFileName: name and extension of the layout file (default
%   'comets_layout.txt')
% separateParamsFiles: If true, creates separate files to contain the
%   global and package parameters. If false, all parameters are included in
%   the body of the layout file. (default false)
% modelFileDir: Directory that contains the model files. This string
%     will be prepended onto the model file name, but not affect the
%     destination where this script creates the model files (which is
%     set in the filedir argument). This is intended for when the model
%     files are already in a separate location, or an absolute path must be
%     provided because the layout will be executed by a script that is not
%     in the same location as it.

if nargin < 2
    directory = pwd;
end
if nargin < 3
    layoutFileName = 'comets_layout.txt';
end
if nargin < 4
    separateParamsFiles = false;
end
if nargin < 5
    modelFileDir = '';
end

if separateParamsFiles
    createCometsParamsFile(directory, 'global_params.txt', layout.params);
    createPackageParamsFile(directory, 'package_params.txt', layout.params);
end
createScriptFile(directory, layoutFileName, separateParamsFiles);

writeCometsLayout(layout, directory, layoutFileName, ~separateParamsFiles, true, modelFileDir); 
    %writeCometsLayout also creates model files

end


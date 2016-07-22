function [ output_args ] = createCometsFiles( directory, layout )
%CREATECOMETSFILES Create the specified directory if it doesn't exist, then
%write the CometsScript, CometsParams, and PackageParams files necessary
%for a COMETS run based on the given CometsLayout

%TODO: add argument to specify name of layout file

mkdir(directory);

createScriptFile(directory, 'comets_layout.txt');
createCometsParamsFile(directory, 'global_params.txt', layout.params);
createPackageParamsFile(directory, 'package_params.txt', layout.params);

writeCometsLayout(layout, directory, 'comets_layout.txt');

end


function [ output_args ] = createPackageParamsFile( directory, params )
%CREATEPACKAGEPARAMSFILE Create the package params file for a COMETS run.
%Input: 
%   directory: location of the output file
%   params: a CometsParams object

fname = fullfile(directory, 'package_params.txt');
f = fopen(fname,'w');

fprintf(f,'numDiffPerStep = %d\n',params.numDiffPerStep);
fprintf(f,'numRunThreads = %d\n',params.numRunThreads);
fprintf(f,'growthDiffRate = %d\n',params.growthDiffRate);
fprintf(f,'flowDiffRate = ',);
fprintf(f,'',);
fprintf(f,'',);
fprintf(f,'',);
fprintf(f,'',);
fprintf(f,'',);
fprintf(f,'',);
fprintf(f,'',);
fprintf(f,'',);
fprintf(f,'',);
fprintf(f,'',);

end


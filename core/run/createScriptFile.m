function createScriptFile( directory, layoutName )
%CREATESCRIPTFILE Create the comets_script.txt file which tells
%command-line COMETS where to find the files it needs to run
%
%Layout name will be guessed if not provided.

if nargin < 2
    layoutName = 'comets_layout.txt';
elseif ~strfind(layoutName,'.') %the layout name doesn't have an extension
    layoutName = [layoutName '.txt'];    
end

scriptfile = fullfile(directory, 'comets_script.txt');
gpfile = fullfile(directory,'global_params.txt');
ppfile = fullfile(directory,'package_params.txt');
lfile = fullfile(directory,layoutName);

file = fopen(scriptfile,'w');

fprintf(file,'load_comets_parameters %s\n',gpfile);
fprintf(file,'load_package_parameters %s\n',ppfile);
fprintf(file,'load_layout %s\n',lfile);

fclose(file);
end


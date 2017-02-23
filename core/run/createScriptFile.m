function createScriptFile( directory, layoutName, paramFilesExist )
%CREATESCRIPTFILE(directory, [layoutName], [paramFilesExist]) Create the
%comets_script.txt file which tells command-line COMETS where to find the
%files it needs to run
%
%Layout name will be guessed if not provided.
%If paramFilesExist is not given, the function will check the given
%directory for 'global_params.txt' and 'package_params.txt'.
%If paramFilesExist = false, the script will exclude any params files even
%if they really do exist

if nargin < 2
    layoutName = 'comets_layout.txt';
elseif ~strfind(layoutName,'.') %the layout name doesn't have an extension
    layoutName = [layoutName '.txt'];
end

scriptfile = fullfile(directory, 'comets_script.txt');
lfile = fullfile(directory,layoutName);
gpfile = fullfile(directory,'global_params.txt');
ppfile = fullfile(directory,'package_params.txt');

%do the param files exist?
gpexist = exist(gpfile,'file');
ppexist = exist(ppfile,'file');

%default behavior if paramFilesExist is not given
if nargin < 3
    paramFilesExist = gpexist | ppexist;
end

file = fopen(scriptfile,'w');

fprintf(file,'load_layout %s\n',lfile);

if paramFilesExist
    if gpexist
        fprintf(file,'load_comets_parameters %s\n',gpfile);
    end
    if ppexist
        fprintf(file,'load_package_parameters %s\n',ppfile);
    end
end

fclose(file);
end


function tab = parseBiomassLog(biomassFile)
% parseBiomassCometsOutput:
% parses biomass file into a table with the following columns:
% t: cycle/timestep
% x: x coordinate
% y: y coordinate
% z: z coordinate
% model: ID number of the model (ordered as in the layout)
% biomass: biomass value

filelength = countLinesInFile(biomassFile);

if filelength > 1
f = fopen(biomassFile);
tline = fgetl(f);
k = 1; %counter for iterating lines
ndims = 2;

%initialize. These will be too big if you have more than one cell or model,
%but we'll trim later
X = nan(filelength,1);
Y= nan(filelength,1);
Z= zeros(filelength,1);
Biomass= nan(filelength,1);
T= nan(filelength,1);
ModelId= nan(filelength,1);
ModelName = cell(filelength,1);

%Determine the version/format of the logs based on the first line
%Version 1: biomass_0_0 = sparse(1, 1);
%Version 2 (ca. Comets v 2.6.3, August 7 2019): T X Y modelName.txt 1E-6
version = 2;
if strcmpi('biomass_',tline(1:8))
    version = 1;
end

if version == 1
    while ischar(tline)
        timeStep = str2num(regexp(tline,'(?<=biomass\_)\d*','match','ONCE'));
        modelID = str2num(regexp(tline,'(?<=biomass\_\d*\_)\d*','match','ONCE'));

        if timeStep > -1 %because of a weird bug where 'biomass' is corrupted
            if isempty(regexp(tline,'sparse','match','ONCE'))
                x = str2num(regexp(tline,'(?<=biomass\_\d*\_\d*\()\d*','match','ONCE'));
                y = str2num(regexp(tline,'(?<=biomass\_\d*\_\d*\(\d*, )\d*','match','ONCE'));
                z = str2double(tline(regexp(tline,'(?<=\= )\d'):end-1));

                X(k) = x;
                Y(k) = y;
                Biomass(k) = z;
                T(k) = timeStep;
                ModelId(k) = modelID;
                k = k+1;
            end
        end
        tline = fgetl(f);
    end
else %version == 2
    modelNames = {};
    
    %future-proofing for a version where 3d biomass logs enter with format: T X Y modelName.txt 1E-6
    nameIdx = 4;
    bioIdx = 5;
    parts = strsplit(tline);
    if length(parts) > 5
        ndims = 3;
        nameIdx = 5;
        bioIdx = 6;
    end
    while ischar(tline)
        parts = strsplit(tline);
        if str2num(parts{1}) > -1
            T(k) = str2num(parts{1});
            X(k) = str2num(parts{2});
            Y(k) = str2num(parts{3});
            if ndims > 2
                Z(k) = str2num(parts{4});
            end
            name = parts{nameIdx};
            mid = stridx(name,modelNames,false);
            if ~any(mid)
                modelNames = [modelNames name];
                mid = stridx(name,modelNames,false);
            end
            ModelId(k) = mid(1) - 1; %zero-indexed to keep consistent with Comets's V1 format
            ModelName{k} = name;
            Biomass(k) = str2double(parts{bioIdx});
            k = k+1;
        end
        tline = fgetl(f);
    end
    
end

fclose(f);

nrows = sum(~isnan(X));
tab = table();
tab.t = T(1:nrows);
tab.x = X(1:nrows);
tab.y = Y(1:nrows);
tab.z = Z(1:nrows);
tab.model = ModelId(1:nrows);
tab.biomass = Biomass(1:nrows);
tab.modelName = ModelName(1:nrows);

else
    tab = array2table(nan(0,7),'VariableNames',{'t','x','y','z','model','biomass','modelName'});
end
end


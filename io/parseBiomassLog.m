function out = parseBiomassLog(biomassFile)
% parseBiomassCometsOutput:
% parses biomass file into a table with the following columns:
% t: cycle/timestep
% x: x coordinate
% y: y coordinate
% model: ID number of the model (ordered as in the layout)
% biomass: biomass value

filelength = countLinesInFile(biomassFile);

if filelength > 1
f = fopen(biomassFile);
tline = fgetl(f);
k = 1;

%initialize. These will be too big if you have more than one cell or model,
%but we'll trim later
X = nan(filelength,1);
Y= nan(filelength,1);
Biomass= nan(filelength,1);
T= nan(filelength,1);
ModelId= nan(filelength,1);

while ischar(tline)
    
    timeStep = str2num(regexp(tline,'(?<=biomass\_)\d*','match','ONCE'));
    modelID = str2num(regexp(tline,'(?<=biomass\_\d*\_)\d*','match','ONCE'));
    
    if timeStep > -1 %because of a weird bug where 'biomass' is corrupted
        if isempty(regexp(tline,'sparse','match','ONCE'))
            x = str2num(regexp(tline,'(?<=biomass\_\d*\_\d*\()\d*','match','ONCE'));
            y = str2num(regexp(tline,'(?<=biomass\_\d*\_\d*\(\d*, )\d*','match','ONCE'));
            z = str2num(tline(regexp(tline,'(?<=\= )\d'):end-1));
            
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

fclose(f);

nrows = sum(~isnan(X));
arr = horzcat(T(1:nrows),X(1:nrows),Y(1:nrows),ModelId(1:nrows),Biomass(1:nrows));
out = array2table(arr);
out.Properties.VariableNames = {'t','x','y','model','biomass'};
else
    out = array2table(zeros(0,5),'VariableNames',{'t','x','y','model','biomass'});
end
end


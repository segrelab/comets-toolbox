function out = parseBiomassLog(biomassFile)
% parseBiomassCometsOutput:
% parses biomass file into a table with the following columns:
% t: cycle/timestep
% x: x coordinate
% y: y coordinate
% model: ID number of the model (ordered as in the layout)
% biomass: biomass value

f = fopen(biomassFile);
tline = fgetl(f);
k = 1;
while ischar(tline)
    
    timeStep = str2num(regexp(tline,'(?<=biomass\_)\d*','match','ONCE'));
    modelID = str2num(regexp(tline,'(?<=biomass\_\d*\_)\d*','match','ONCE'));
    
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
    tline = fgetl(f);
    
    
end

fclose(f);

arr = horzcat(T',X',Y',ModelId',Biomass');
out = array2table(arr);
out.Properties.VariableNames = {'t','x','y','model','biomass'};

end

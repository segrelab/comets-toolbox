function [out] = parseBiomassCometsOutput(biomassFile)
% parseBiomassCometsOutput:
% parses biomass file into struct with following fields:
% x: x pixel
% y: y pixel
% biomass: biomass value
% timeStep: cycle time step
% model: model ID

f = fopen(biomassFile);
tline = fgetl(f);
% build a 
k = 1;
while ischar(tline)
    
        timeStep = str2num(regexp(tline,'(?<=biomass\_)\d*','match','ONCE'));
        modelID = str2num(regexp(tline,'(?<=biomass\_\d*\_)\d*','match','ONCE'));
    
        if isempty(regexp(tline,'sparse','match','ONCE'));
            y = str2num(regexp(tline,'(?<=biomass\_\d*\_\d*\()\d*','match','ONCE'));
            x = str2num(regexp(tline,'(?<=biomass\_\d*\_\d*\(\d*, )\d*','match','ONCE'));
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

out.x = X;
out.y = Y;
out.biomass = Biomass;
out.model = ModelId;
out.timeStep = T;

end

classdef CometsParams
    %CometsParams A wrapper for  global and model-level parameters used in
    %COMETS FBA
    %
    %Constructor CometsParams()
    
    properties
        % Session/SSH parameters
        %local = false; %run on the local machine?
        %server;
        %username;
        %password; %TODO: how to secure this?
        % Don't store it- prompt at runtime
        
        % COMETS global params with defaults:
        maxCycles = 200
        pixelScale = 5
        saveslideshow = false
        slideshowExt = 'png'
        slideshowColorRelative = true
        slideshowRate = 1
        slideshowLayer = 324
        writeFluxLog = false
        FluxLogName = './flux.txt'
        FluxLogRate = 1
        writeMediaLog = false
        MediaLogName = './media.txt'
        MediaLogRate = 1
        writeBiomassLog = false
        BiomassLogName = './biomass.txt'
        BiomassLogRate = 1
        writeTotalBiomassLog = false
        totalBiomassLogRate = 1
        TotalbiomassLogName = './total_biomass'
        useLogNameTimeStamp = false
        slideshowName = './res.png'
        
        %COMETS package params with defaults:
        numDiffPerStep = 10
        numRunThreads = 1
        growthDiffRate = 0
        flowDiffRate = 3e-9
        exchangestyle = 'Monod Style'
        defaultKm = 0.01
        defaultHill = 1
        timeStep = 0.01
        deathRate = 0.0
        spaceWidth = 0.01 %COMETS calculates spaceVolume with this, dont include Vol
        maxSpaceBiomass = 2.2E-4
        minSpaceBiomass = 0.25e-10
        allowCellOverlap = true
        toroidalWorld = false
        showCycleTime = true
        showCycleCount = true
        defaultVmax = 10
        logFormat = 'COMETS' %['COMETS', 'Matlab']
        biomassMotionStyle = 'Convection 2D' %['Diffusion (Crank-Nicolson)', 'Diffusion
        %(Eight Point)', 'Diffusion 3D', 'Convection 2D', 'Convection 3D']
        exchangeStyle = 'Standard FBA' %['Standard FBA', 'Monod Style', 'Pseudo-Monod
        %Style']
        
        
        %TODO: Find appropriate values
        defaultReactionLower = 0.0
        defaultReactionUpper = 100
        defaultDiffusionConstant = 1e-6
        
    end
    
    methods
        %constructor
        function self = CometsParams()
        end
    end
    
end


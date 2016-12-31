classdef CometsParams
    %CometsParams A wrapper for  global and model-level parameters used in
    %COMETS FBA
    
    %Constructor CometsParams()
    %
    % $Author: mquintin $	$Date: 2016/08/16 17:05:10 $	$Revision: 0.2 $
    % Last edit: mquintin 12/30/2016
    % Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016
    
    properties       
        % COMETS global params with defaults:
        maxCycles = 200
        pixelScale = 5
        saveslideshow = false
        slideshowExt = 'png'
        slideshowColorRelative = true
        slideshowRate = 1
        slideshowLayer = 324
        writeFluxLog = false
        FluxLogName = './flux.m'
        FluxLogRate = 1
        writeMediaLog = false
        MediaLogName = './media.m'
        MediaLogRate = 1
        writeBiomassLog = false
        BiomassLogName = './biomass.m'
        BiomassLogRate = 1
        writeTotalBiomassLog = false
        totalBiomassLogRate = 1
        TotalbiomassLogName = './total_biomass.m'
        useLogNameTimeStamp = false
        slideshowName = './res.png'
        
        %COMETS FBA package params with defaults:
        numDiffPerStep = 10
        numRunThreads = 1
        growthDiffRate = 0
        flowDiffRate = 3e-9
        defaultDiffusionConstant = 1e-6
        timeStep = 0.01
        deathRate = 0.0
        spaceWidth = 0.01 %COMETS calculates spaceVolume with this, dont include Vol
        maxSpaceBiomass = 2.2E-4
        minSpaceBiomass = 0.25e-10
        allowCellOverlap = true
        toroidalWorld = false
        showCycleTime = true
        showCycleCount = true
        %randomOrder = false
        %logFormat = 'COMETS' %['COMETS', 'Matlab']
        biomassMotionStyle = 'Diffusion (Crank-Nicolson)' %['Diffusion (Crank-Nicolson)', 'Diffusion
        %(Eight Point)', 'Diffusion 3D']
        %Not yet implemented: ['Convection 2D', 'Convection 3D']
        exchangeStyle = 'Monod Style' %['Standard FBA', 'Monod Style', 'Pseudo-Monod
        %Style']
        
        %Model-relevent parameters
        defaultReactionLower = -1000
        defaultReactionUpper = 1000
        defaultKm = 0.01
        defaultHill = 1
        defaultVmax = 10        
        
    end
    
    methods
        %constructor
        function self = CometsParams()
        end
    end
    
end


classdef CometsParams
    %CometsParams A wrapper for  global and model-level parameters used in
    %COMETS FBA
    
    %Constructor CometsParams()
    %
    % $Author: mquintin $	$Date: 2016/08/16 17:05:10 $	$Revision: 0.3 $
    % Last edit: mquintin 6/22/2020
    % Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016
    
    properties       
        % COMETS global params with defaults:
        activateRate = 0.001 %probability of a model activating (from 0 to 1)
        allowCellOverlap = true %if true, allows different species to occupy the same space
        deathRate = 0.0 %from 0 to 1. fraction of biomass which dies each HOUR
        maxCycles = 200 %the maximum number of simulation steps to run. If set to -1, this is unlimited.
        maxSpaceBiomass = 2.2E-4 %grams. maximum allowed biomass in a space
        minSpaceBiomass = 1e-13 %grams. minimum allowed biomass in a space (setting to a small value > 0 might avoid some numerical errors)
        pauseOnStep = false %if true, pauses the simulation after completing a step
        randomOrder = true %Should the order that models are processed at each timestep be randomized? If false, they are always run in the order presented in the first line of the layout file.
        spaceWidth = 0.01 %centimeters. COMETS calculates spaceVolume with this ^3
        simulateActivation = false %if true, the models are activated with the set activationRate
        timeStep = 0.01 %hours. time for each simulation step
        toroidalWorld = false %If true, edge cells are considered adjacent to the cell on the opposite edge
        objectiveStyle = 'MAX_OBJECTIVE_MIN_TOTAL' %replace with 'default' to use the Comets package default
        randomSeed = 0 %seed for the semirandom number generator
        allowFluxWithoutGrowth = true; %Sets whether a metabolic model which cannot generate flux through its biomass reaction will still run in order to satisfy any other objective reactions
        
        %Graphical & output global params
        colorRelative = true %if true, colors each space relative to the space with the highest value.
        displayLayer = 0 %sets the current medium component (or biomass if 0) to be displayed 
        pixelScale = 5 %the number of pixels to render for each space
        showCycleTime = true %if true, shows the time it took to finish the fba cycle in the output
        showCycleCount = true %if true, shows the current cycle number in the output
        
        %Slideshow global params
        saveslideshow = false %if true, saves a graphics slideshow to a series of files. See also slideshowName.
        slideshowColorRelative = true %as colorRelative above, applied to the slideshow
        slideshowExt = 'png' %the file extension for slideshow pictures. Currently, only “png” “bmp” and “jpg” are supported, and “png” is probably the best.
        slideshowLayer = 0 %the layer to take a snapshot of for each slideshow step, in order of media from 0 to N-1 (for N media components). If this is set to N, a snapshot of the biomass is taken.
        slideshowName = './res.png'
        slideshowRate = 1 %the number of steps between taking a slideshow picture
                
        %COMETS FBA package params with defaults:
        biomassMotionStyle = 'Diffusion (Crank-Nicolson)' %Sets the method used for diffusing biomass. Only one of the indicated strings is an allowed value
            %['Diffusion 2D(Crank-Nicolson)', 'Diffusion 2D(Eight Point)', 'Diffusion 3D']
            %Not yet implemented: ['Convection 2D', 'Convection 3D']
            %Comets versions older than v 2.2.2 should use "Diffusion (Cranck-Nicolson)" or "Diffusion (Eight Point)", ommitting "2D"
        defaultDiffConst = 1e-6 %Units = cm^2/s. The default diffusion constant for extracellular metabolites
        %logFormat = 'COMETS' %['COMETS', 'Matlab']
        exchangeStyle = 'Monod Style' %Sets the method used for calculating maximum exchange rates for all extracellular metabolites. Only one of the three strings is an allowed value: ['Standard FBA', 'Monod Style', 'Pseudo-Monod Style']
        flowDiffRate = 0 %cm^2/s. The default biomass diffusion constant for non-growth diffusion 
        growthDiffRate = 0 %cm^2/s. The default biomass diffusion constant for growth
        numDiffPerStep = 10 %Number of partial diffusions to do for each time step. Instead of doing one big jump for a time step, this gives the option of breaking the time step into smaller pieces to do a smoother diffusion calculation.
        numRunThreads = 1 %set >1 to allow multithreaded computation
        
        %Model kinetics package parameters
        defaultAlpha = 1 %The default Alpha coefficient (slope) for the Pseudo-Monod style exchange
        defaultHill = 2 %The default Hill coefficient for Monod-style exchange
        defaultKm = 0.01 %millimoles/cm^3. The default Km value for Monod-style exchange
        defaultReactionLower = -1000
        defaultReactionUpper = 1000
        defaultVmax = 10 %moles/g/hr. The default Vmax value for Monod-style exchange
        defaultW = 10 %The default W coefficient (plateau) for the Pseudo-Monod style exchange
        numExRxnSubsteps = 10
        
        %Batch Dilution package parameters
        batchDilution = false
        dilFactor = 0.01
        dilTime = 24 %hours
        cellSize = 1e-9 %grams dry weight of an individual microbial cell. Must be larger than minSpaceBiomass
        
        %Evolution package parameters
        evolution = false
        mutRate = 1e-9 %rate for deletions
        addRate = 1e-5 %rate for reaction additions, turning on rxns with UB and LB == 0
        costlyGenome = false
        geneFractionalCost = 5e-8
        
        
        %Logging package params
        writeFluxLog = false %If true, writes fluxes out to a log file
        fluxLogName = './flux.m'
        fluxLogRate = 1 %How often (number of simulation steps) to write to the flux file. A value of 1 will cause writing after every step.
        writeMediaLog = false
        mediaLogName = './media.m'
        mediaLogRate = 1
        writeBiomassLog = false %if true, writes a summation of all biomass on a per-grid cell basis to a log file
        biomassLogName = './biomass.m'
        biomassLogRate = 1
        writeTotalBiomassLog = false %if true, writes a summation of all biomass information to a log file
        totalBiomassLogRate = 1
        totalBiomassLogName = './total_biomass.m'
        useLogNameTimeStamp = false %If true, appends a time stamp to every log file name
        writeMatFile = false %If true, writes a .mat files of everything
        MatFileName = './comets_log.mat'
        %genotypeLogName: There is currently no logging parameter set for Genotypes, the name is 'GENOTYPES_' + biomassLogName
    end
    
    methods
        %constructor
        function self = CometsParams()
        end
    end
    
end


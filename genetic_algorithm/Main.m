% Uday Tripathi 7/2016
% Main class: Runs the entire algorithm iteratively
classdef Main
    properties
        generationNum=1; % The current generation number; 1 by default
        generation=[]; % The sets of genomes per generation
        models=[]; % The models that the genomes draw from
        mets=[]; % The metabolites that the genomes draw from
    end
    
    methods
        % Called before initGenomes(). Sets the models field for the main
        function self=initModels(self,models)
            self.models=models;
        end
        
        % Called before initGenomes(). Sets the mets field for the main
        function self=initMets(self,mets)
            self.mets=mets;
        end
        
        % Initializes the genomes. Called once to begin the algorithm.
        % Called before run()
        % Input:
        % numGenomes = the number of genomes each generation is to have
        % numOfMets = the number of metabolites that are in each genome
        % numOfModels = the number of models that are in each genome
        function self=initGenomes(self, numGenomes, numOfMets, numOfModels)
            modelsInUse=zeros(numGenomes)
            for i=1:numGenomes
                % Generates random sequence of metabolites from the
                % possible list
                firstMet=randi([1,length(self.mets)-numOfMets]);
                lastMet=firstMet+numOfMets-1;
                metabolites=self.mets(firstMet:lastMet);
                
                firstModel=randi([1,length(self.models)-numOfMets]);
                % Ensures that same set of models is not in multiple
                % genomes to begin
                while intersect((firstModel:firstModel+numOfModels),modelsInUse)~=0
                    firstModel=randi([1,length(self.models)-numOfMets]);
                end
                
                % Generates random sequence of models from the possible
                % list
                lastModel=firstModel+numOfModels-1;
                modelNames=self.models(firstModel:lastModel);
                modelsInUse(i)=firstModel;
                
                % Creates each genome for each slot in a generation
                tempGenome=Genome();
                tempGenome=tempGenome.addMetsAndModels(metabolites,modelNames);
                
                % Sets the inital bounds for Cobra as intended 
                % The used metabolites are set bounds to -1000/1000 while
                % the metabolites not used in model are set to bounds 0
                tempGenome=changeMetLevels(self.mets,tempGenome);
                
                tempGenome=tempGenome.getScore();
                tempList(i)=tempGenome;
            end
            self.generation{1}=tempList;
        end
       
        % Generates the next generation of genomes by calling breed and
        % making the appropriate changes in the generation field
        % Input
        % numStaySame = the number of genomes that are to stay intact when
        % selecting highest scoring genomes to reproduce directly
        % newMets = the list of possible metabolites that can replace
        % metabolites in a genome via mutation
        % numCross = the number of cross-bred genomes to be present in each
        % generation
        function self=nextGeneration(self, numStaySame, newMets, numCross)
            currLength=length(self.generation);
            oldGenome=self.generation{currLength};
            tempGenome=breed(oldGenome,numStaySame,newMets,numCross,self.mets);
            self.generation{currLength+1}=tempGenome;
            self.generationNum=self.generationNum+1;
        end
        
        % Runs the algorithm iteratively, automatically recording and
        % returning results
        % Input:
        % maxCycles = the number of generations the algorithm is intended
        % to run for
        % newMets = the set of new metabolites that could replace others in
        % the genome via mutation
        % numCross = the number of cross-bred genomes to be present in each
        % generation
        function self=run(self,maxCycles,numStaySame,newMets,numCross)
            for i=1:maxCycles-1
               self=self.nextGeneration(numStaySame,newMets,numCross); 
            end
        end
    end
    
    
end
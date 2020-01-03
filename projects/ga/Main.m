% Uday Tripathi 7/2016
% Main class: Runs the entire algorithm iteratively

% Standard Protocol to set up GA
% main=Main()
% main=main.initModels(models)
% main=main.initMets(mets)
% main=main.initGenomes(numGenomes,numMets,numModels)
% main=main.run(self,maxCycles,numStaySame,newMets,newModels,numCross,type,excRxn)
% type: 'Cobra' or 'Comets'
% excRxn: 'EX Nitrite e0'
classdef Main
    properties
        generationNum=1; % The current generation number; 1 by default
        generation=[]; % The sets of genomes per generation
        models=[]; % The models that the genomes draw from
        mets=[]; % The metabolites that the genomes draw from
        hashMap;
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
             self.hashMap=containers.Map;
            
            modelsInUse=zeros(numGenomes);
            for i=1:numGenomes
                % Generates random sequence of metabolites from the
                % possible list
                firstMet=randi([1,length(self.mets)-numOfMets]);
                lastMet=firstMet+numOfMets-1;
                metabolites=self.mets(firstMet:lastMet);
                
                modelsInUse=zeros(numOfModels);
                for j=1:numOfModels
                    tempModel=randi([1,length(self.models)-numOfMets]);
                    while(sum(find(tempModel==modelsInUse))~=0) % Ensures 
                        % that each model is only used once in a sequence
                        tempModel=randi([1,length(self.models)-numOfMets]);
                    end
                    modelsInUse(j)=tempModel;
                    modelRef(j)=tempModel;
                end
                % Creates each genome for each slot in a generation
                tempGenome=Genome();
                tempGenome=tempGenome.addMetsAndModels(metabolites,modelRef);
                
                tempList(i)=tempGenome;
            end
            self.generation{1}=tempList;
        end
        
        % type = 'Cobra' or 'Comets'
        function self=runGeneration(self, type, excRxn,newMets)
            if strcmp(type,'Cobra')==1
                self=runCobra(self, excRxn,newMets);
            elseif strcmp(type,'Comets')
                % TODO: COMETS implementation
            else
            end
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
        function self=nextGeneration(self, numStaySame, newMets, newModels, numCross)
            currLength=length(self.generation);
            oldGenomes=self.generation{currLength};
            tempGenome=breed(oldGenomes,numStaySame,newMets,newModels,numCross);
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
        % generation + 1
        function self=run(self,maxCycles,numStaySame,newMets,newModels,numCross,type,excRxn)
            self=self.runGeneration(type, excRxn, newMets);
            for i=1:maxCycles-1
                self=self.nextGeneration(numStaySame,newMets,newModels,numCross);
                self=self.runGeneration(type,excRxn,newMets);
            end
        end
        
        % Runs each model through COBRA optimization and adds up scores
        function self=runCobra(self,excRxn,newMets)
            genomeSet=self.generation{self.generationNum};
            for i=1:length(genomeSet)
                genome=self.generation{self.generationNum}(i);
                numModels=length(genome.sequence)-genome.endOfMets;
                hashCode=hash(genome,self.mets, newMets);
                if isKey(self.hashMap,hashCode)==1 % Checks if genome is already in hashmap
                    genome.score=self.hashMap(hashCode);
                else
                    metsToKeep=genome.sequence(1:genome.endOfMets);
                    fluxScore=0;
                    for j=genome.endOfMets+1:length(genome.sequence);
                        modelIndex=genome.sequence{j};
                        while (ischar(modelIndex)==1) % if knockout occured, move to next index
                           j=j+1;
                           modelIndex=genome.sequence{j};
                        end
                        if isempty(modelIndex)==1 % if knockout occurred at that position
                            fluxScore=fluxScore+0;
                        else
                            model=self.models{modelIndex};
                            fluxScore=fluxScore+cobraFlux(self,model,excRxn,metsToKeep,numModels); 
                        end
                    end
                    genome.score=(abs(fluxScore)/numModels);
                    self.hashMap(hashCode)=abs((fluxScore)/numModels);
                end
                self.generation{self.generationNum}(i)=genome;
            end
        end
        
        % Same as lookForFlux
        function score=cobraFlux(self,model,exchangeReaction,metsToKeep,numModels)
            model=changeMetLevels(model,self.mets,metsToKeep,numModels);
            score=0;
            indexOfRxn=strmatch(exchangeReaction,model.rxnNames);
            if (isempty(indexOfRxn)==0)
                temp=model.S(:,indexOfRxn);
                tempArr=nonzeros(temp);
%                 opt=optimizeCbModel(model,'max',0,true);
                rxnTrueName = model.rxns(indexOfRxn);
                [fmin, fmax, vmin, vmax] = fluxVariability(model,100,'max',{rxnTrueName});
%                 flux=opt.x(indexOfRxn);
                flux=fmin;
                for i=1:length(tempArr)
                    score=score+tempArr(i);
                end
                score=score*flux;
                score=abs(score); 
            else
                score=0;
            end
        end
        
        % Generates tables with hashes and scores from the entire genome
        % set
        function table=getResults(self, fileName)
           table=hashTab(self.hashMap.keys,self.hashMap.values);
           writetable(table,fileName);
        end
    end
end


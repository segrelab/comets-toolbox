
classdef Main
    properties
        generationNum=1;
        generation=[];
        models=[];
        mets=[];
    end
    
    methods
        function self=initModels(self,models)
            self.models=models;
        end
        
        function self=initMets(self,mets)
            self.mets=mets;
        end
        
        % DONE: Make mets/models different #s 
        function self=initGenomes(self, numGenomes, numOfMets, numOfModels)
            for i=1:numGenomes
                firstMet=randi([1,length(self.mets)-numOfMets]);
                lastMet=firstMet+numOfMets-1;
                metabolites=self.mets(firstMet:lastMet);
                
                firstModel=randi([1,length(self.models)-numOfMets]);
                lastModel=firstModel+numOfModels-1;
                modelNames=self.models(firstModel:lastModel);
                
                tempGenome=Genome();
                tempGenome=tempGenome.addMetsAndModels(metabolites,modelNames);
                
                tempGenome=changeMetLevels(self.mets,tempGenome);
                
                tempGenome=tempGenome.getScore();
                tempList(i)=tempGenome;
            end
            self.generation{1}=tempList;
        end
       
        function self=nextGeneration(self, numStaySame, newMets, numCross)
            currLength=length(self.generation);
            oldGenome=self.generation{currLength};
            % oldGenome=oldGenome{self.generationNum};
            tempGenome=breed(oldGenome,numStaySame,newMets, numCross);
            self.generation{currLength+1}=tempGenome;
            self.generationNum=self.generationNum+1;
        end
        
        function self=run(self,maxCycles,numStaySame,newMets,numCross)
            for i=1:maxCycles-1
               self=self.nextGeneration(numStaySame,newMets,numCross); 
            end
        end
    end
    
    
end

classdef Main
    properties
        generationNum=0;
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
        
        % TODO: Make mets/models different #s
        function self=initGenomes(self, numGenomes,numOfEach)
            for i=1:numGenomes
                firstMet=randi([1,length(self.mets)-numOfEach]);
                lastMet=firstMet+numOfEach-1;
                metabolites=self.mets(firstMet:lastMet);
                
                firstModel=randi([1,length(self.models)-numOfEach]);
                lastModel=firstModel+numOfEach-1;
                modelNames=self.models(firstModel:lastModel);
                
                tempGenome=Genome();
                tempGenome=tempGenome.addMetsAndModels(metabolites,modelNames);
                tempGenome=tempGenome.getScore();
                tempList(i)=tempGenome;
            end
            self.generation{1}=tempList;
        end
       
        function self=nextGeneration(self, numStaySame, newMets)
            currLength=length(self.generation);
            oldGenome=self.generation(currLength);
            oldGenome=oldGenome{1};
            tempGenome=breed(oldGenome,numStaySame,newMets);
            self.generation{currLength+1}=tempGenome;
            self.generationNum=self.generationNum+1;
        end
    end
    
    
end

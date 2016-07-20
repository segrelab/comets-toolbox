classdef Genome
    properties
        score=0;
        sequence={};
        endOfMets=0;
    end
    
    methods
        function self=getScore(self)
            self.score=randi([1,10]); % TODO
        end

        function self=addMetsAndModels(self, metInput, models)
            for i=1:length(metInput)
                self.sequence{i}=metInput{i};
                self.endOfMets=self.endOfMets+1;
            end
            
            counter=1;
            for j=length(metInput)+1:length(models)+length(metInput)
                self.sequence{j}=models{counter};
                counter=counter+1;
            end
        end

    end
end
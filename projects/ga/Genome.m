% Uday Tripathi 7/2016
% Genome class. Responsible for each sequence within the main class that
% runs the algorithm
classdef Genome
    properties
        score=0; % the fitness score of specified genome
        sequence={}; % the sequence of metabolites and models in the genome
        endOfMets=0; % the position of the last metabolite in the sequence
    end
    
    methods
        % Adds metabolites and models to the genome's sequence
        % Input:
        % metInput = the metabolites to be entered into the sequence
        % models = the models to be entered into the sequence
        function self=addMetsAndModels(self, metInput, models)
            for i=1:length(metInput)
                self.sequence{i}=metInput{i};
                self.endOfMets=self.endOfMets+1;
            end
            
            counter=1;
            for j=length(metInput)+1:length(models)+length(metInput)
                self.sequence{j}=models(counter);
                counter=counter+1;
            end
        end

    end
end
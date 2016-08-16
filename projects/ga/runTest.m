% Uday Tripathi 7/2016

% Used for testing purposes, not used in algorithm
%excRxn='EX Nitrite e0'
function tempGenome=runTest(genome, models, mets, excRxn)
    for i=genome.endOfMets+1:length(genome.sequence)
        tempGenome=genome;
        % tempGenome=changeMetLevels(self.mets,tempGenome);     
        fluxScore=0;
        for i=genome.endOfMets+1:length(genome.sequence);
            modelIndex=genome.sequence{i};
            model=models{modelIndex};
            fluxScore=fluxScore+lookForFlux(model,excRxn); 
        end
    end
    tempGenome.score=fluxScore;
    
end
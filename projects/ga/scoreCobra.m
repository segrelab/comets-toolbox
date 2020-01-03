% Uday Tripathi 7/2016

function score=scoreCobra(genome,excRxn)
        score=0;
        seq=genome.sequence;
        fluxScore=0;
        for j=genome.endOfMets+1:length(seq)
            model=genome.sequence{j};
            fluxScore=fluxScore+lookForFlux(model, excRxn);
        end
        score=fluxScore;
end
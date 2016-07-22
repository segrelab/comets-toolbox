function score=scoreCobra(genome,excRxn)
%     genomes=main.generation{1};
%     scores={};
%     
%     for i=1:length(genomes)
%         seq=genomes(i).sequence;
%         fluxScore=0;
%         for j=genomes(i).endOfMets+1:length(seq)
%             model=genomes(i).sequence{j};
%             fluxScore=fluxScore+lookForFlux(model, excRxn);
%         end
%         scores{i}=fluxScore;
%     end

        score=0;
        seq=genome.sequence;
        fluxScore=0;
        for j=genome.endOfMets+1:length(seq)
            model=genome.sequence{j};
            fluxScore=fluxScore+lookForFlux(model, excRxn);
        end
        score=fluxScore;
end
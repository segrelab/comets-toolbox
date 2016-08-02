function scores=plotFitnessLandscape(main, numGens)
    for i=1:numGens
        genomes=main.generation{i};
        maxScore=findMaxScore(genomes);
        scores(i)=maxScore;
    end
    plot(scores);
end

function score=findMaxScore(genomeGen)
    maxScore=0;
    for j=1:length(genomeGen)
        tempGenome=genomeGen(j);
        if tempGenome.score > maxScore
           maxScore=tempGenome.score; 
        end
    end
    score=maxScore;
end
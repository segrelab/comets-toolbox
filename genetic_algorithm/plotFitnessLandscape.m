function scores=plotFitnessLandscape(main, color)
    for i=1:main.generationNum;
        genomes=main.generation{i};
        maxScore=findMaxScore(genomes);
        scores(i)=maxScore;
    end
    plot(scores,color);
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
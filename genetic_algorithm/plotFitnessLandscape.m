% Uday Tripathi 7/2016

% Used to generate results, takes highest scorers from each generation and
% plots their scores to generate fitness landscapes
function scores=plotFitnessLandscape(main, color, gens)
    for i=1:gens;
        genomes=main.generation{i};
        maxScore=findMaxScore(genomes);
        scores(i)=maxScore;
    end
    plot(scores,color);
    axis([1,gens,0,1000]);
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
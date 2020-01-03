% Uday Tripathi 7/2016

% Plots all the scores of every genome in every generation in the form of a
% scatter plot
function plotScatter(main)
    for i=1:main.generationNum
       genomes=main.generation{i};
       for j=1:length(genomes)
          genome=genomes(j);
          scatter(i,genome.score);
          hold all;
       end
    end
end

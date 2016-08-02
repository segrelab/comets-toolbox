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

% scatter(x(1),data1(1));
% hold all;
% scatter(x(1),data1(2));
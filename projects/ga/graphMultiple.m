% Uday Tripathi 7/2016

% Can be used to generate multiple fitness landscapes, parameters can be
% modified, Used for generating results from GA

colors={'y','b','c','r','g'};

for i=1:5
   main=Main();
   main=main.initModels(models);
   main=main.initMets(mets);
   main=main.initGenomes(20,3,3);
   main=main.run(20,10,newMets,newModels,8,'Cobra','EX Nitrite e0');
   color=colors{i};
   plotFitnessLandscape(main,color,20);
   hold all;
end
savedMain=Main();
savedMain=savedMain.initModels(models);
savedMain=savedMain.initMets(mets);
savedMain=savedMain.initGenomes(10,3,3);

colors=['y' 'm' 'c' 'r' 'g' 'b'];

for i=1:7
    main=savedMain;
    main=main.run(10,3,newMets,newModels,i-1,'Cobra','EX Nitrite e0');
    plotFitnessLandscape(main,colors(i));
    hold on;
end

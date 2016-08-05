savedMain=Main();
savedMain=savedMain.initModels(models);
savedMain=savedMain.initMets(mets);
savedMain=savedMain.initGenomes(30,3,3);

colors=['y' 'm' 'c' 'r' 'g' 'b'];

for i=10:20
    main=savedMain;
    main=main.run(10,3,newMets,newModels,i,'Cobra','EX Nitrite e0');
    plotFitnessLandscape(main,colors(i));
    hold on;
end

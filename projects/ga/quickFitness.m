% Uday Tripathi 7/2016

% Testing method, not used in GA
function main=quickFitness(numOfGenomes, numOfGenerations)
    getModels();
    models={K1,K1A,K2,K3,K4,K5,K6,K7,K8,K9,K9A,K10,K11,K12,K13,K14,K15,K16,K17,K18,K19,K20,K21,K22};
    mets={'EX D-Glucose e0','EX Sucrose e0','EX Maltose e0', 'EX D-Fructose e0', 'EX D-Mannose e0','EX Dulcose e0'};
    newModels=models(10:20);
    newMets=mets;

    main=Main();
    main=main.initModels(models);
    main=main.initMets(mets);
    main=main.initGenomes(numOfGenomes,3,3);
    main=main.run(numOfGenerations,numOfGenomes/2,newMets,newModels,numOfGenomes/4,'Cobra','EX Nitrite e0');
end
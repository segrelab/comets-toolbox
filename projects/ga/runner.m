% Uday Tripathi 7/2016

% Used to generate large number of data points in algorithm
masterHash=containers.Map;
for i=1:50
main=Main();
main=main.initModels(models);
main=main.initMets(mets);
main=main.initGenomes(50,3,3);
main.hashMap=masterHash;
main=main.run(50,25,newMets,newModels,15,'Cobra','EX Nitrite e0');
masterHash=main.hashMap;
end
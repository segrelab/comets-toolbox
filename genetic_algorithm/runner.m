for i=1:15
main=Main();
main=main.initModels(models);
main=main.initMets(mets);
main=main.initGenomes(20,3,3); 
main.hashMap=masterHash;
main=main.run(10,10,newMets,newModels,5,'Cobra','EX Nitrite e0');
masterHash=main.hashMap;
end
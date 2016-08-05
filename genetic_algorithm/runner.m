masterHash=containers.Map;
for i=1:50
main=Main();
main=main.initModels(models);
main=main.initMets(mets);
main=main.initGenomes(20,3,3);
main.hashMap=masterHash;
rand1=randi([3,10]);
rand2=20-rand1-randi([1,9]);
main=main.run(50,rand1,newMets,newModels,rand2,'Cobra','EX Nitrite e0');
masterHash=main.hashMap;
end
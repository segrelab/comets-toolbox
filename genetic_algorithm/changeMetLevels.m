function y=changeMetLevels(mets,genome)

% strfind(K1.rxnNames,'glu')
% x=find(~cellfun(@isempty,ans))
% s=strfind(K1.rxnNames,'e0')
% y=find(~cellfun(@isempty,s))
% intersect(x,y)

%strmatch(rxnName,model.rxnNames)
%model.ub(ans)

models=genome.sequence{genome.endOfMets+1:length(genome.sequence)};
metsToKeep=genome.sequence(1:genome.endOfMets);
counter=genome.endOfMets+1;
for i=1:length(models)
    tempModel=models(i);
    idList={};
    for j=1:length(mets)
        rxnIndex=strmatch(mets(i),tempModel.rxnNames);
        rxnId=tempModel.rxns(rxnIndex);
        idList=[idList,rxnId];
    end
    tempModel=changeRxnBounds(tempModel,idList,0,'b');
    
    incList={};
    for r=1:length(metsToKeep)
        rxnIndex=strmatch(metsToKeep(r),tempModel.rxnNames);
        rxnId=tempModel.rxns(rxnIndex);
        incList=[incList,rxnId];
    end
    tempModel=changeRxnBounds(tempModel,incList,1000,'u');
    tempModel=changeRxnBounds(tempModel,incList,-1000,'l');
    
    genome.sequence{counter}=tempModel;
    counter=counter+1;    
end
y=genome;
end
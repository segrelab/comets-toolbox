function y=createGALayout(genome)
    layout=CometsLayout();
    for i=genome.endOfMets+1:length(genome.sequence)
        model=genome.sequence{i};
        layout=layout.addModel(model);
    end
    
    modelForIndex=genome.sequence{genome.endOfMets+1};
    
    for j=1:genome.endOfMets
        index=strmatch(genome.sequence(j),modelForIndex.metNames);
        %idName=modelForIndex.mets(index);
        %mediaNum=strmatch(idName,layout.mets);
        layout.media_amt(index)=1000;
    end
    
    y=layout;
end
% Uday Tripathi 7/2016
% Sample excRxn: 'EX Nitrite e0'
% Workflow: a=load(model) a=a.model lookForFlux(model,exchangeReaction)

function score=lookForFlux(model,exchangeReaction,mets)
    model=changeMetLevels(model,mets);

    score=0;
    
    indexOfRxn=strmatch(exchangeReaction,model.rxnNames);
    if (isempty(indexOfRxn)==0)
        temp=model.S(:,indexOfRxn);
        tempArr=nonzeros(temp);
        opt=optimizeCbModel(model,'max',0,true);
        flux=opt.x(indexOfRxn);
        
        for i=1:length(tempArr)
            score=score+tempArr(i);
        end
        
        score=score*flux;
    else
        score=0;
    end
end
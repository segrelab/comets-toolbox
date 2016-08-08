function [bounds, scores, objs] = carbonSourceScaling(useMets)
%An experiment to see if the relationship between carbon influx and nitrate
%efflux in Cobra models is nonlinear

%mets={'EX D-Glucose e0','EX Sucrose e0','EX Maltose e0', 'EX D-Fructose e0', 'EX D-Mannose e0'}
allMets = {'Glucose','Sucrose','Maltose','Fructose','Mannose','Glutamate',...
    'Dulcose','Glycerol','D-Mannose','Maltohexaose','Xylose','Taurine',...
    'Sorbitol','Arabinose','Lactate','glucose','sucrose','maltose',...
    'Fructose','Mannose','Glutamate','dulcose','glycerol',...
    'Maltohexaose','Xylose','Taurine','Sorbitol','Arabinose','Lactate'};
model=load('C:\Users\udayt.AD\Desktop\Kolenbrander_MATLAB\K9_HOMD_GF24325_Actinomyces_naeslundii.mat');
%loaded as 'model'

bounds = 0:20;
exchangeRxn = 'EX Nitrite e0';
%useMets = {'Sucrose' '' ''};

%get the score for each bound
[scores,objs] = arrayfun(@(b) scoreAtScale(model,allMets,useMets,b,exchangeRxn),bounds);

end

%modified from changeMetLevels to include the 'bound' parameter
function modModel=changeMets(model,mets,metsToKeep,bound)
metsToKeep=metsToKeep(~cellfun('isempty',metsToKeep));
tempModel=model;
idList={};
for j=1:length(mets)
    rxnIndex=strmatch(mets{j},tempModel.rxnNames);
    rxnId=tempModel.rxns(rxnIndex);
    if ~cellfun('isempty',rxnId) %found at least one ID
        idList=[idList rxnId{:}];
    end
end
tempModel=changeRxnBounds(tempModel,idList,0,'b');
incList={};
for r=1:length(metsToKeep)
    rxnIndex=strmatch(metsToKeep(r),tempModel.rxnNames);
    rxnId=tempModel.rxns(rxnIndex);
    incList=[incList,rxnId{:}];
end
tempModel=changeRxnBounds(tempModel,incList,bound,'u');
tempModel=changeRxnBounds(tempModel,incList,-bound,'l');
modModel=tempModel;
end

%set the bounds for each of the n metabolites in {mets} to bound/n then get
%the output flux
function [score, obj] = scoreAtScale(model, allMets, useMets, bound, exchangeRxn)
%set the bounds
bound = bound;
model = changeMets(model,allMets,useMets,bound);

%from lookForFlux()
score=0;
indexOfRxn=strmatch(exchangeRxn,model.rxnNames);
if (isempty(indexOfRxn)==0)
    temp=model.S(:,indexOfRxn);
    tempArr=nonzeros(temp);
    opt=optimizeCbModel(model,'max',0,true);
    %flux=opt.x(indexOfRxn);
    obj = opt.f;
    
    rxnTrueName = model.rxns(indexOfRxn);
    [fmin, fmax, vmin, vmax] = fluxVariability(model,100,'max',{rxnTrueName});
    flux = fmax;
    
    for i=1:length(tempArr)
        score=score+tempArr(i);
    end
    
    score=score*flux;
else
    score=-10000; %Broken: worse than otherwise possible
end
end
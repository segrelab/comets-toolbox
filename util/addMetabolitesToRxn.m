function model = addMetabolitesToRxn( model, mets, rxnname, stoich)
%ADDMETABOLITETORXN CobraModel [MetNames] RxnName [Stoich]
%   Add the given metabolites to the reaction
%   If any of the listed metabolites are already present, they will not be
%   changed
% Input args:
%model:  a Cobra-format model struct
%mets: a single metabolite name or a cell array of names
%rxnname: the name of a single reaction in the given model, OR the index of a reaction
%stoich: an array of stoichiometries corresponding 1:1 to the given metabolites, OR a single value that will be applied to all metabolites


%First, check if any mets have to be added to the model
newmets = {};
if iscell(mets)
    tstoich = stoich;
    if length(stoich) == 1
        tstoich(1:length(mets)) = stoich(1); %extend the stoich if one value is used for many mets
    end
    for i = 1:length(mets)
        if ~any(strcmp(model.mets,mets{i}))
            newmets = [newmets; mets{i}];
        end
    end
elseif ischar(mets)
    if ~any(strcmp(model.mets,mets))
        newmets = {mets};
    end
    mets = {mets}; %gurantee it's a cell for downstream
end

if ~isempty(newmets)
    for i = 1:length(newmets)
        warning(['Adding metabolite ' newmets{i} ' to the model ' getModelName(model)]);
        model = addMetabolite(model,newmets{i});
    end
end

%identifying the reaction
rxnidx = 0;
if isnumeric(rxnname)
    rxnidx = rxnname;
    rxnname = model.rxns{rxnidx};
elseif ischar(rxnname)
    rxnidx = find(strcmp(rxnname,model.rxns),1);
elseif iscell(rxnname)
    rxnname = rxnname{1};
    rxnidx = find(strcmp(rxnname,model.rxns),1);
end


%Do the work

% rxnmetidxs = findMetsFromRxns(model,rxnname);
% rxnmetnames = model.mets(rxnmetidxs);
rxnmetnames = findMetsFromRxns(model,rxnname);
rxnmetidxs = zeros(1,length(rxnmetnames));
for i = 1:length(rxnmetnames)
    rxnmetidxs(i) = stridx(rxnmetnames{i},model.mets,false);
end
rxnmetstoich = model.S(rxnmetidxs,rxnidx);

newmetnames = [rxnmetnames; mets];
newrxnstoich = [rxnmetstoich; stoich];


for i = 1:length(rxnmetnames)
    rxnmetname = rxnmetnames{i};
    if any(strcmp(rxnmetname,mets)) %this met has a new stoich
        newrxnstoich(i) = stoich(strcmp(rxnmetname,mets)); %possibly redundant, but leave in case an old met is being given a new stoich
    end
end
    


model = changeRxnMets(model,rxnmetnames, newmetnames, rxnname, newrxnstoich);

end


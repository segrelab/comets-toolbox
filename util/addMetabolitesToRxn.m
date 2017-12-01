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


%parse the arguments
newmets = {};
newstoich = [];
if iscell(mets)
    tstoich = stoich;
    if length(stoich) == 1
        tstoich(1:length(mets)) = stoich(1);
    end
    for i = 1:length(mets)
        if ~any(strcmp(model.mets,mets{i}))
            newmets = [newmets; mets{i}];
            newstoich = [newstoich; tstoich(i)];
        else
            warn(['Metabolite ' mets{i} ' is already present in reaction ' rxnname]);
        end
    end
elseif ischar(mets)
    if ~any(strcmp(model.mets,mets))
        newmets = {mets};
        newstoich = stoich(1);
    end
end
rxnidx = 0;
if isnumeric(rxnname)
    rxnidx = rxnname;
    rxnname = model.rxns(rxnname);
elseif ischar(rxnname)
    rxnidx = find(strcmp(model.rxns,rxnname),1);
end


%Do the work
model = addMetabolite(model,newmets);
rxnmetidxs = findMetsFromRxns(model,rxnname);
rxnmetnames = model.mets(rxnmetidxs);
rxnmetstoich = model.S(rxnmetidxs,rxnidx);
newmetnames = [rxnmetnames; newmets];
newrxnstoich = [rxnmetstoich; newstoich];
model = changeRxnMets(model,rxnmetnames, newmetnames, rxnname, newrxnstoich);

end


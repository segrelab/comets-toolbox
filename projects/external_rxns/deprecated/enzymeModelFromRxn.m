function pseudo = enzymeModelFromRxn(varargin)
% ENZYMEMODELFROMRXN Given a model, a reaction, and the name of an enzyme
% metabolite, create a model for a pseudoorganism that carries out the same
% reaction 
% usage: enzymeModelFromRxn( model, reaction, enzyme )
%     model: a COBRA model reaction: the String name of the base reaction,
%     as in model.rxns enzyme: the String name of the enzyme metabolite, as
%     in model.mets

if nargin < 3
    error(['Inputs for enzymeModelFromRxn should be a COBRA model,'...
        ' the name or index of a reaction, and the name of an enzyme metabolite.']);
end

model = varargin{1};

if ischar(varargin{2})
    rxnName = char(varargin{2});
    rxnIdx = find(ismember(model.rxns,rxnName));
    %make sure we get exactly 1 match
    if length(rxnIdx) < 1
        error(['Could not find a reaction called ' rxnName ' in the'...
            ' given model.']);
    end
    if length(rxnIdx) > 1
        error(['Found multiple matches for the reaction name ' rxnName]);
    end
elseif isnumeric(varargin{2})
    rxnIdx = varargin{2};
    rxnName = char(model.rxns(rxnIdx));
else
    error(['The second arugment for enzymeModelFromRxn should be the'...
        ' name or index of a reaction in the given model']);
end

enzmet = varargin{3};

%create the model
pseudo = createModel();
pseudo.description = ['Enzyme psuedoorganism ' enzmet ' (' rxnName ')'];

%copy the relevent reaction details
s = model.S(:,rxnIdx); %stoichiometry as a sparse column 
metIdxs = find(s); %index of involved metabolites
stoich = s(metIdxs); %flatten stoichiometry column
mets = model.mets(metIdxs); %metabolite names
rev = model.rev(rxnIdx);
lb = model.lb(rxnIdx);
ub = model.ub(rxnIdx);
rule = model.rules(rxnIdx);
rxnReference = model.rxnReferences(rxnIdx);
rxnECNumber = model.rxnECNumbers(rxnIdx);
grRule = model.grRules(rxnIdx);
metFormulas = model.metFormulas(metIdxs);
metCharge = model.metCharge(metIdxs);
metKEGGID = model.metKEGGID(metIdxs);
metChEBIID = model.metChEBIID(metIdxs);
metInChIString = model.metInChIString(metIdxs);
b = model.b(metIdxs);

pseudo = addReaction(pseudo, rxnName, mets, stoich, rev, lb, ub);
pseudo.rules(1) = rule;
pseudo.rxnReferences(1) = rxnReference;
pseudo.rxnECNumbers(1) = rxnECNumber;
pseudo.grGrules(1) = grRule;
pseudo.metFormulas = metFormulas;
pseudo.metCharge = metCharge;
pseudo.KEGGID = metKEGGID;
pseudo.metChEBIID = metChEBIID;
pseudo.metInChIString = metInChIString;
pseudo.b = b;

%add exchange reactions
pseudo = addExchangeRxn(pseudo,mets);
pseudo = addExchangeRxn(pseudo,enzmet);
%TODO: if there aren't any rxns already to compare max/min bounds, will
%this still work?
%pseudo = addDemandReaction(pseudo,enzmet);

%biomass reaction
pseudo = addReaction(pseudo,'biomass',enzmet,-1,0);

%optimize the reaction as well as the biomass
pseudo = changeObjective(pseudo,{rxnName,'biomass'});


function modModel=changeMetLevels(model,block,retain,numModels)
%CHANGEMETLEVELS Set the uptake reaction rate to 0 for all metabolites in
%%{block}, and set appropriate bounds to the uptake reactions for all
%metabolites in {retain}
%model a Cobra model to be modified
%block cell array of metabolite names for which influx reactions will be
%blocked
%retain cell array of metabolite names for which influx will occur
%numModels number of models present in the current Genome

% Uday Tripathi 7/2016
%     otherMets={'EX Allose e0', 'EX Altrose e0', 'EX Gulose e0', 'EX Idose e0',...
%         'EX Galactose e0', 'EX Talose e0', 'EX Psicose e0’, ‘EX Sorbose e0',...
%         'EX Tagatose e0', 'EX L-Arabinose e0', 'EX D-Arabinose e0', 'EX Lyxose e0',...
%         'EX Ribose e0', 'EX Xylose e0', 'EX Ribulose e0', 'EX Xylulose e0’‘EX Lactulose e0',...
%         'EX Lactose e0', 'EX Trehalose e0', 'EX Cellobiose e0', 'EX Chitobiose e0',...
%         'EX Kojibiose e0', 'EX Nigerose e0', 'EX Isomaltose e0', 'EX Trehalose e0',...
%         'EX Sophorose e0', 'EX Laminaribiose e0’, ‘EX Gentiobiose e0', 'EX Turanose e0',...
%         'EX Maltulose e0', 'EX Palatinose e0', 'EX Gentiobiulose e0’, ‘EX Mannobiose e0',...
%         'EX Melibiose e0', 'EX Melibiulose e0', 'EX Rutinose e0', 'EX Rutinulose e0',...
%         'EX Xylobiose e0', 'EX Arabitol e0', 'EX Dulcitol e0', 'EX Erythritol e0',...
%         'EX Galactitol e0', 'EX Glucitol e0', 'EX Glycerol e0', 'EX Isomalt e0',...
%         'EX Inositol e0', 'EX Lactitol e0', 'EX Maltitol e0', 'EX Mannitol e0',...
%         'EX Sorbitol e0', 'EX Xylitol e0'};

retain=retain(~cellfun('isempty',retain));
bounds=10/numModels;
tempModel=model;
idList={};
for j=1:length(block) % Finds all the block to turn off
    rxnIndex=strmatch(block{j},tempModel.rxnNames);
    rxnId=tempModel.rxns(rxnIndex);
    idList=[idList,rxnId];
end
tempModel=changeRxnBounds(tempModel,idList,0,'b');

incList={};
for r=1:length(retain) % Turns selected block on
    rxnIndex=strmatch(retain(r),tempModel.rxnNames);
    rxnId=tempModel.rxns(rxnIndex);
    incList=[incList,rxnId];
end
tempModel=changeRxnBounds(tempModel,incList,bounds,'u');
tempModel=changeRxnBounds(tempModel,incList,-bounds,'l');
modModel=tempModel;
end

%Add an external reaction to the given layout
%@author mquintin 5/8/2017
function layout = addExternalReaction(layout, rxnName, metabolites, stoichiometries, varargin)
%Usage: layout = addExternalReaction(layout, rxnName, metabolites{},
%stoichiometries[], ['enzyme', enzymeName], ['k', rxnRate], ['km',
%michaelisConstant]


t.rxns = layout.external_rxns;
t.mets = layout.external_rxn_mets;
% % % %initialize the tables if empty
% % % if isempty(t.rxns)
% % %     t.rxns = cell2table({'TEMP_INIT_REACTION',0,'TEMP_MET',0});
% % %     t.rxns.Properties.VariableNames = {'name','k','enzyme','km'};
% % % end
% % % if isempty(t.mets)
% % %     t.mets = cell2table({'TEMP_INIT_REACTION','TEMP_MET',0});
% % %     t.mets.Properties.VariableNames = {'rxn','met','stoich'};
% % % end
% % % 
% % % %check that the reaction doesn't already exist
% % % if any(stridx(rxnName,t.rxns.name))
% % %     error(['The reaction "' rxnName '" already exists.']);
% % % end

%default values
enzyme = '';
k = layout.params.defaultVmax;
km = layout.params.defaultKm;

%parse optional arguments
for i = 1:2:length(varargin)
    switch upper(varargin{i})
        case 'ENZYME'
        %add an enzyme to the reaction
        enzyme = varargin{i+1};
        layout = addMetIfNotPresent(layout,varargin{i+1});
        case 'K'
        %set kcat/vmax
        k = varargin{i+1};
        case 'KM'
        %set Michaelis constant
        km = varargin{i+1};
    end
end

%add the reaction to the table
rxnrow = {rxnName, k, enzyme, km};
t.rxns = [t.rxns; rxnrow];

%add the metabolites to the table
if iscell(metabolites)
    for i = 1:length(metabolites)
        s = stoichiometries(i);
        metrow = {rxnName, metabolites{i}, s};
        t.mets = [t.mets; metrow];
        layout = addMetIfNotPresent(layout,metabolites(i));
    end
elseif ischar(metabolites)
    metrow = {rxnName, metabolites, stoichiometries(1)};
    t.mets = [t.mets; metrow];
    layout = addMetIfNotPresent(layout,{metabolites});
end

%make sure the column names are set correctly
t.rxns.Properties.VariableNames = {'name','k','enzyme','km'};
t.mets.Properties.VariableNames = {'rxn','met','stoich'};

% % %remove initialization rows
% % if any(stridx('TEMP_INIT_REACTION',t.rxns.name))
% %     tmp = stridx('TEMP_INIT_REACTION',t.rxns.name);
% %     t.rxns = t.rxns(1:length(t.rxns.name) ~= tmp,:);
% % end
% % if any(stridx('TEMP_INIT_REACTION',t.mets.rxn))
% %     tmp = stridx('TEMP_INIT_REACTION',t.rxns.name);
% %     t.rxns = t.rxns(1:length(t.mets.rxn) ~= tmp,:);
% % end

layout.external_rxns = t.rxns;
layout.external_rxn_mets = t.mets;


function layout = addMetIfNotPresent(layout, metname)
    ispresent = cellfun(@(arr) ~isempty(strfind(metname, arr)), layout.mets);
    if ~ispresent
        layout = addMets(layout,{metname});
    end
end

end
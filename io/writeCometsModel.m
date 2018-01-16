function f = writeCometsModel( input, filename, cometsParams)
%WRITECOMETSMODEL create a Comets input file for the given model
%   The third argument is optional, and can be used to override the default
%kinetic parameters declared in the CometsParams class

%Change how exchange reactions are defined:
% 1: by the S matrix
% 2: by name
exchangeMode = 1;

if isa(input,'string')
    strct=load(input);
    model=strct.(char(fieldnames(strct)));
else
    if isa(input,'struct')
        model=input;
    else
        error(['Invalid argument in writeCometsModel(' class(input)...
            ', ' class(filename) '): The first argument should '...
            'be a well-structured COBRA model or the path of a '...
            '.mat file containing one.']);
    end
end

%assert that the model is a well-structured COBRA model
%check for these fields: metNames, rxns, S, lb, ub, c, mets
for cf={'mets' 'rxns' 'S' 'lb' 'ub' 'c'}
    if ~isfield(model,cf)
        error(['Invalid argument in writeCometsModel(' class(input)...
            ', ' class(filename) '): The input model requires the '...
            'following fields: [mets, rxns, S, lb, ub, c].']);% Identified fields are ' [fieldnames(model)]']);
    end
end
        

clear exchange_rxnsIndex;
%exc_logical=findExcRxns(model, 1);%COBRA function returning a logical vector.
%NOTE: We don't use findExcRxns any more because of the 'inclObjFlag'
%argument, when either puts the objective into the list or leaves it out,
%regardless of whether it satisfies the conditions that define an exchange
%reaction
if exchangeMode == 1 %find by the S matrix
    exc_logical = findExcByS(model);
    exchange_rxnsIndex=find(exc_logical);
else %find by name
    exchange_rxnsIndex = stridx('EX_',model.rxns,true);
end

S=full(model.S);

[p, f, e] = fileparts(filename);
if ~exist(p)
    mkdir(p); %initialize the folder
end
fileID = fopen(filename,'w');

%Print the S matrix 
[sx, sy] = size(model.S);
if (sx + sy < 1)
    error('There must be at least one row in the Stoichiometrix Matrix');
end
fprintf(fileID,'SMATRIX  %d  %d\n',sx,sy);
for i=1:sx
    for j=1:sy
        if S(i,j)~=0
            fprintf(fileID,'    %d   %d   %f\n',i,j,S(i,j));
        end
    end
end

fprintf(fileID,'//\n');

%get the default flux and kinetic parameters
if nargin < 3
    %load defaults from the CometsParams class
    cometsParams = CometsParams(); 
end
defaults.ub = cometsParams.defaultReactionUpper;
defaults.lb = cometsParams.defaultReactionLower;
defaults.km = cometsParams.defaultKm;
defaults.vmax = cometsParams.defaultVmax;

%Print the bounds
fprintf(fileID,'BOUNDS  %d  %d\n',defaults.lb,defaults.ub);
for i=1:length(model.rxns)
    fprintf(fileID,'    %d   %f   %f\n',i,model.lb(i),model.ub(i));
end
fprintf(fileID,'//\n');

%find objective reaction
for i=1:length(model.c)
    if model.c(i) ~= 0
        objective=i;
    end
end

%find the objective reaction or reactions
%The absolute value of model.c should denote priority, with 1 being highest
%A negative number denotes that the reaction should be minimized
%Ex: if c = [0 0 3 0 -2 1], maximize r6, then minimize r5, then maximize r3
%   so the output line should be: "   6 -5 3"
objIdxs = find(model.c);
[objPriority, map] = sort(abs(model.c(objIdxs)));
objLine = '   ';
for i = 1:length(objPriority)
    idx = objIdxs(map(i));
    if (model.c(idx) < 0) 
        idx = -1 * idx;
    end
    objLine = [objLine ' ' num2str(idx)];
end
objLine = [objLine '\n'];
%Print the objective reaction
fprintf(fileID,'OBJECTIVE\n');
   fprintf(fileID,objLine); 
fprintf(fileID,'//\n');

%Print the Biomass reaction, if there are any true values in
%model.biomassRxn
if isfield(model,'biomassRxn') 
    if any(model.biomassRxn)
        fprintf(fileID,'BIOMASS\n');
        fprintf(fileID,'    ');
        idx = find(model.biomassRxn);
        for i=1:length(idx)
            fprintf(fileID,' %d',idx(i));
        end
        fprintf(fileID,'\n//\n');
    end
end

%Print metabolite names
fprintf(fileID,'METABOLITE_NAMES\n');
for i=1:length(model.mets)
  fprintf(fileID,'    %s\n',char(model.mets(i)));  
end
fprintf(fileID,'//\n');

%Print reaction names
fprintf(fileID,'REACTION_NAMES\n');
for i=1:length(model.rxns)
    rxnname = model.rxns{i};
    if length(strtrim(rxnname)) < 1
        rxnname = ['reaction_' num2str(i)];
    end
    rxnname = strrep(rxnname,' ','_');
    fprintf(fileID,'    %s\n',rxnname);
end
fprintf(fileID,'//\n');

%Print exchange reactions
fprintf(fileID,'EXCHANGE_REACTIONS\n');
for i=1:length(exchange_rxnsIndex)
    idx = exchange_rxnsIndex(i);
    fprintf(fileID,' %d',idx); 
end
fprintf(fileID,'\n//\n');

%Print kinetic parameters
%Note that the reaction indices refer to the position of the reaction ID in
%the Exchange Reactions block, *Not* the actual index of the reaction
%KM
if isfield(model,'km') && any(model.km)
    fprintf(fileID,'KM_VALUES\t%d\n',defaults.km);
    idx = find(~isnan(model.km) & model.km ~= defaults.km);
    for i=1:length(idx)
        rxnidx = idx(i);
        exchidx = find(exchange_rxnsIndex==rxnidx);
        if exchidx
            fprintf(fileID,'    %d %d\n',exchidx,model.km(rxnidx));
        end
    end
    fprintf(fileID,'//\n');
end

%Vmax
if isfield(model,'vmax') && any(model.vmax)
    fprintf(fileID,'VMAX_VALUES\t%d\n',defaults.vmax);
    idx = find(~isnan(model.vmax) & model.vmax ~= defaults.vmax);
    for i=1:length(idx)
        rxnidx = idx(i);
        exchidx = find(exchange_rxnsIndex==rxnidx);
        if exchidx
            fprintf(fileID,'    %d %d\n',exchidx,model.vmax(rxnidx));
        end
    end
    fprintf(fileID,'//\n');
end

%Objective Style
if ~strcmpi(cometsParams.objectiveStyle,'default')
    fprintf(fileID,'OBJECTIVE_STYLE\n');
    fprintf(fileID,'\t%s\n//\n',cometsParams.objectiveStyle);
end

fclose(fileID);
end

%determine if the reactions are exchanges or not by checking if there's
%only one reactant in the S matrix
function s = findExcByS(model)
    s = model.S;
    s = s ~= 0; %convert to logical: is there a value?
    s = sum(s,1); %collapse columns
    s = s == 1; %did each column have one member?
end
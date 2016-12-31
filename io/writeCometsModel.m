function f = writeCometsModel( input, filename, cometsParams)
%WRITECOMETSMODEL create a Comets input file for the given model
%   The third argument is optional, and can be used to override the default
%kinetic parameters declared in the CometsParams class


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
for cf={'mets' 'metNames' 'rxns' 'S' 'lb' 'ub' 'c'}
    if ~isfield(model,cf)
        error(['Invalid argument in writeCometsModel(' class(input)...
            ', ' class(filename) '): The input model requires the '...
            'following fields: [mets, metNames, metFormulas, rxns, '...
            'S, lb, ub, c]. Identified fields are ' char(fieldnames(model))]);
    end
end
        

clear exchange_rxnsIndex;
%exchange_rxnsIndex(1)=1; %not sure what case this is preventing... 
                          %reenable after debugging
exc_logical=findExcRxns(model);%COBRA function returning a logical vector.
exchange_rxnsIndex=find(exc_logical);

S=full(model.S);

[p, f, e] = fileparts(filename);
if ~exist(p)
    mkdir(p); %initialize the folder
end
fileID = fopen(filename,'w');

%Print the S matrix 
fprintf(fileID,'SMATRIX  %d  %d\n',length(model.S(:,1)),length(model.S(1,:)));
for i=1:length(S(:,1))
    for j=1:length(S(1,:))
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
%Print the objective reaction
fprintf(fileID,'OBJECTIVE\n');
   fprintf(fileID,'    %d\n',objective); 
fprintf(fileID,'//\n');

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
        fprintf(fileID,'    %d %d\n',exchidx,model.km(rxnidx));
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
        fprintf(fileID,'    %d %d\n',exchidx,model.vmax(rxnidx));
    end
    fprintf(fileID,'//\n');
end

fclose(fileID);
end


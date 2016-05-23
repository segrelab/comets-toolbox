function f = writeCometsModel( input, filename )
%WRITECOMETSMODEL Summary of this function goes here
%   Detailed explanation goes here


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
%check for these fields: metNames, metFormulas, rxns, S, lb, ub, c, mets
for cf={'mets' 'metNames' 'metFormulas' 'rxns' 'S' 'lb' 'ub' 'c'}
    if ~isfield(model,cf)
        error(['Invalid argument in writeCometsModel(' class(input)...
            ', ' class(filename) '): The input model requires the '...
            'following fields: [mets, metNames, metFormulas, rxns, '...
            'S, lb, ub, c]. Identified fields are ' [char(fieldnames(model))]]);
    end
end
        

clear exchange_rxnsIndex;
%exchange_rxnsIndex(1)=1; %not sure what case this is preventing... 
                          %reenable after debugging
exchange_rxnsIndex=strcmp('EX_',model.rxns);

S=full(model.S);

fileID=fopen(filename,'w');

%Print the S matrix 
fprintf(fileID,'SMATRIX  %d  %d\n',length(model.S(:,1)),length(model.S(1,:))+1);
for i=1:length(S(:,1))
    for j=1:length(S(1,:))
        if S(i,j)~=0
            fprintf(fileID,'    %d   %d   %f\n',i,j,S(i,j));
        end
    end
end

fprintf(fileID,'//\n');

%Print the bounds
fprintf(fileID,'BOUNDS  %d  %d\n',-1000,1000);
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
    fprintf(fileID,'    %s\n',char(model.rxns(i)));
end
fprintf(fileID,'//\n');

%Print exchange reactions
fprintf(fileID,'EXCHANGE_REACTIONS\n');
for i=1:length(exchange_rxnsIndex)
    fprintf(fileID,' %d',exchange_rxnsIndex(i)); 
end
fprintf(fileID,'\n//\n');

fclose(fileID);
end


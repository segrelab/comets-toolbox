function code=hash(genome, mets, newMets)
str='';
for j=1:genome.endOfMets
    g=genome.sequence{j};
    if isempty(g)==1
        temp='00';
    else
        if (strmatch(g,newMets)~=0)
            index=strmatch(g,newMets)+20;
        else
            index=strmatch(g,mets);
        end
            temp=num2str(index);
            if index<10
                temp=strcat('0',temp);
            end
    end
    str=strcat(str,temp);
end

for i=genome.endOfMets+1:length(genome.sequence)
    e=genome.sequence{i};
    if isempty(e)==1 
        num='00';
    else
        num=num2str(e);
        if genome.sequence{i}<10
            num=strcat('0',num);
        end
    end
    str=strcat(str,num);
end
code=str;
end
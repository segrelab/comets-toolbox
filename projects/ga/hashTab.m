% Uday Tripathi 7/2016

% Creates table from hashmap with genome hashcodes in left columns and
% scores in the right column
function hashSetup=hashTab(keys,values)

x=keys;
y=values;
hashSetup=cell(length(keys),2);
for i=1:length(x)
   hashSetup{i,1}=x{i};
   hashSetup{i,2}=y{i};
end
hashSetup=cell2table(hashSetup,'VariableNames',{'Genome' 'Score' });
end
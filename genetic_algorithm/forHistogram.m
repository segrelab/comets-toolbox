keys=masterHash.keys;
glucose=0;
sucrose=0;
maltose=0;
fructose=0;
mannose=0;
dulcose=0;
modelsCount=zeros(24,1);
for i=1:masterHash.Count
   k=keys(i);
   if (masterHash(k{1})==1000)
      seq=decode(k{1},mets,models);
      if (~isempty(strmatch('EX D-Glucose e0',seq)))
          glucose=glucose+1;
      elseif (~isempty(strmatch('EX Sucrose e0',seq)))
          sucrose=sucrose+1;
      elseif (~isempty(strmatch('EX Maltose e0',seq)))
          maltose=maltose+1;
      elseif (~isempty(strmatch('EX D-Fructose e0',seq)))
          fructose=fructose+1;
      elseif (~isempty(strmatch('EX D-Mannose e0',seq)))
          mannose=mannose+1;
      elseif (~isempty(strmatch('EX Dulcose e0',seq)))
          dulcose=dulcose+1;
      end
      
      for j=4:6
         temp=seq(j);
         temp=temp{1};
         num=str2num(temp);
         modelsCount(num)=modelsCount(num)+1;
      end
   end
end
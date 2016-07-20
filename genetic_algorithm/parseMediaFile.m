%sample input for mediaLine: 'media_1{170}'

function score=parseMediaFile(fileName, mediaName)

fid=fopen(fileName,'r');
score=0;
counter=0; % for keeping track of first line (media_names)
while ~feof(fid)
    line=fgetl(fid);
    if counter==0
        firstLine=strsplit(line,'''');
        names=firstLine(2:2:end);
        index=find(ismember(names,mediaName));
        mediaLine=strcat('media_1{',num2str(index),'}');
        counter=1;
    end
    if any(strfind(line, 'sparse'))==0
        if any(strfind(line, mediaLine))==1
            temp=strsplit(line);
            strScore=temp(end);
            strScore=strjoin(strScore);
            num=strScore(1:end-1);
            score=score+str2double(num);
        end
    end
end
end

function tab = parseMediaLog(varargin)
% PARSEMEDIALOG(logFilePath, [metNames]) load the Comets media log at the
% given path into a Table
% Note: This script is currently only compatible with 2D layouts
%
%Input:
%    logFilePath
%    metNames       : Optional. Cell array of metabolite names to extract
%                   data for. If not given, all metabolites will be loaded
%
% $Author: mquintin $	$Date: 10/19/2017 $	$Revision: 2.0 $
% Last edit: mquintin 10/19/2017
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2017

if nargin < 1
    logFilePath = 'log_media.m';
else
    logFilePath = varargin{1};
end

if ~exist(logFilePath,'file')
    error(['Could not find the log file ' logFilePath]);
end

%filelength = countLines(logFilePath);

fid = fopen(logFilePath);

%first line includes met names
fline = fgetl(fid);

%The fist line is a function that creates the media_names array, holding
%all names
media_names = {};
if (strfind(fline,'media_names = {') == 1) && (strfind(fline,';') == length(fline))
    %^makes sure the right function call is there, and there's only one
    %command on the line
    eval(fline); %replaces media_names
end

if nargin > 1
    names = varargin{2};
    if ischar(names) %make sure it's a cell array
        names = {names};
    end
    %store the indexes of the metabolites
    midxs = zeros(length(names),1);
    for i = 1:length(names)
        idx = stridx(names{i}, media_names, false);
        assert(~isempty(idx), 'The metabolite name ''%s'' does not appear to be present in the log file.', names{i});
        midxs(i) = idx;
    end
else
    names = media_names;
    midxs = 1:length(names); %indexes of the mets we're reporting
end

%figure out the dimensions of the layout
fline = fgetl(fid);
%second line should be media_0{1} = sparse(zeros(X, Y));
splitline = regexp(fline,'[(,)]','split');
xdim = str2double(splitline{3});
ydim = str2double(splitline{4});

%figure out how many timepoints there are
%first, find the last line
readsize = 256; %should be longer than any of the data lines
fseek(fid, -readsize, 'eof'); %move the position indicator near end of file
fline = fgetl(fid); %read in the rest of the file
tline = '';
while ischar(fline)
    tline = [tline fline];
    fline = fgetl(fid);
end
wordpos = strfind(tline,'media_');
wordpos = wordpos(end);%the byte # where the last line starts
fline = tline(wordpos:end);
splitline = regexp(fline,'[_{]','split');
tmax = str2double(splitline{2});

fseek(fid,0,'bof'); %reset the read position

%assemble vectors for data population
%this may be bigger than needed. We'll trim later
numrows = length(names) * tmax * xdim * ydim;
t = zeros(numrows,1);
x = zeros(numrows,1);
y = zeros(numrows,1);
met = zeros(numrows,1);
amt = zeros(numrows,1);
metname = repmat({''},numrows,1);

%parse the file
% fline = fgetl(fid);
% currow = 1; %pointer for which index is to be written next
% while ischar(fline)
%     %line format is like: media_0{162}(3, 3) = 1E-8;
%     %              or   : media_0{70} = sparse(zeros(5, 5));
%     %media_XX denotes the timestep
%     %{YY} denotes the metabolite
%     %(X, Y) denotes the coordinates
%     %the last value is either initiating a grid for each coordinate, or
%     %holds the amount
%     fline = fgetl(fid);
%     splitline = regexp(fline,'[_,{}();\s]+','split');
%     if length(splitline) == 8 %'sparse' line will have length 9
%         origmetid = str2double(splitline{3}); %the index of the name in media_names
%         newmetid = find(midxs == origmetid,1); %the index in the included mets
%
%         if ~isempty(newmetid)
%             t(currow) = str2double(splitline{2});
%             met(currow) = newmetid;
%             metname(currow) = media_names(origmetid);
%             x(currow) = str2double(splitline{4});
%             y(currow) = str2double(splitline{5});
%             amt(currow) = str2double(splitline{7});
%
%             currow = currow + 1;
%         end
%     else %'sparse' line: populate any metabolites that weren't listed in the last set as having 0 amount
%         if length(prevline) == 8
%
%         end
%         if length(prevline) > 8 %previous line was also sparse
%
%         end
%         %if length(prevline) == 0, there's nothing to do here because we're
%         %at the first line
%
%         %Reset the arrays that track if a metabolite was present in the
%         %current coordinate
%
%
%     end
%     prevline = splitline;
%     fline = fgetl(fid);
% end

%Do it a different way:
%When a new coordinate is set:
%   build an array of values for every met, initialized at 0
%When not-sparse:
%   set the value in the temp array for the corresponding met
%when sparse:
%   populate the values for the last coordinate, then set the new
%   coordinate
fline = fgetl(fid); %the media_names line
fline = fgetl(fid); %now we're at the first data line
currow = 1; %pointer for which index is to be written next
tvals = zeros(xdim,ydim,length(midxs));
tt = -1;
while ischar(fline)
    %line format is like: media_0{162}(3, 3) = 1E-8;
    %              or   : media_0{70} = sparse(zeros(5, 5));
    %media_XX denotes the timestep
    %{YY} denotes the metabolite
    %(X, Y) denotes the coordinates
    splitline = regexp(fline,'[_,{}();\s]+','split');
    if length(splitline) == 9 %'sparse' line will have length 9, and
        %indicates that we've moved to the next coordinate
        %write the records for the previous coordinate
        if tt >= 0 %so we don't run on line 2, before any data's loaded
            if ~isempty(newmetidx)
                for xi = 1:xdim
                    for yi = 1:ydim
                        mname = names{newmetidx};
                        t(currow) = tt;
                        met(currow) = newmetidx;
                        metname{currow} = mname;
                        x(currow) = xi;
                        y(currow) = yi;
                        amt(currow) = tvals(xi,yi);
                        currow = currow + 1;
                    end
                end
            end
        end
        %now reset the temp data
        origmetidx = str2double(splitline{3});
        newmetidx = find(midxs == origmetidx);
        tt = str2double(splitline{2});
        %tx = str2double(splitline{7});
        %ty = str2double(splitline{8});
        tvals = zeros(xdim,ydim);
        
    elseif length(splitline) == 8 %this line has a value
        origmetidx = str2double(splitline{3});
        newmetidx = find(midxs == origmetidx);
        if any(newmetidx)
            tx = str2double(splitline{4});
            ty = str2double(splitline{5});
            tvals(tx,ty) = str2double(splitline{7});
            %tvals is a 2d matrix for each position's met concentration
        end
    end
    
    fline = fgetl(fid);
end

%now write the records for the last coordinate too
if tt >= 0
    origmetidx = str2double(splitline{3});
    newmetidx = find(midxs == origmetidx);
    if ~isempty(newmetidx)
        for xi = 1:xdim
            for yi = 1:ydim
                mname = names{newmetidx};
                t(currow) = tt;
                met(currow) = newmetidx;
                metname{currow} = mname;
                x(currow) = xi;
                y(currow) = yi;
                amt(currow) = tvals(xi,yi);
                currow = currow + 1;
            end
        end
    end
end

fclose(fid);

%trim the arrays
t = t(1:currow-1);
x = x(1:currow-1);
y = y(1:currow-1);
met = met(1:currow-1);
amt = amt(1:currow-1);
metname = metname(1:currow-1);

%assemble table
tab = table(t, x, y, met, amt, metname);

end


%credit to Edric Ellis @ https://stackoverflow.com/questions/12176519/is-there-a-way-in-matlab-to-determine-the-number-of-lines-in-a-file-without-loop
function count = countLines(fname)
fh = fopen(fname, 'rt');
assert(fh ~= -1, 'Could not read: %s', fname);
count = 0;
while ~feof(fh)
    count = count + sum( fread( fh, 16384, 'char' ) == char(10) );
end
fclose(fh);
end

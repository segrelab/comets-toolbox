function model = readCometsModel( path )
%READCOMETSMODEL Summary of this function goes here
%   Detailed explanation goes here

fileid = fopen(path,'r');

%line1: SMATRIX xdim ydim
line = fgetl(fileid); 
[s x y] = strread(line,'%s %d %d');

if ~strcmpi(s,'SMATRIX')
    error(['Please check to ensure ' path ' is a valid COMETS model file']);
end

smatrix = [];
%populate the S MATRIX. Format: x y val
line = fgetl(fileid);
while ischar(line)
    if strfind(line,'//')
        break
    end
    [x y v] = strread(line,'%d %d %f');
    smatrix(x,y) = v;
    line = fgetl(fileid);
end


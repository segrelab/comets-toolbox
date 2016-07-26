function model = readModel( path)
%READMODEL Load a file into a COBRA-formatted struct
%   If no file is given, will spawn a dialog to prompt the user to select
%   one.
%path: Optional path to a model file

if nargin == 0
    path = uigetfile;
end

%determine format
iscomets = false;
fileID = fopen(path);
line = fgets(fileID);
firstword = textscan(line,'%7s',1);
if strcmpi('SMATRIX',firstword{1})
    iscomets = true;
end

model = -1;

if iscomets
    model = readCometsModel(path);
else
    model = readCbModel(path);
end

end


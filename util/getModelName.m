function res = getModelName( model )
%GETMODELNAME Parse the given COBRA model to return a name to be used in 
%eg a COMETS output file name
%   If model.description is a Character Array, strip whitespace and special
%   characters then return it.
%   If model.description is a Struct, check if it has a name. If so, return
%   it.
%   Otherwise, return 'model_XYZ' where XYZ is a hash code based on the
%   model to approximate uniqueness.

% $Author: mquintin $	$Date: 2017/01/019 $	$Revision: 0.1 $
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2017
if ~isstruct(model)
    error('getModelName() requires a COBRA model Struct as input');
end

res = '';

if isfield(model,'description')
    description = model.description;
    if ischar(description)
        description = strrep(description,' ','_'); %replace whitespace
        description = regexprep(description,'\W',''); %remove special chars
        [pathstr,name,ext] = fileparts(description);
        res = name;
    elseif isstruct(description)
        if isfield(description,'name') && ~isempty(description.name)
            dname = strrep(description.name,' ','_'); %replace whitespace
            dname = regexprep(dname,'\W',''); %remove special chars
            [pathstr,name,ext] = fileparts(dname);
            res = name;
        end
    else
        warning('Unhandled input: Model.description is not a String or a Struct. Defaulting to generating a name.');
    end
end

if strcmp(res,'') %a suitable name hasn't been found
    %generate a name based on a sloppy hashing of the model
    hashres = hashStruct(model);
    hexres = dec2hex(hashres); % convert to hex
    hexres = reshape(hexres',1,numel(hexres)); %flatten into a single row
    res = ['model_' hexres];
end
    
end

function res = hashStruct(arg)
    %convert the given struct, cell array, numeric array, or character 
    %vector to a sequence of 8 integers
    res = uint8(zeros(1,8));
    if isstruct(arg)
        fnames = fieldnames(arg);
        for i = 1:length(fnames)
                f = getfield(arg,fnames{i});
                h = hashStruct(f);
                res = bitxor(res,h);
        end
    elseif ~isempty(res)
        if iscell(arg)
            idx = ~cellfun(@isempty,arg);
            arg = arg(idx); %strip empties
            arg = cellfun(@char,arg,'UniformOutput',false); %convert nonchar cell contents
            arg = char(arg); %convert to a full table of chars
        end
        x = uint8(full(arg));
        
        %pad & reshape x so it's 8 columns, all rows are full
        x = reshape(x,1,numel(x));
        x = [x zeros(1, 8 - mod(numel(x),8))];
        x = x';
        x = reshape(x,numel(x)/8,8);
        
        %xor all rows
        [rows,cols] = size(x);
        for j = 1:rows
            res = bitxor(res,x(j,:));
        end
    end

end

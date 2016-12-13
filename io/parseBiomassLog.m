function [outputArgs] = parseBiomassLog(file)
%PARSEBIOMASSLOG Summary of this function goes here
% 
% [OUTPUTARGS] = PARSEBIOMASSLOG(INPUTARGS) Explain usage here
% 
% Examples: 
% 
% Provide sample usage code here
% 
% See also: List related files here

% $Author: mquintin $	$Date: 2016/11/01 17:03:13 $	$Revision: 0.1 $
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016

fileid = fopen(file);
allLines = textscan(f,'%s','delimiter','\n');
fclose(fileid);

end

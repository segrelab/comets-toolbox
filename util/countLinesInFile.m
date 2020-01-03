%credit to Edric Ellis @ https://stackoverflow.com/questions/12176519/is-there-a-way-in-matlab-to-determine-the-number-of-lines-in-a-file-without-loop
function count = countLinesInFile(fname)
fh = fopen(fname, 'rt');
assert(fh ~= -1, 'Could not read: %s', fname);
count = 0;
while ~feof(fh)
    count = count + sum( fread( fh, 16384, 'char' ) == char(10) );
end
fclose(fh);
end
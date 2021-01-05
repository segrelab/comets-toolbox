function status = testComets()
%TESTCOMETS Verifies the installation of COMETS and Gurobi and the related
%environment variables.
%Output status = 1 if all tests pass, 0 otherwise.

status = 1;

%check COMETS_HOME, GUROBI_HOME
disp('Verifying environment...');
cometshome = getenv('COMETS_HOME');
if isempty(cometshome)
   disp('COMETS_HOME environmental variable is not set')
   status = 0;
else
    disp(['COMETS_HOME is set to ' cometshome]);
end

gurobihome = getenv('GUROBI_HOME');
if isempty(gurobihome)
   disp('GUROBI_HOME environmental variable is not set')
   status = 0;
else
    disp(['GUROBI_HOME is set to ' gurobihome]);
end

end

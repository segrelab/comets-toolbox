%Import from SBML
ecoli = readCbModel('sample/e_coli_core.xml')
%Import from .MAT
reader = load('sample/pseudomonas.mat');
pseudomonas = reader.model1
%also from comets file format...

%Build & populate a layout
world = CometsLayout()
world = world.addModel(pseudomonas)
world = world.addModel(ecoli)

%Manipulate the layout
x = 5;
y = 5;
world = world.setDims(x,y);
barrier = world.barrier; %just to see this is a 5x5 logical matrix
newbar = eye(5); %5x5 identity matrix
world.barrier = newbar; %simply replace the world.barrier

%Generate Comets files
writeCometsLayout(world,'sample/demoWorld1/')

%Run comets
run_comets('sample/demoWorld1')
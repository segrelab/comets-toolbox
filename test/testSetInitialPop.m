%TESTSETINITIALPOP Confirm that the setInitialPop function works as
%expected
% 
% $Author: mquintin $	$Date: 2016/08/28 16:54:26 $	$Revision: 0.1 $
% Copyright: Daniel Segrè, Boston University Bioinformatics Program 2016

%%Create layout
layout = CometsLayout();
load('pa_model.mat'); %as variable 'model'
layout = addModel(layout,model);
layout = addModel(layout,model); %run with two models
layout.params.writeBiomassLog=true; %confirm that this worked if biomass.txt appears
layout.params.maxCycles=20;
layout.media_amt(:)=10; %add some media

cd('C:\sync\biomes\scripts\CometsToolbox\scratch\test\out'); %always run in scratch

layout = setInitialPop(layout,'1x1');
runfolder = fullfile(pwd, 'setInitialPop1x1'); %
runComets(layout,runfolder);

%layout = setInitialPop(layout,'colonies');
%runfolder = fullfile(pwd, 'setInitialPopColonies'); %
%runComets(layout,runfolder);
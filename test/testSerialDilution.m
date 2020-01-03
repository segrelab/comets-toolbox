%A script to test out the serial dilution functions
load('iJO1366.mat');
layout = createLayout();
layout = addModel(layout,iJO1366);
layout = addModel(layout,iJO1366);
layout.media_amt(1:length(layout.mets)) = 0.01;
layout = setInitialPop(layout,'1x1');
layout.initial_pop(2) = layout.initial_pop(2)*2;

[biomass,t,media] = runSerialDilution(layout,4,20,true,'C:\sync\biomes\scripts\tmp');
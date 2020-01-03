function layout = makeChemostat(layout,varargin)
%MAKECHEMOSTAT makeChemostat(layout, dilution{mL/h}, cellVolume)
% Make the given layout behave as a chemostat with a constant
% inflow/outflow of media. The flow rate is defined in units of mL/hour
%
% This function should be invoked AFTER all models and extracellular
% reactions have been added to the layout. Media components which are added
% after invokation will not have the proper refresh & dilution behaviors
% applied.
%
% Applies the following transformations to the given layout:
%   *Convert to a homogenous medium (1x1)
%   *Change cell volume
%   *Add mediaRefresh based on the initial media_amt
%   *Add reactions so all media components decrease by a fixed
%   fraction/timestep
%   *Increase death rate to represent biomass dilution
%
% TODO: 
% -How best to handle initial biomass? Right now, behavior is taken
% from setInitialPop() with the '1x1' option
% -add option to scale media amounts to the new size?

%defaults
defaultVolume = 10; %mL
defaultFlowPerH = 1; %mL/hour
% defaultVerbose = true;

%NOT YET IMPLEMENTED
%scaleMedia = false; %should media amounts be scaled when changing volume?

p = inputParser;
addRequired(p,'layout',@(x) isa(x,'CometsLayout'));
addOptional(p,'flowPerH',defaultFlowPerH,@(x) isa(x,'double'));
addOptional(p,'volume',defaultVolume,@(x) isa(x,'double'));
% addOptional(p,'verbose',defaultVerbose,@(x) isa(x,'boolean'));
parse(p,layout,varargin{:});

flowPerH = p.Results.flowPerH;
volume = p.Results.volume;
%verbose = p.Results.verbose;

%Resize the layout and set initial populations
layout = setInitialPop(layout,'1x1');

layout.params.spaceWidth = volume^(1/3);
% if verbose
%     disp(['Chemostat volume set to ' num2str(volume)]);
% end

%apply dilution factor to remove media
d = flowPerH / volume; %units h^-1
dps = d/3600; %units s^-1. Rxn velocity is in these units
for i = 1:length(layout.mets)
    name = ['dilute_' layout.mets{i}];
    layout = addExternalReaction(layout,name,layout.mets{i},-1,'k',dps);
end

%apply fresh media

%Using media refresh causes an error because the dilution happens
%continuously and the addition happens at discrete points. So dilution
%slows down over the course of a timestep, resulting in the steady-state
%concentration being slightly higher than it should be
%
%%refreshPerTS = d * layout.params.timeStep;
%%layout.global_media_refresh = layout.media_amt * refreshPerTS;
%
%Instead, use a pseudometabolite to continuously add media

layout = addMets(layout,{'bioreactorA[pseudo]' 'bioreactorB[pseudo]'});
layout.media_amt(stridx('bioreactorA[pseudo]',layout.mets)) = 0.5;
layout.media_amt(stridx('bioreactorB[pseudo]',layout.mets)) = 0.5;

refreshPerS = layout.media_amt;
refreshPerS = refreshPerS(refreshPerS > 0);
mediamets = layout.mets(layout.media_amt > 0);

refreshPerS_A = refreshPerS;
refreshPerS_A(stridx('bioreactorA[pseudo]',mediamets)) = -1;
refreshPerS_A(stridx('bioreactorB[pseudo]',mediamets)) = 1;
layout = addExternalReaction(layout,'bioreactor_refresh_media_A',mediamets,refreshPerS_A,'k',dps);

refreshPerS_B = refreshPerS;
refreshPerS_B(stridx('bioreactorA[pseudo]',mediamets)) = 1;
refreshPerS_B(stridx('bioreactorB[pseudo]',mediamets)) = -1;
layout = addExternalReaction(layout,'bioreactor_refresh_media_B',mediamets,refreshPerS_B,'k',dps);



%apply death rate
layout.params.deathRate = d; %units are h^-1

end
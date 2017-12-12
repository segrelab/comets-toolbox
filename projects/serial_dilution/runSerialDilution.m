function [biomass,t,media] = runSerialDilution(layout,varargin)
%runSerialDilution(layout,nCycles,dilutionFactor,includeSpentMedia,directory)
%   Executes the given layout multiple times, diluting the results between
%   cycles.
%Required Argument:
%   layout: a 1x1 CometsLayout object. Media should be included in the
%   media_amt field as opposed to the initial_media field (on the
%   assumption that initial_media is only used when there are spatially
%   distinct media regions)
%Optional Arguments:
%   nCycles: Number of growth steps to perform
%   dilutionFactor: if > 1, the -fold dilution performed between cycles. If < 1, the percent of biomass that gets transfered to the next cycle
%   includeSpentMedia: if true (default), a portion of the media at the end of a cycle will be combined with the media at the start of the next cycle. This is equivalent to pipetting media directly from one stage into the next. If false, only the biomass will be transferred and the media at the start of each cycle will be identical.
%   directory: location to store log files and the COMETS .bat script
%Returns:
%   biomass: matrix of model biomasses at each timepoint
%   t: time in hours for each timepoint
%   media: matrix of media concentration at each timepoint
%
%Example Use:
% load('iJO1366.mat');
% layout = createLayout();
% layout = addModel(layout,iJO1366);
% layout = addModel(layout,iJO1366);%2 copies of the model
% layout.media_amt(1:end) = 1;
% layout = setInitialPop(layout,'1x1',[1e-5 2e-5]);
% 
% [biomass,t,media] = runSerialDilution(layout,5,0.5,true,pwd);
% 
% plot(t,biomass(:,1),t,biomass(:,2))

%Defaults
defaultNCycles = 5;
defaultDilutionFactor = 0.05;
defaultIncludeSpentMedia = true;
defaultDirectory = pwd;

p = inputParser;
addRequired(p,'layout',@(x) isa(x,'CometsLayout'));
addOptional(p,'nCycles',defaultNCycles,@(x) isa(x,'double'));
addOptional(p,'dilutionFactor',defaultDilutionFactor,@(x) isa(x,'double'));
addOptional(p,'includeSpentMedia',defaultIncludeSpentMedia);
addOptional(p,'directory',defaultDirectory,@(x) exist(x,'dir'));
parse(p,layout,varargin{:});

cycles = p.Results.nCycles;
df = p.Results.dilutionFactor;
incspent = p.Results.includeSpentMedia;
d = p.Results.directory;
biomass = [];
media = [];
t = [];

%ensure this is being run on a 1x1 layout
if (layout.xdim ~= 1 || layout.ydim ~= 1)
    error('runSerialDilution requires the given Layout''s dimensions to be 1x1.');
end

%Warn if media is set in layout.initial_media instead of layout.media_amt
if (logical(nnz(layout.initial_media))) %if any values are nonzero
    warning(['The 1x1 layout in runSerialDilution should have its media recipe '...
        'set in the media_amt field. The initial_media should be reserved for '...
        'defining regions with distinct media composition. Media may not be'...
        'properly transferred between cycles.']);
end

%allow dilution factor to be given as a fraction or as the fold dilution
%eg if the user says 20X dilution, convert 20 -> 0.05
%always treat it as a fraction from here out
if (df > 1)
    df = 1/df;
end

%set up the necessary logs
layout.params.writeBiomassLog = true;
biolog = layout.params.biomassLogName;
if (incspent == true)
    layout.params.writeMediaLog = true;
    medialog = layout.params.mediaLogName;
end

curdir = pwd;
cd(d);
ts = layout.params.timeStep;
lograte = layout.params.biomassLogRate;
layout.params.mediaLogRate = lograte;
step = ts * lograte;

cc = 0; %current cycle
elapsedTime = 0;
while (cc < cycles)
    %run a simulation
    runComets(layout);
    
    %get the biomass
    b = parseBiomassLog(biolog);
    nmodels = max(b.model + 1);
    nrows = length(unique(b.t)); %number of timesteps
    bt = zeros(nrows,nmodels);
    for (i = 1:nmodels)
        modelbio = b.biomass(b.model == i-1);
        bt(:,i) = modelbio;
    end
    biomass = [biomass;bt];
    
    %get the media
    m = parseMediaLog(medialog);
    nmets = max(m.met);
    mt = zeros(length(unique(m.t)),nmets);
    for (i = 1:nmets)
        metcon = m.amt(m.met == i);
        if (metcon)
            mt(:,i) = metcon;
        end
    end
    media = [media;mt];
    
    %apply the biomass for the next iteration
    finalbio = biomass(end,:)';
    layout.initial_pop = finalbio * df;
    
    %apply the media for the next iteration
    if (incspent)
        finalmets = media(end,:);
        layout.media_amt = (layout.media_amt * (1-df)) + (finalmets * df);
    end
    
    %update the time vector
    nt = step:step:(step * nrows);
    nt = nt + (cc * ts * layout.params.maxCycles);
    t = [t nt];
    
    cc = cc+ 1;
end
%shift the whole time vector back one step so it starts at 10 instead of t1
t = t - step;

cd(curdir);
end


classdef CometsLayout
    %CometsLayout Defines the COMETS world and contains COBRA models.
    %
    %     Constructor: CometsLayout()
    %
    %     Standard workflow should be as follows: 1) Create an empty layout
    %         world = CometsLayout()
    %     2) Set global and model-level defaults in the contained CometsParams
    %         world.params.DefaultVmax = 10
    %     3) Add COBRA models
    %
    %     See also CometsParams
    %
    properties
        models = {};
        xdim = 1;
        ydim = 1;
        mets = {}; %cell array of strings
        media_amt = [0];%vector 1/met, default 0. Initial media concentration in every cell
        params = CometsParams();
        %use sparse matrices. Empty elements use default values
        diffusion_constants = []; %met by 2. If (i,1)=0, met i uses the default diffusion constant. if (i,1)=1, met i's diffusion constant is the value of (i,2)
        global_media_refresh = [];%vector 1/met, default 0
        media_refresh = [0];%[0] %met by x by y, fill with 0
        global_static_media = [];%met by 2. (met,1) is logical denoting if the corresponding media is held static, (met,2) is the held concentration
        static_media = [0];%met by x by y by 2, with the fourth dimension as in global_static_media ****
        initial_media = [0]; %met by x by y by 2. Initial media concentration in the specified cell. Fourth dimension denotes [isThisValueSet?, value]
        %To further explain these last four, if the fourth dimension holds (1,0) the value in the cell is not empty/default; it's set to zero.
        barrier = [0]; %x by y, logical
        initial_pop = [0];%models by x by y, default 0
        external_rxns = table();
        external_rxn_mets = table();
        %TODO: initial_pop modes (rectangle, random...)
    end
    
    methods
        function obj=CometsLayout()
        end
        
        function self=addModel(self,model)
            self.models = [self.models model];
            
            %if the model contains any external metabolites, add them to this mets list
            %get exchange reactions
            excl = findExcRxns(model); %logical: does this rxn have 1 metabolite?
            exc = model.S(:,excl); %S matrix slice of just exchange reactions
            [row,col] = find(exc);
            names = model.mets(row);
            
            %mis = sum(abs(exc)); %collapse to vector of exchange metabolites
            %names = model.mets(mis~=0); %get logical index of cells
            
            newnames = setdiff(names, self.mets);
            self = addMets(self,newnames);
        end
        
        %Add the metabolites in the cell array newnames to this layout
        function self = addMets(self,newnames)
            self.mets = [self.mets; newnames]; %must maintain order, don't use Union
            
            diff = length(self.mets) - length(self.media_amt);
            if diff > 0
                self.media_amt = [self.media_amt; zeros(diff,1)];
            end
            
            diff = length(self.mets) - length(self.diffusion_constants);
            if diff > 0
                self.diffusion_constants = [self.diffusion_constants; zeros(diff,2)];
            end
            
            diff = length(self.mets) - length(self.global_media_refresh);
            if diff > 0
                self.global_media_refresh = [self.global_media_refresh; zeros(diff,1)];
            end
            
            diff = length(self.mets) - size(self.global_static_media,1);
            if diff > 0
                self.global_static_media = [self.global_static_media; zeros(diff,2)];
            end
            
            diff = length(self.mets) - size(self.static_media,1);
            if diff > 0
                %self.static_media = [self.static_media; zeros(diff,self.xdim,self.ydim,2)];
                self.static_media(diff,:,:,:)=0;
            end
        end
        
        %function self=removeModel(self,model)
        %end
        
        function self=setParams(self,params)
            self.params = params;
        end
        
        function idx=metIdx(self,name)
            idx = stridx(name,self.mets,false);
        end
        
        function self = setXdim(self,x)
            diff = x - self.xdim;
            if diff < 0
                self.media_refresh = self.media_refresh(1:x,:); %met by x by y, default 0
                self.static_media = self.static_media(:,1:x,:); %met by x by y by 2, with the fourth dimension as in global_static_media
                self.barrier = self.barrier(1:x,:); %x by y, logical
                self.initial_pop = self.initial_pop(:,1:x,:); %models by x by y
            elseif diff > 0
                %self.media_refresh = [self.media_refresh; zeros(diff,self.ydim)]; %met by x by y, default 0
                self.media_refresh(:,x,:) = 0;
                %self.static_media = [self.static_media; zeros(length(self.mets),diff,self.ydim,2)]; %met by x by y by 2, with the fourth dimension as in global_static_media
                self.static_media(:,x,:,:) = 0;
                self.barrier = [self.barrier; zeros(diff,self.ydim)]; %x by y, logical
                %self.initial_pop = [self.initial_pop; nan(length(self.models),diff,self.ydim)]; %models by x by y
                self.initial_pop(:,x,:) = 0;
            end
            self.xdim = x;
        end
        
        function self = setYdim(self,y)
            diff = y - self.ydim;
            if diff < 0
                self.media_refresh = self.media_refresh(:,1:y); %met by x by y, default 0
                self.static_media = self.static_media(:,:,1:y); %met by x by y by 2, with the fourth dimension as in global_static_media
                self.barrier = self.barrier(:,1:y); %x by y, logical
                self.initial_pop = self.initial_pop(:,:,1:y); %models by x by y
            elseif diff > 0
                %self.media_refresh = [self.media_refresh; zeros(self.xdim,diff)]; %met by x by y, default 0
                self.media_refresh(:,:,y) = 0;
                %self.static_media = [self.static_media; zeros(length(self.mets),self.xdim,diff,2)]; %met by x by y by 2, with the fourth dimension as in global_static_media
                self.static_media(:,:,y,:) = 0;
                self.barrier = [self.barrier zeros(self.xdim,diff)]; %x by y, logical
                %self.initial_pop = [self.initial_pop; nan(length(self.models),self.xdim,diff)]; %models by x by y
                self.initial_pop(:,:,y,:) = 0;
            end
            self.ydim = y;
        end
        
        function self = setDims(self,x,y)
            self = self.setXdim(x);
            self = self.setYdim(y);
        end
        
        function self = setInitialMediaInCell(self,x,y,metname,value)
            idx = stridx(metname,self.mets,false);
            if isempty(idx) || ~idx
                warning(['Could not find ' metname ' in the media list. Adding it as a new media component.']);
                self = addMets(self,{metname});
                idx = stridx(metname,self.mets,false);
            end
            self.initial_media(idx,x,y,1)=1;
            self.initial_media(idx,x,y,2)=value;
        end
        
        %set the initial amount of the metabolite given by name
        function self = setInitialMedia(self,metname,value)
            idx = stridx(metname, self.mets, false);
            if isempty(idx) || ~idx
                warning(['Could not find ' metname ' in the media list. Adding it as a new media component.']);
                self = addMets(self,{metname});
                idx = stridx(metname,self.mets,false);
            end
            self.media_amt(idx) = value;
        end
        
        %rename setInitialMedia for simplicity
        function self = setMedia(self, metname, value)
            self = setInitialMedia(self, metname, value);
        end
        
        %sort the list of metabolites alphabetically, and rearrange other
        %lists accordingly
        function self = sortMetabolites(self)
            %lists to rearrange: mets, media_amt, diffusion_constants, global_media_refresh
            %media_refresh, global_static_media, static_media, initial_media
            nmets = length(self.mets);
            x = self.xdim;
            y = self.ydim;
            [self.mets, map] = sort(self.mets);
            if any(self.media_amt)
                self.media_amt = self.media_amt(map);
            end
            if any(self.diffusion_constants)
                self.diffusion_constants = self.diffusion_constants(map,1:2);
            end
            if any(self.global_media_refresh)
                self.global_media_refresh = self.global_media_refresh(map);
            end
            if any(self.media_refresh(:))
                s = size(self.media_refresh);
                if s(1) < nmets
                    self.media_refresh(nmets,z,y) = 0;
                end
                self.media_refresh = self.media_refresh(map,:,:);
            end
            if any(self.global_static_media(:))
                self.global_static_media = self.global_static_media(map,:);
            end
            if any(self.static_media(:))
                s = size(self.static_media);
                if s(1) < nmets
                    self.static_media(nmets,x,y,2) = 0;
                end
                self.static_media = self.static_media(map,:,:,:);
            end
            if any(self.initial_media(:))
                s = size(self.initial_media);
                if s(1) < nmets
                    self.initial_media(nmets,x,y,2) = 0;
                end
                self.initial_media = self.initial_media(map,:,:,:);
            end
        end
        
        %setDiffusion(self, metnames, [values])
        %set diffusion constants for the given metabolite or list of
        %metabolites
        %'metnames' can be a single metabolite name, a cell array of
        %metabolite names, a single metabolite index, or an array of
        %metabolite indexes
        %'values' can be a single value, an array of values, false, or
        %not given. If false or not given, the metabolites will have their
        %"set" flag (the first dimension in diffusion_constants) turned
        %off. If a single value, all input metabolites will get that value
        %assigned. If an array, there must be one value per metabolite
        function self = setDiffusion(varargin)
            self = varargin{1};
            
            midx = [];
            switch class(varargin{2})
                case 'char'
                    midx = metIdx(self,varargin{2});
                case 'cell'
                    c = varargin{2};
                    for i=1:length(c)
                        midx = [midx metIdx(self,c{i})];
                    end
                case 'double' %this covers single values and arrays of doubles
                    midx = varargin{2};
                otherwise
                    error('Metabolites in setDiffusion(layout,mets,values) must be ID''d as a char, cell array of chars, or double');
            end
            
            hasValue = false;
            if nargin > 2 && (varargin{3} || isnumeric(varargin{3}))
                hasValue = true;
                vals = varargin{3};
                if length(vals) == 1
                    vals = repmat(vals,length(midx),1);
                end
                if length(vals) ~= length(midx)
                    error('The third argument in setDiffusion(layout,mets,values) must be empty, false, or of the same length as the list of mets');
                end
            end
            
            if hasValue
                self.diffusion_constants(midx,1) = 1;
                self.diffusion_constants(midx,2) = vals;
            else
                self.diffusion_constants(midx,1) = 0;
            end
        end
        
    end
    
end


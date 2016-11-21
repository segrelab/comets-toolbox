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
        diffusion_const = [0]; %vector 1/met, default in params
        global_media_refresh = [];%vector 1/met, default 0
        media_refresh = [0];%[0] %met by x by y, fill with 0
        global_static_media = [];%met by 2. (met,1) is logical denoting if the corresponding media is held static, (met,2) is the held concentration
        static_media = [0];%met by x by y by 2, with the fourth dimension as in global_static_media ****
        initial_media = [0]; %met by x by y by 2. Initial media concentration in the specified cell. Fourth dimension denotes [isThisValueSet?, value]
        %To further explain these last three, if the fourth dimension holds (1,0) the value in the cell is not empty/default; it's set to zero.
        barrier = [0]; %x by y, logical
        initial_pop = [0];%models by x by y, default 0
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
            self.mets = [self.mets; newnames]; %must maintain order, don't use Union
            
            diff = length(self.mets) - length(self.media_amt);
            if diff > 0
                self.media_amt = [self.media_amt; zeros(diff,1)];
            end
            
            diff = length(self.mets) - length(self.diffusion_const);
            if diff > 0
                self.diffusion_const = [self.diffusion_const; zeros(diff,1)];
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
            self.initial_media(idx,x,y,1)=1;
            self.initial_media(idx,x,y,2)=value;
        end
        
        %sort the list of metabolites alphabetically, and rearrange other
        %lists accordingly
        function self = sortMetabolites(self)
            %lists to rearrange: mets, media_amt, diffusion_const, global_media_refresh
            %media_refresh, global_static_media, static_media, initial_media
            nmets = length(self.mets);
            x = self.xdim;
            y = self.ydim;
            [self.mets, map] = sort(self.mets);
            if any(self.media_amt)
                self.media_amt = self.media_amt(map);
            end
            if any(self.diffusion_const)
                self.diffusion_const = self.diffusion_const(map);
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
    end
    
end


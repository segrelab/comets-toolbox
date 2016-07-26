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
        media_amt = [0]%[NaN] %vector 1/met, default 0
        params = CometsParams();
            %use sparse matrices. Empty elements use default values
        diffusion_const = [0]; %[NaN] %vector 1/met, default in params
        global_media_refresh = [];%[0] %vector 1/met, default 0
        media_refresh = [0];%[0] %met by x by y, fill with 0 ****
        global_static_media = [];%[NaN] %met by 2. (met,1) is logical denoting if the corresponding media is held static, (met,2) is the held concentration
        static_media = [0];%[NaN] %met by x by y by 2, with the fourth dimension as in global_static_media ****
        barrier = [0]; %x by y, logical
        initial_pop = [0];%[0] %models by x by y, default 0
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
            self.media_amt = [self.media_amt; zeros(diff,1)];
            
            diff = length(self.mets) - length(self.diffusion_const);
            self.diffusion_const = [self.diffusion_const; zeros(diff,1)];
            
            diff = length(self.mets) - length(self.global_media_refresh);
            self.global_media_refresh = [self.global_media_refresh; zeros(diff,1)];
            
            diff = length(self.mets) - size(self.global_static_media,1);
            self.global_static_media = [self.global_static_media; zeros(diff,2)];
            
            diff = length(self.mets) - size(self.static_media,1);
            %self.static_media = [self.static_media; zeros(diff,self.xdim,self.ydim,2)];
            self.static_media(diff,:,:,:)=0;
        end
        
        %function self=removeModel(self,model)
        %end
        
        function self=setParams(self,params)
            self.params = params;
            %todo: load local properties from params todo: pass params to
            %all contained models
        end
        
        function idx=metIdx(self,name)
            %given the String name of a metabolite, returns its index in
            %the mets list. If not found, it will return an empty matrix.
            %Check for this case with isempty(idx)
            idx = [];
            if ~isempty(self.mets)
                %idx = find(cellfun('length',regexp(self.mets,name))==1);
                idx = find(strcmp(name,self.mets),1,'first'); 
                %should be a single integer
            end
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
    end
        
end


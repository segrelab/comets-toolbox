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
        diffusion_constants = []; %met by 2. If (i,1)=0, met i uses the default diffusion constant. if (i,1)=1, met i's diffusion constant is the value of (i,2). Units = cm^2/s
        global_media_refresh = [];%vector 1/met, default 0
        media_refresh = [];%[0] %met by x by y, fill with 0. Units = concentration
        global_static_media = [];%met by 2. (met,1) is logical denoting if the corresponding media is held static, (met,2) is the held concentration. Units = concentration
        static_media = [0];%met by x by y by 2, with the fourth dimension as in global_static_media ****
        initial_media = [0]; %met by x by y by 2. Initial media concentration in the specified cell. Fourth dimension denotes [isThisValueSet?, value]
        %To further explain these last four, if the fourth dimension holds (1,0) the value in the cell is not empty/default; it's set to zero.
        barrier = [0]; %x by y, logical
        initial_pop = [0];%models by x by y, default 0. Units = grams.
        external_rxns = table();
        external_rxn_mets = table();
        %TODO: initial_pop modes (rectangle, random...)
    end
    
    methods
        function obj = CometsLayout()
        end
        
        function self = addModel(self,model)
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
        
        function self = addMets(self,newnames)
            %Add the metabolites in the cell array newnames to this layout
            newnames = setdiff(newnames, self.mets);
            
            %make sure the newnames array is vertical
            [w,h] = size(newnames);
            if h > w
                newnames = newnames';
            end
            
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
            
            diff = length(self.mets) - size(self.media_refresh,1);
            if diff > 0
                self.media_refresh(length(self.mets),:,:)=0;
            end
            
            diff = length(self.mets) - size(self.global_static_media,1);
            if diff > 0
                self.global_static_media = [self.global_static_media; zeros(diff,2)];
            end
            
            diff = length(self.mets) - size(self.static_media,1);
            if diff > 0
                %self.static_media = [self.static_media; zeros(diff,self.xdim,self.ydim,2)];
                self.static_media(length(self.mets),:,:,:)=0;
            end
        end
        
        %function self=removeModel(self,model)
        %end
        
        function self = setParams(self,params)
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
        
        function self = setInitialMedia(self,metname,value)
            %split up cell array values of metname
            if iscell(metname)
                len = length(metname);
                v = repmat(value,1,len); %in case a single value was given
                for i = 1:len
                    mn = metname{i};
                    self = setInitialMedia(self,mn,v(i));
                end
            else %metname is char
                %set the initial amount of the metabolite given by name
                idx = stridx(metname, self.mets, false);
                if isempty(idx) || ~idx
                    warning(['Could not find ' metname ' in the media list. Adding it as a new media component.']);
                    self = addMets(self,{metname});
                    idx = stridx(metname,self.mets,false);
                end
                self.media_amt(idx) = value;
            end
        end
        
        function self = setMedia(self, metname, value)
            %renamed setInitialMedia for simplicity
            self = setInitialMedia(self, metname, value);
        end
        
        
        function self = sortMetabolites(self)
            %sort the list of metabolites alphabetically, and rearrange other
            %lists accordingly
            %
            %lists to rearrange: mets, media_amt, diffusion_constants, global_media_refresh
            %media_refresh, global_static_media, static_media, initial_media
            nmets = length(self.mets);
            x = self.xdim;
            y = self.ydim;
            [self.mets, map] = sort(self.mets);
            if any(self.media_amt)
                self.media_amt = self.media_amt(map);
            end
            if any(self.diffusion_constants(:))
                self.diffusion_constants = self.diffusion_constants(map,:);
            end
            if any(self.global_media_refresh(:))
                self.global_media_refresh = self.global_media_refresh(map);
            end
            if any(self.media_refresh(:))
                s = size(self.media_refresh);
                if s(1) < nmets
                    self.media_refresh(nmets,x,y) = 0;
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
        
        function self = setDiffusion(varargin)
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
                    error('Metabolites in setDiffusion(layout,mets,values) must be ID''d as a char, a cell array of chars, a single index, or an array of indices');
            end
            
            hasValue = false;
            if nargin > 2 && (varargin{3}(1) || isnumeric(varargin{3}))
                hasValue = true;
                vals = varargin{3};
                if length(vals) == 1
                    vals = repmat(vals,length(midx),1);
                end
                if length(vals) ~= length(midx)
                    error('The third argument in setDiffusion(layout,mets,values) must be empty, false, a single value, or of the same length as the list of mets');
                end
            end
            
            for i = 1:length(midx)
                m = midx(i);
                if hasValue
                    self.diffusion_constants(m,1) = 1;
                    self.diffusion_constants(m,2) = vals(i);
                else
                    self.diffusion_constants(m,1) = 0;
                end
            end
        end
        
        function self = setStaticMedia(varargin)
            %setStaticMedia(layout, x, y, metnames, values)
            %
            %Set if the given metabolites in media are static
            %
            %'x' and 'y' can be single integers or arrays specifying
            %coordinates. If exactly one is an array, the single value will
            %be paired with all members of the array. If both are arrays,
            %the shorter array will be repeated to match the longer.
            %
            %'metnames' can be a single metabolite name, a cell array of
            %metabolite names, a single metabolite index, or an array of
            %metabolite indexes
            %
            %'values' can be a single value, an array of values, false, or
            %not given. If false or not given, the metabolites will have their
            %"set" flag (the first dimension in diffusion_constants) turned
            %off. If a single value, all input metabolites will get that value
            %assigned. If an array, there must be one value per metabolite
            self = varargin{1};
            x = varargin{2};
            y = varargin{3};
            %check coordinate vector dimensions
            %first, linearize them and put them in the same orientation
            x = x(1:end);
            y = y(1:end);
            [temp,xlen] = size(x);
            [temp,ylen] = size(y);
            %if xlen == ylen, do nothing. Otherwise repeat the short one to
            %match the long one
            if (xlen < ylen)
                x = repmat(x,1,ylen);
                x = x(1:ylen);
            end
            if (xlen > ylen)
                y = repmat(y,1,xlen);
                y = y(1:xlen);
            end
            
            midx = [];
            switch class(varargin{4})
                case 'char'
                    midx = metIdx(self,varargin{4});
                case 'cell'
                    c = varargin{4};
                    for i=1:length(c)
                        idx = metIdx(self,c{i});
                        if isempty(idx)
                            self = self.addMets(c(i));
                            idx = metIdx(self,c{i});
                        end
                        midx = [midx idx];
                    end
                case 'double' %this covers single values and arrays of doubles
                    midx = varargin{4};
                otherwise
                    error('Metabolites in setStaticMedia must be ID''d as a char, a cell array of chars, a single index, or an array of indices');
            end
            
            hasValue = false;
            if nargin > 4 && (varargin{5}(1) || isnumeric(varargin{5}))
                hasValue = true;
                vals = varargin{5};
                if length(vals) == 1
                    vals = repmat(vals,length(midx),1);
                end
                if length(vals) ~= length(midx)
                    error('The fifth argument in setStaticMedia must be empty, false, a single value, or of the same length as the list of mets');
                end
            end
            
            %Don't just apply changes to self.static_media(midx,x,y,:)!
            %This will change values in every combination of values in x
            %and y. Instead, iterate over x and y so it's properly done
            %pairwise.
            for i = 1:length(x)
                xi = x(i);
                yi = y(i);
                if hasValue
                    self.static_media(midx,xi,yi,1) = 1;
                    self.static_media(midx,xi,yi,2) = vals;
                else
                    self.static_media(midx,xi,yi,1) = 0;
                end
            end
        end
        
        %applyStaticMediaMask(layout,mask,metnames,values)
        %
        function self = applyStaticMediaMask(self, mask, metnames, values)
            %Set if the given metabolites in the media are static. Instead of
            %specifying x-y coordinates, 'mask' is a logical matrix of the
            %same dimensions as the layout. The static media will be set in
            %every position where mask(x,y) == true
            %
            %'metnames' can be a single metabolite name, a cell array of
            %metabolite names, a single metabolite index, or an array of
            %metabolite indexes
            %
            %'values' can be a single value, an array of values, false, or
            %not given. If false or not given, the metabolites will have their
            %"set" flag (the first dimension in diffusion_constants) turned
            %off. If a single value, all input metabolites will get that value
            %assigned. If an array, there must be one value per metabolite
            
            %simply convert the mask to coordinates then pass everything to
            %setStaticMedia()
            [x,y] = find(mask);
            self = setStaticMedia(self,x,y,metnames,values);
        end
        
        %setMediaRefresh(layout, x, y, metnames, values)
        function self = setMediaRefresh(self, x, y, mets, values)
            %Set the amount to adjust media in the specified cells at each
            %timestep. The concentration in the cell will have the given value
            %added, so units of the values should be concentration.
            %
            %'x' and 'y' can be single integers or arrays specifying
            %coordinates. If exactly one is an array, the single value will
            %be paired with all members of the array. If both are arrays,
            %the shorter array will be repeated to match the longer.
            %
            %'metnames' can be a single metabolite name, a cell array of
            %metabolite names, a single metabolite index, or an array of
            %metabolite indexes
            %
            %'values' can be a single value, or an array of values If a
            %single value, all input metabolites will get that value
            %assigned. If an array, there must be one value per metabolite
            
            %check coordinate vector dimensions
            %first, linearize them and put them in the same orientation
            x = x(1:end);
            y = y(1:end);
            [temp,xlen] = size(x);
            [temp,ylen] = size(y);
            %if xlen == ylen, do nothing. Otherwise repeat the short one to
            %match the long one
            if (xlen < ylen)
                x = repmat(x,1,ylen);
                x = x(1:ylen);
            end
            if (xlen > ylen)
                y = repmat(y,1,xlen);
                y = y(1:xlen);
            end
            
            midx = [];
            switch class(mets)
                case 'char'
                    midx = metIdx(self,mets);
                case 'cell'
                    for i=1:length(mets)
                        midx = [midx metIdx(self,mets{i})];
                    end
                case 'double' %this covers single values and arrays of doubles
                    midx = mets;
                otherwise
                    error('Metabolites in setMediaRefresh must be ID''d as a char, a cell array of chars, a single index, or an array of indices');
            end
            
            vals = values;
            if length(vals) == 1
                vals = repmat(vals,length(midx),1);
            end
            if length(vals) ~= length(midx)
                error('The fifth argument in setMediaRefresh must be a single value or of the same length as the list of mets');
            end
            
            %Don't just apply changes to self.media_refresh(midx,x,y)!
            %This will change values in every combination of values in x
            %and y. Instead, iterate over x and y so it's properly done
            %pairwise.
            for i = 1:length(x)
                xi = x(i);
                yi = y(i);
                vi = vals(i);
                self.media_refresh(midx,xi,yi) = vi;
            end
        end
        
        function self = applyBarrierMask(self, mask)
            %applies the given logical 2D matrix as the barriers in this
            %layout, overriding the previous barriers. If the mask is
            %larger than the layout, the top-left segment of the mask is
            %used.
            mask = mask(1:self.xdim,1:self.ydim);
            self.barrier = mask;
        end
        
        function self = setBarrier(self,x,y)
            %applies barriers to the layout at the given x and y
            %coordinates. If X or Y are a single value, it is paired with
            %every value in the other dimension. Otherwise, x and y should
            %be the same length.
            self = applyBarrierValue(self,x,y,1);
        end
        
        function self = removeBarrier(self,x,y)
            %removes barriers from the layout at the given x and y
            %coordinates. If x or y are a single value, it is paired with
            %every value in the other dimension. Otherwise, x and y should
            %be the same length.
            self = applyBarrierValue(self,x,y,0);
        end
        
        function self = applyBarrierValue(self,x,y,val)
            %internal function to perform the logic of setBarrier() and
            %removeBarrier()
            
            xlen = length(x);
            ylen = length(y);
            
            mask = self.barrier;
            
            if (xlen == 1)
                x = repmat(x,size(y));
                xlen = length(x);
            end
            if (ylen == 1)
                y = repat(y,size(x));
                ylen = length(y);
            end
            
            if ((xlen > 1) && (ylen > 1))
                if (xlen ~= ylen)
                    error('The coordinate lists used to set barriers should be the same length.');
                else
                    for i = 1:xlen
                        mask(x(i),y(i)) = val;
                    end
                end
            end
            
            self = applyBarrierMask(self,mask);
        end
        
        function self = setGlobalStaticMedia(self,metname,val)
            %Sets the given metabolite or list of metabolites to be
            %globally held at the given value or values. To remove a
            %metabolite from this setting, assign it a value < 0
            if ~iscell(metname)
                metname = {metname};
            end
            if length(val) < length(metname)
                val = repmat(val,length(metname),1);
            end
            for i = 1:length(metname)
                metidx = stridx(metname{i},self.mets,false);
                if val(i) >= 0
                    self.global_static_media(metidx,1) = 1;
                    self.global_static_media(metidx,2) = val(i);
                else
                    self.global_static_media(metidx,1) = 0;
                end
            end
        end
        
    end
    
end


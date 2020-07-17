function writeCometsLayout( input, filedir, filename, includeParams, writeModels, modelFileDir)
%WRITECOMETSLAYOUT(input,[filedir],[filename],[includeParams],[writeModels],[modelFileDir]) Create a layout file along with the corresponding model
%files
% Arguments:
%     input: a CometsLayout struct
%     filedir: directory in which files should be created. Defaults to the current working directory
%     includeParams: should a 'parameters' block be included in the start of the file text?
%     writeModels: should model files be created for each model in the given CometsLayout?
%     modelFileDir: Directory that contains the model files. This string
%     will be prepended onto the model file name, but not affect the
%     destination where this script creates the model files (which is
%     set in the filedir argument). This is intended for when the model
%     files are already in a separate location, or an absolute path must be
%     provided because the layout will be executed by a script that is not
%     in the same location as it.
if nargin == 2
    filename = 'layout.txt';
    %filedir = 'layout';
end

if nargin < 4
    includeParams = true; %should the params block be printed within this file?
end
if nargin < 5
    writeModels = true;
end
if nargin < 6
    modelFileDir = '';
end

if isa(input,'string')
    strct=load(input);
    layout=strct.(char(fieldnames(strct)));
else
    if isa(input,'CometsLayout')
        layout=input;
    else
        error(['Invalid argument in writeCometslayout(' class(input)...
            ', ' class(filename) '): The first argument should '...
            'be a well-structured COMETS layout or the path of a '...
            '.mat file containing one.']);
    end
end

% %deprecated- CometsLayout is now a class in order to enforce this %assert
% that the input is a well-structured COMETS layout %check for these fields
% for cf=['models' 'xdim' 'ydim' 'mets' 'media_amt' 'params'
% 'diffusion_const' 'media_refresh']
%     if ~isfield(layout,cf)
%         error(['Invalid argument in writeCometsLayout(' class(input)...
%             ', ' class(filename) '): The input layout requires the '...
%             'following fields: [models xdim ydim mets media_amt params
%             diffusion_const media_refresh]. Identified fields are '
%             (char(fieldnames(model)))]);
%     end
% end

%enforce that layout.models and layout.mets are cell arrays, not single
%objects in order to simplify parsing downstream
if isstruct(layout.models)
    layout.models = {layout.models};
end
if ischar(layout.mets)
    layout.mets = {layout.mets};
end
if ~iscell(layout.models)
    error(['Error in layout format: models should be of type cell array'...
        'or be a single COBRA model struct.']);
end
if ~iscell(layout.mets)
    error(['Error in layout format: mets should be of type cell array'...
        'or char.']);
end

%sort the metabolites in the layout alphabetically. Some sections of the
%layout file may refer to media by their position in the sorted list, not
%their position in the world_media section
layout = sortMetabolites(layout);


filename = fullfile(filedir,filename);
fileID=fopen(filename,'w');

% Parameters
%
% This block contains parameters initially loaded with the file. A list of
% these with their accepted values is here. Here�s the structure of the
% block:
%
% parameters
%   param_1 = value_1
%   param_2 = value_2
%   . . .
%   param_N = value_N
% //
%
% This block is included at the top of the file for now because
% flowDiffRate and growthDiffRate will only be applied if parameters are
% loaded before model files.
if includeParams
    fprintf(fileID,'\tparameters\n');
    
    pfields = fieldnames(layout.params);
    dontPrint = {'defaultReactionLower','defaultReactionUpper','defaultDiffConst','objectiveStyle'};
    logicalFields = {'writeBiomassLog','writeFluxLog','writeMediaLog','writeTotalBiomassLog',...
        'useLogNameTimeStamp','showCycleTime','showCycleCount','saveslideshow',...
        'slideshowColorRelative','simulateActivation','randomOrder','pauseOnStep','allowCellOverlap',...
        'toroidalWorld','colorRelative','slideshowColorRelative','evolution','batchDilution','costlyGenome'};
    integerFields = {'maxCycles','numDiffPerStep','numRunThreads','numExRxnSubsteps','fluxLogRate','mediaLogRate','biomassLogRate','totalBiomassLogRate'};
    for i = 1:length(pfields)
        p = pfields{i};
        if ~ismember(p,dontPrint)
            c = char(p);
            val = getfield(layout.params,c);
            if islogical(val) | ismember(c,logicalFields)
                if val
                    val = 'true';
                else
                    val = 'false';
                end
            end
            if ismember(c,integerFields)
                val = round(val);
            end
            %     if ~ischar(val)
            %         val = char(val);
            %     end
            fprintf(fileID,'\t%s = %s\n',char(p),num2str(val));
        end
    end
    fprintf(fileID,'//\n');
end


% The data blocks in this file are mostly nested within each other. The
% model file block encapsulates the model world and initial population
% blocks. The rest of the blocks are listed in the model world block.


% 1. Model Names This is a single line block, NOT followed by // on a line
% below, but at the end of the file. This must be the first line of the
% layout file. It is followed by the name of at least one FBA model file.
%
% model_file model_file_name1 model_file_name2 ... model_file_name_N 2.
fprintf(fileID,'model_file');
for i = 1:length(layout.models)
    m = layout.models{i};
    mname = [modelFileDir getModelFileName(m)];
    fprintf(fileID,' %s',mname);
end
fprintf(fileID,'\n');

% Model World
%
% This is a single line block, NOT followed by // on a line below, but
% after several internal data blocks. This must be the first block inside
% the model names block. It simply opens up the data block containing the
% world information. Optionally, it can be followed by the name of a file
% containing global media information (note that this is deprecated! Global
% media information should be included in the layout file under the world
% media block).
fprintf(fileID,'\tmodel_world\n');

% 2a. Grid Size
%
% This is required to be the first block under the model world line. It
% doesn�t have a closing //, and only describes the width and height of the
% simulation grid.
%
% grid_size  width  height
fprintf(fileID,'\t\tgrid_size %d %d\n',layout.xdim, layout.ydim);

% 2b. World Media
%
% The world media block contains global information of the quantity of all
% extracellular metabolites in the simulation. Each row in the block has
% two elements � the name of an extracellular metabolite (must be exactly
% as found in the model file) followed by the quantity of that metabolite
% initialized in every block in the simulation.
%
% This block must come before the media refresh, static media, and
% diffusion constants blocks.
%
% world_media
%   metab_1  quantity_1 metab_2  quantity_2 metab_3  quantity_3 . . .
%   metab_N  quantity_N
% //
fprintf(fileID,'\t\tworld_media\n');
for i = 1:length(layout.mets)
    m = layout.mets{i};
    idx = layout.metIdx(m);
    m = strrep(m,' ','_');
    fprintf(fileID,'\t\t%s %g\n',char(m),layout.media_amt(idx));
end
fprintf(fileID,'\t//\n');
% 2c. Diffusion Constants
%
% The diffusion constants block contains diffusion constant information for
% the extracellular metabolites in the simulation. The block begins with a
% global default value on the same line as the opening tag. Each row in the
% block, then, has two elements � the index of the metabolite in question,
% in the same order as in the world_media block above (starting from 0);
% and a value for the diffusion constant if it differs from the default.
%
% diffusion_constants    default_value
%   index_1  diff_const_1 index_2  diff_const_2 index_3  diff_const_3 . . .
ddiff = layout.params.defaultDiffConst;
fprintf(fileID,'\tdiffusion_constants %d\n',ddiff);
if any(layout.diffusion_constants(:,1))
    for i = 1:length(layout.mets)
        m = layout.mets{i};
        idx = layout.metIdx(m);
        if idx && layout.diffusion_constants(idx,1) %if the diffusion constant is set
            dc = layout.diffusion_constants(idx,2);
            if dc ~= ddiff %and the diffusion constant is not equal to the default
                fprintf(fileID,'\t\t%d %g\n',idx-1,dc);
            end
        end
    end
end
fprintf(fileID,'\t//\n');

% // Media
% This section should handle specification of media on a cell-by-cell
% basis.
fprintf(fileID,'\tmedia\n');

ms = size(layout.initial_media);
%s = [# metabolites in media, x, y]

if length(ms) < 3 %don't break the loop if static_media is empty or 1x1
    ms(3) = 1;
end

for x = 1:ms(2) %for each x coordinate
    for y = 1:ms(3) %and each y coordinate
        v = layout.initial_media(:,x,y,1);%is it set?
        if length(v) < length(layout.mets)%must include a value for all media
            v(length(layout.mets)) = 0;
        end
        if any(v)
            fprintf(fileID,'\t\t%d %d',x-1,y-1);
            for j = 1:length(v)
                if v(j) %this medium is set
                    fprintf(fileID,' %d', layout.initial_media(j,x,y,2));
                else %use the global value
                    fprintf(fileID,' %d', layout.media_amt(j));
                end
            end
            fprintf(fileID,'\n');
        end
    end
end
fprintf(fileID,'\t//\n');

% // 2d. Media Refresh
%
% This block describes how much each medium component should be refreshed
% on each simulation cycle in any given grid space. The opening line
% contains global refresh values for each medium component, in the same
% order as presented in the world media block.
%
% Each proceeding row contains the amount of media to refresh for each grid
% space where there is a nonzero refresh value. That is, the only rows that
% should be present in this block should contain some amount of medium to
% be refreshed.
%
% media_refresh  global_amt_1  global_amt_2  ...  global_amt_N
%   row_1  col_1  amt_1  amt_2  amt_3  ...  amt_N row_2  col_2  amt_1 amt_2
%   amt_3  ...  amt_N row_3  col_3  amt_1  amt_2  amt_3  ...  amt_N . . .
%   row_M  col_M  amt_1  amt_2  amt_3  ...  amt_N
fprintf(fileID,'\tmedia_refresh');
fprintf(fileID,' %d',layout.global_media_refresh);
fprintf(fileID,'\n');

[mdim,xdim,ydim] = size(layout.media_refresh);
for x = 1:xdim
    for y = 1:ydim
        row = layout.media_refresh(1:mdim,x,y);
        if any(row)
            %fprintf(fileID,'\t\t%d %d %g\n',x-1,y-1,row);
            fprintf(fileID,'\t\t%d %d ',x-1,y-1);
            for i = 1:length(row)
                fprintf(fileID,'%d ',row(i));
            end
            fprintf(fileID,'\n');
        end
    end
end
fprintf(fileID,'\t//\n');

% // 2e. Static Media
%
% Like the media refresh block, this describes how the media in each space
% in the grid should be altered during the simulation. However, this block
% describes which media components should remain at a static value. That
% is, those media whose quantities should not change due to the effects of
% the simulation. This might represent a constant sink or source of a
% number of metabolites.
%
% This block contains pairs of data elements. Each pair starts with a
% binary (0 or 1) element, denoting whether or not to use that pair as a
% static element, and a quantity to keep that element static at. This lets
% one build a static media set where only a few medium elements are
% maintained as static, while keeping the file structure similar to the
% media refresh block above.
%
% For example:
%
% static_media  0  0  1  0  1  2  0  0 // Breaks into 4 pairs [0 0], [1 0],
% [1 2], [0 0]. Only components 2 and 3 have a 1 as their first element, so
% those medium components are kept static. Component 2 remains at 0, while
% component 3 stays at 2. Note that in this example, there are no
% exceptions, so this applies throughout the simulation. In general, it is
% done like this:
%
% static_media  use_1  amt_1  use_2  amt_2  use_3  amt_3  ...  use_N  amt_N
%   row_1  col_1  use_1  amt_1  use_2  amt_2  ...  use_N  amt_N row_2 col_2
%   use_1  amt_1  use_2  amt_2  ...  use_N  amt_N row_3  col_3 use_1  amt_1
%   use_2  amt_2  ...  use_N  amt_N . . . row_M  col_M  use_1 amt_1  use_2
%   amt_2  ...  use_N  amt_N
fprintf(fileID,'\tstatic_media');
gs = size(layout.global_static_media);
for row = 1:gs(1)
    fprintf(fileID,' %g',layout.global_static_media(row,:));
end
fprintf(fileID,'\n');

s = size(layout.static_media);

if length(s) < 3 %don't break the loop if static_media is empty or 1x1
    s(3) = 1;
end

if any(find(layout.static_media(:,:,:,1)))
    for x = 1:s(2)
        for y = 1:s(3)
            b = layout.static_media(:,x,y,1);%is this medium static?
            v = layout.static_media(:,x,y,2);%values
            i = find(b); %indexes
            if any(i)
                %            b = zeros(1,gs(1));
                %            b(i) = 1; %is this medium static?
                sm = [b';v'];
                row = sm(1:(2*gs(1)));%pairs of logical/value for each media
                fprintf(fileID,'\t\t%d %d',x-1,y-1);
                for j = 1:length(row)
                    fprintf(fileID,' %d',row(j));
                end
                fprintf(fileID,'\n');
            end
        end
    end
end
fprintf(fileID,'\t//\n');

%% // 2f. Barrier Coordinates
%
% Simple enough, this block describes those grid coordinates that contain
% barriers (i.e., no media, biomass, or diffusion can occur here).
%
% barrier
%   row_1  col_1 row_2  col_2 row_3  col_3 . . . row_N  col_N
fprintf(fileID,'\tbarrier\n');
s = size(layout.barrier);
for x = 1:s(1)
    for y = 1:s(2)
        if layout.barrier(x,y)
            fprintf(fileID,'\t\t%d %d\n',x-1,y-1);
        end
    end
end
fprintf(fileID,'\t//\n');


%% 2g Periodic media
% This block describes what and where should be the periodic media.
% There are two settings, global and detailed. 
% Global:
% metIndex  functionName   amplitude period  phase offset
%
% Detailed:
% metIndex functionName    rowIndex  colIndex amplitude period phase offset

if ~isempty(layout.global_periodic_media)   
    % Global mode
    fprintf(fileID,'\tperiodic_media\tglobal\n');
    % Iterate over array and print if amplitude is > 0
    for i=1:length(layout.global_periodic_media)
        gpm_i = layout.global_periodic_media{i};
        fprintf(fileID,'\t\t%d', gpm_i.idx - 1);
        fprintf(fileID,'\t%s', gpm_i.funcname);
        fprintf(fileID,'\t%d', gpm_i.amplitude);
        fprintf(fileID,'\t%d', gpm_i.period);
        fprintf(fileID,'\t%d', gpm_i.phase);
        fprintf(fileID,'\t%d', gpm_i.offset);
        fprintf(fileID,'\n');
    end
elseif ~isempty(layout.detailed_periodic_media)
    % Detailed mode
    fprintf(fileID,'\tperiodic_media\tdetailed\n');
    for i=1:length(layout.detailed_periodic_media)
        dpm_i = layout.detailed_periodic_media{i};
        fprintf(fileID,'\t\t%d', dpm_i.idx - 1);
        fprintf(fileID,'\t%s', dpm_i.funcname);
        fprintf(fileID,'\t%d', dpm_i.x - 1);
        fprintf(fileID,'\t%d', dpm_i.y - 1);
        fprintf(fileID,'\t%d', dpm_i.amplitude);
        fprintf(fileID,'\t%d', dpm_i.period);
        fprintf(fileID,'\t%d', dpm_i.phase);
        fprintf(fileID,'\t%d', dpm_i.offset);
        fprintf(fileID,'\n');
    end
    
end
fprintf(fileID, "\t//\n");
fprintf(fileID,'//\n');
% // 3. Initial Biomass Population
%
% This final block describes the initial biomass population in the layout,
% and has many options.
%
% In the default biomass layout style, there is just initial_pop left alone
% as the header, followed by one row for each grid space containing
% biomass. There must be one quantity for each metabolic model in the
% system.
%
% initial_pop
%   row_1  col_1  biomass_1  biomass_2  ...  biomass_N row_2  col_2
%   biomass_1  biomass_2  ...  biomass_N row_3  col_3  biomass_1  biomass_2
%   ...  biomass_N . . . row_M  col_M  biomass_1  biomass_2  ...  biomass_N
% // The next set of options modify the initial_pop line itself, and
% contain no rows in the block, though the // on the line below must be
% present.
% NOTE: all coordinates here are 0-indexed!
%
% initial_pop  random  N1  biomass_1  N2  biomass_2 ... // This will
% randomly assign Ni spaces to have biomass_i amount of biomass from model
% i. If biomass from different species is allowed to overlap, then that is
% allowed to happen in this case, but if different species is not allowed
% to overlap, then that rule is upheld.
%
% initial_pop  random_rect  X  Y  W  H  N1  biomass_1  N2  biomass_2 ... //
% As above, but the randomly assigned biomass spots are confined to a
% rectangle with its upper-left corner at grid space (X,Y), with W grid
% spaces wide, and H spaces tall.
%
% initial_pop  filled  biomass_1  biomass_2 ... // This will completely
% fill the grid with the given amount of biomass from each species.
%
% initial_pop  filled_rect  X  Y  W  H  biomass_1  biomass_2 ... // This
% will completely fill the rectangle (see above) with biomass from each
% species.
%
% initial_pop  square  N1  biomass_1  N2  biomass_2 ... // This will fill
% squares with radius Ni at the center of the grid with biomass_i from
% species i.
if sum(sum(any(layout.initial_pop))) > 0 %some initial pop is set
    fprintf(fileID,'initial_pop\n');
    s = size(layout.initial_pop);
    if length(s) < 3 %don't break the loop if initial_pop is empty or 1x1
        s(3) = 1;
    end
    for x = 1:s(2)
        for y = 1:s(3)
            v = layout.initial_pop(:,x,y);
            if any(v)
                %x y pop1 pop2 pop3...
                fprintf(fileID,['\t%d %d' sprintf(' %d',v) '\n'],x-1,y-1);
            end
        end
    end
    fprintf(fileID,'//\n');
else %no initial pop is set
%     fprintf(fileID,'initial_pop filled');
%     for i=1:length(layout.models)
%         fprintf(fileID,' 1E-7');
%     end
    fprintf(fileID,'initial_pop');
    fprintf(fileID,'\n');
    fprintf(fileID,'//\n');
end

%if external reactions are set, print the relevent block
if ~isempty(layout.external_rxn_mets)
    fprintf(fileID,'reactions\n');
    fprintf(fileID,'\treactants\n');
    mets = layout.external_rxn_mets;
    rxns = layout.external_rxns;
    metdims = size(mets);
    nrows = metdims(1);
    reactionnames = rxns.name;
    for i = 1:nrows
        row = mets(i,:);
        if row.stoich < 0 %only write reactants here
            metidx = stridx(row.met{1},layout.mets,false);
            rxnidx = stridx(row.rxn{1},reactionnames,false);
            rxnrow = rxns(rxnidx,:);
            if isempty(rxnrow.enzyme{1}) %no enzyme
                sto = -row.stoich;
                k = rxnrow.k;
                fprintf(fileID,'\t\t%d %d %d %d\n', rxnidx, metidx, sto, k);
            else %enzyme catalyzed
                km = rxnrow.km;
                fprintf(fileID,'\t\t%d %d %d\n', rxnidx, metidx, km);
            end
        end
    end
    fprintf(fileID,'\tenzymes\n');
    rxndims = size(rxns);
    nrows = rxndims(1);
    for i = 1:nrows
        row = rxns(i,:);
        if ~isempty(row.enzyme{1})
            enzidx = stridx(row.enzyme{1},layout.mets,false);
            fprintf(fileID,'\t\t%d %d %d\n', i, enzidx, row.k);
        end
    end
    fprintf(fileID,'\tproducts\n');
    nrows = metdims(1);
    for i = 1:nrows
        row = mets(i,:);
        rxnidx = stridx(row.rxn{1},reactionnames,false);
        if row.stoich > 0
            metidx = stridx(row.met{1},layout.mets,false);
            sto = row.stoich;
            fprintf(fileID,'\t\t%d %d %d\n', rxnidx, metidx, sto);
        end
    end
    fprintf(fileID,'//\n');
end

fclose(fileID);

%write the model files
if writeModels
    for i = 1:length(layout.models)
        m = layout.models{i};
        writeCometsModel(m,getModelFilePath(m),layout.params);
    end
end

    function mname = getModelFileName(model)
        name = getModelName(model);
        mname = [name '.txt']; %relative path; file goes in current directory
    end
    function mname = getModelFilePath(model)
        fname = getModelFileName(model);
        mname = fullfile(filedir,fname); %absolute path
    end

end


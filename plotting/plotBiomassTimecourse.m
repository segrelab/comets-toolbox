function f = plotBiomassTimecourse(table,modelNames,logscale)
%PLOTBIOMASSTIMECOURSE(table,[logscale]) create a line plot of the total 
%amount of the biomass for each species. 
%The first argument should be a data table loaded through parseBiomassLog.m

nmodels = max(table.model) + 1;

%create model names if not given
if nargin < 2
     modelNames = {};
     for i = 1:nmodels
         modelNames = [modelNames {['Model ' num2str(i)]}];
     end
end

if nargin < 3
    logscale = true;
end

f = figure();
hold on;
for i = 1:nmodels
    %sum each timestep
    tab = table(table.model == i-1,:);
    t = unique(tab.t);
    bio = zeros(length(t),1);
    for j = 1:length(t)
        steptab = tab(tab.t == t(j),:);
        bio(j) = sum(steptab.biomass);
    end
    plot(t,bio,'LineWidth',2,'DisplayName',modelNames{i});
end

if logscale
    set(gca,'yscale','log');
end

%set number of columns in the legend
ncol = nmodels;
if nmodels >= 5
    ncol = 3;
end
if nmodels >= 7
    ncol = 4;
end

if nmodels > 1
    leg = legend('location','southoutside');
    set(leg,'NumColumns',ncol);
end

xlabel('Timestep');
ylabel('Biomass (g)');

end


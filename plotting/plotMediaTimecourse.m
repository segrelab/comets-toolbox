function p = plotMediaTimecourse(table,metnames,scale,linewidth)
%PLOTMEDIATIMECOURSE(table,{metnames},[scale],lineweight) create a line plot of the total 
%amount of the specified metabolites. 
%The first argument should be a data table loaded through parseMediaLog.m
%Scale is one of 'normal' (default), 'log', or 'relative'. The first letter
%of each option is also valid.
%   for legacy reasons from when the parameter was "logscale",
%   false='normal' and true= 'log'
%   'Relative' scales each metabolite to its own max concentration
if nargin < 3
    scale = 'normal';
end

if nargin >= 3
    if islogical(scale)
        if scale
            scale = 'log';
        else
            scale = 'normal';
        end
    else %clean up input
        switch upper(scale(1))
            case 'N'
                scale = 'normal';
            case 'L'
                scale = 'log';
            case 'R'
                scale = 'relative';
            case 'T'
                scale = 'log';
            case 'F'
                scale = 'normal';
            otherwise
                scale = 'normal';
        end
    end
end
        

if nargin < 4
    linewidth = 2;
end

if ischar(metnames) %if given one metabolite to plot
    metnames = {metnames};
end

nummets = length(metnames);
%set number of columns in the legend
ncol = nummets;
if nummets >= 5
    ncol = 3;
end
if nummets >= 7
    ncol = 4;
end

x = unique(table.t);
y = zeros(length(x),nummets);

ncells = max(table.x) * max(table.y);
for i = 1:length(metnames)
    met = metnames{i};
    st = table(strcmp(met,table.metname),:);
    
    %sum all cells at the same timepoint
    amt = reshape(st.amt,length(x),ncells);
    amt = sum(amt,2);
    
    if strcmpi(scale,'relative')
        amt = amt/(max(amt));
    end
    
    y(:,i) = amt;
end

p = plot(x,y,'LineWidth',linewidth);
if strcmpi(scale,'log')
    set(gca,'YScale','log');
end
leg = legend(metnames,'location','southoutside','Interpreter', 'none');
set(leg,'NumColumns',ncol);
xlabel('Timestep');
yl = 'Concentration (mmol)';
if strcmpi(scale,'relative')
    yl = 'Relative Concentraion';
end
ylabel(yl);
end


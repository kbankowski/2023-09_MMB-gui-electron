%% Pre-amble
clear all
close all
clc

projectPath = '/Users/kk/Documents/0000-00_work/2023-09_MMB-gui-electron';
subProjectPath = 'mmb-electron.app/Contents/Resources/app/dist/electron/static/mmci-cli';

%% Running the models with all rules specified in config_4
mmb('config_4.json','var');

%% Read the simulation results into one structure
% List of common rules based on the invesitation in the following driver
% mmb-electron.app/Contents/Resources/app/dist/electron/static/mmci-cli/mmb_checkCommonRules.m
ruleList = {'CEE', 'CMR', 'Coenen', 'GR', 'LWW', 'OW08', 'OW13', 'SW', 'Taylor', 'Model'};
mmbVarList = ["interest", "inflation", "inflationq", "outputgap", "output"];

% looping through all rules
for aRule = string(ruleList)
    fname = fullfile('out', sprintf('ESREA_FIMOD12-%s.output.json', aRule)); 
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    val = jsondecode(str);
    for mmbVar = mmbVarList
        mmbDatabank.(aRule).(mmbVar) = Series(qq(0, 4), val.data.IRF.interest_.(mmbVar));
    end
end

%% Create a histogram out of rules
plotFiModWithDiffRules(mmbDatabank, string(ruleList), mmbVarList, projectPath, subProjectPath);

%% local function to plot the histogram and save it
function plotFiModWithDiffRules(mmbDatabank, ruleList, mmbVarList, projectPath, subProjectPath)

    % Please specify the date range of the series
    dateRange = qq(1,1):qq(5,4);
    
    % Plotting
    figure
    
    % Defining the shape of the figure
    tiledlayout_width = 3; %Specify the # of columns desired
    tiledlayout_height = 2;
    
    t = tiledlayout(tiledlayout_height, tiledlayout_width, 'TileSpacing', 'compact','Padding','compact');
    
    h = gcf;
    
    cmap = subroutines.linspecer(numel(ruleList));
    
    set(h, 'Units','centimeters', 'Position',[0 0 21-2 8])
    set(h,'defaulttextinterpreter','latex');
    
    for mmbVar = mmbVarList %for each panel
        nexttile;
        grid on
        hold on 
        
        title(mmbVar ...
            ,'Fontsize', 8 ...
            ,'Fontweight', 'normal'...
        );
            
        for aRule = ruleList
            pp.(aRule) = plot(...
                mmbDatabank.(aRule).(mmbVar)(dateRange) ...
                , 'Color',cmap(aRule==ruleList, :)...
                , 'Linewidth',1.5 ...
            );
        end
                
        hold off
        
        % Setting of the x and y axis
        set(gca ...
...            , 'Xtick', 0:5:60 ...
            , 'Fontsize', 8 ...
            , 'Box', 'off' ...
            , 'TickLabelInterpreter','latex' ...
        );
    
    end 
    
       
    % Setting of the legend   
    leg = legend(...
        struct2array(pp)...
        , ruleList...
        , 'Orientation', 'horizontal'...
        , 'Color', [1 1 1]...
        , 'Fontsize', 8 ...
        , 'Interpreter', 'latex' ...
    );
    leg.Layout.Tile = 'north';
    leg.NumColumns = 5;
        
    % Save graph
    fileName = fullfile(projectPath, subProjectPath, "docs/figures", "FiModWithDiffRules");
    exportgraphics(t, sprintf('%s.png',fileName),'BackgroundColor','none');

end
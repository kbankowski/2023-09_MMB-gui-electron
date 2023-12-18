%% Pre-amble
clear all; close all; clc
[projectPath, subProjectPath, ~, ~] = init();

%% Running the models with all rules specified in config_4
mmb('config_6.json','var');

%% Read the simulation results into one structure
modelListForLoop =  ["ESREA_FIMOD12", "DEREA_GEAR16"];
mmbVarList = ["interest", "inflation", "inflationq", "outputgap", "output", "consumption", "investment", "employment", "wage"];

% looping through all models
for aModel = modelListForLoop
    fname = fullfile('out', sprintf('%s-SW.output.json', aModel)); 
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    val = jsondecode(str);
    for aShock = ["interest_", "fiscal_"]
        for mmbVar = mmbVarList
            try
                mmbDatabank.(aModel).(aShock).(mmbVar) = Series(qq(0, 4), val.data.IRF.(aShock).(mmbVar));
            catch
                mmbDatabank.(aModel).(aShock).(mmbVar) = Series(qq(0, 4): qq(0, 4)+20, NaN);
                fprintf('%s variable not found in the %s model results for %s shock\n', mmbVar, aModel, aShock);
            end
        end
    end
end

%% Create a histogram out of rules
% re-ordering the list to put FiMod last so that it is plotted on top of
% everything
modelListForPlotting = modelListForLoop;
plotFispolModels(mmbDatabank, modelListForPlotting, mmbVarList, projectPath, subProjectPath);

%% local function to plot the histogram and save it
function plotFispolModels(mmbDatabank, modelList, mmbVarList, projectPath, subProjectPath)

    % Please specify the date range of the series
    dateRange = qq(1,1): qq(5,4);
    
    % Plotting
    figure
    
    % Defining the shape of the figure
    tiledlayout_width = 3; %Specify the # of columns desired
    tiledlayout_height = 3;
    
    t = tiledlayout(tiledlayout_height, tiledlayout_width, 'TileSpacing', 'compact','Padding','compact');
    
    h = gcf;
    
    cmap = subroutines.linspecer(numel(modelList));
    
    set(h, 'Units','centimeters', 'Position',[0 0 21-2 12])
    set(h,'defaulttextinterpreter','latex');
    
    for mmbVar = mmbVarList %for each panel
        nexttile;
        grid on
        hold on 
        
        title(mmbVar ...
            ,'Fontsize', 8 ...
            ,'Fontweight', 'normal'...
        );
            
        for aModel = modelList
            try
                pp.(aModel) = plot(...
                    mmbDatabank.(aModel).fiscal_.(mmbVar)(dateRange) ...
                    , 'Color', cmap(aModel==modelList, :) ...
                    , 'Linewidth', 2 ...
                );
            catch
            end
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
        struct2array(pp) ...
        , ["FiMod", "GEAR"] ...
        , 'Orientation', 'horizontal' ...
        , 'Color', [1 1 1] ...
        , 'Fontsize', 8 ...
        , 'Interpreter', 'latex' ...
    );
    leg.Layout.Tile = 'north';
        
    % Save graph
    fileName = fullfile(projectPath, subProjectPath, "docs/figures", "FispolModels");
    exportgraphics(t, sprintf('%s.png',fileName),'BackgroundColor','none');

end
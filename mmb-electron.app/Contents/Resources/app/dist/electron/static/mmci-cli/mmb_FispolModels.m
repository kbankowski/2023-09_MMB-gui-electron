%% Pre-amble
clear all; close all; clc
[projectPath, subProjectPath, ~, ~] = init();

%% Running the models with all rules specified in config_4
mmb('config_6.json','var');

%% Read the simulation results into one structure
modelList = subroutines.createModelList(projectPath, subProjectPath);
modelListExclude = ["NK_GK11", "US_AJ16"];
modelListForLoop =  setdiff(string(modelList), modelListExclude);
mmbVarList = ["interest", "inflation", "inflationq", "outputgap", "output"];

% looping through all models
for aModel = modelListForLoop
    fname = fullfile('out', sprintf('%s-SW.output.json', aModel)); 
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    val = jsondecode(str);
    for mmbVar = mmbVarList
        try
            mmbDatabank.(aModel).(mmbVar) = Series(qq(0, 4), val.data.IRF.interest_.(mmbVar));
        catch
            mmbDatabank.(aModel).(mmbVar) = Series(qq(0, 4): qq(0, 4)+20, NaN);
            fprintf('%s variable not found in the %s model results\n', mmbVar, aModel);
        end
    end
end

%% Create a histogram out of rules
% re-ordering the list to put FiMod last so that it is plotted on top of
% everything
selectedModels = ["DEREA_GEAR16", "ESREA_FIMOD12"];
modelListForPlotting = [ ...
    modelListForLoop(~ismember(modelListForLoop, selectedModels)) ...
    , selectedModels ...
];
plotSWruleWithDiffModels(mmbDatabank, modelListForPlotting, mmbVarList, projectPath, subProjectPath);

%% local function to plot the histogram and save it
function plotSWruleWithDiffModels(mmbDatabank, modelList, mmbVarList, projectPath, subProjectPath)

    % Please specify the date range of the series
    dateRange = qq(1,1): qq(5,4);
    % model selector function
    modelSelector = @(aModel) strcmp(aModel, "ESREA_FIMOD12") || strcmp(aModel, "DEREA_GEAR16");
    % thicker Line for selected models
    lineWidthSelector = @(aModel) 2 * modelSelector(aModel) + 1 * ~modelSelector(aModel);
    % less transparency for selected models
    lineTransparencySelector = @(aModel) 1 * modelSelector(aModel) + 0.5 * ~modelSelector(aModel);

    
    % Plotting
    figure
    
    % Defining the shape of the figure
    tiledlayout_width = 3; %Specify the # of columns desired
    tiledlayout_height = 2;
    
    t = tiledlayout(tiledlayout_height, tiledlayout_width, 'TileSpacing', 'compact','Padding','compact');
    
    h = gcf;
    
    % replication of light gray colour for all non-FiMod and non-GEAR models
    cmap = repmat([0.702 0.702 0.702], numel(modelList)-2, 1);
    % based on the following palette 
    % https://www.simplifiedsciencepublishing.com/resources/best-color-palettes-for-scientific-figures-and-data-visualizations
    % #c1272d - Dark Red
    % #0000a7 - Indigo
    % #eecc16 - Yellow
    % #008176 - Teal
    % #b3b3b3 - Light Gray
    line1color = [0, 0, 0.6549];
    line2color = [0.756, 0.153, 0.176];
    
    cmap = [cmap; line1color; line2color];
    
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
            
        for aModel = modelList
            pp.(aModel) = plot(...
                mmbDatabank.(aModel).(mmbVar)(dateRange) ...
                , 'Color', [cmap(aModel==modelList, :), lineTransparencySelector(aModel)] ...
                , 'Linewidth', lineWidthSelector(aModel) ...
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
    
    % since we plot model at the end so that it overlays other lines we
    % move it to the front of the legend
    pickLastAndFirst = @(x) [x(end), x(end-1), x(1)];

    % Setting of the legend   
    leg = legend(...
        pickLastAndFirst(struct2array(pp)) ...
        , ["FiMod", "GEAR", "other models"] ...
        , 'Orientation', 'horizontal' ...
        , 'Color', [1 1 1] ...
        , 'Fontsize', 8 ...
        , 'Interpreter', 'latex' ...
    );
    leg.Layout.Tile = 'north';
        
    % Save graph
    fileName = fullfile(projectPath, subProjectPath, "docs/figures", "SWruleWithDiffModels");
    exportgraphics(t, sprintf('%s.png',fileName),'BackgroundColor','none');

end
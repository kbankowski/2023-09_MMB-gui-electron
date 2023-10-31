
clear all
close all
clc

projectPath = '/Users/kk/Documents/0000-00_work/2023-09_MMB-gui-electron';
subProjectPath = 'mmb-electron.app/Contents/Resources/app/dist/electron/static/mmci-cli';

%% Create a list of all models
% Define the folder you want to look in
folder = fullfile(projectPath, subProjectPath, "models");
% Get a list of all files and folders in this folder
files = dir(folder);
% Filter out all the files (keep only directories)
directories = files([files.isdir]);
% Remove '.' and '..' from the list
directories = directories(~ismember({directories.name}, {'.', '..'}));
% Optionally, extract a list of directory names
modelList = string({directories.name});

%% Loop through all models and collect the valid rules
ruleList = {};
for aModel = modelList
    fname = fullfile(projectPath, subProjectPath, "models", aModel, aModel+".json"); 
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    val = jsondecode(str);
    ruleList = [ruleList, val.capabilities.rules'];
end

%% Create a histogram out of rules
plotHistogramRules(ruleList, projectPath, subProjectPath);

%% local function to plot the histogram and save it
function plotHistogramRules(ruleList, projectPath, subProjectPath)

    % Plotting
    figure
    
    % Defining the shape of the figure
    tiledlayout_width = 1;
    tiledlayout_height = 1;
    
    t = tiledlayout(tiledlayout_height, tiledlayout_width, 'TileSpacing', 'compact','Padding','compact');
    
    h = gcf;
    
    cmap = subroutines.linspecer(1);
    
    set(h, 'Units','centimeters', 'Position',[0 0 21-2*2.5 7])
    set(h,'defaulttextinterpreter','latex');
    
    nexttile;
    grid on
    hold on 
    
    histogram(categorical(ruleList));
    
    hold off
    
    % Setting of the x and y axis
    set(gca ...
        , 'Fontsize', 7 ...
        , 'Box', 'off' ...
        , 'TickLabelInterpreter','latex' ...
    );
        
    % Save graph
    fileName = fullfile(projectPath, subProjectPath, "docs/figures", "rulesHistogram");
    exportgraphics(t, sprintf('%s.png',fileName),'BackgroundColor','none');

end
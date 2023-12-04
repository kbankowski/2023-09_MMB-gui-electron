%% Pre-amble
clear all
close all
clc
[projectPath, subProjectPath, projectPathFimod] = init();

%% Running the models with all rules specified in config_4
mmb('config_4g.json','var');

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


%% Read to rules to see their values
fileID = fopen('docs/ruleMPvarNames.txt');
% Read the data into a cell array
data = textscan(fileID, '%s', 'Delimiter', '\n', 'Whitespace', '');
coffNames = replace(string(data{1}), " ", "_");
% Close the file
fclose(fileID);

% initiating the table
coeffTable = table( ...
    'Size', [length(coffNames) length(ruleList)] ...
    , 'VariableTypes', repmat("double", 1, length(ruleList)) ...
    , 'VariableNames', ruleList ...
    , 'RowNames', coffNames ...
);

% reading the parameters of standard rules from json files
for aRule = string(ruleList(1:end-1))
    fname = fullfile('rules', aRule, sprintf('%s.json', aRule)); 
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    val = jsondecode(str);
    rulesCoeff.(aRule) = vertcat(cellfun(@(x) eval(x), val.coefficients));
    coeffTable{:, aRule} = rulesCoeff.(aRule);
end

% reading the model specific rule
fname = fullfile('models', 'ESREA_FIMOD12', sprintf('%s.json', 'ESREA_FIMOD12')); 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val = jsondecode(str);
rulesCoeff.("Model") = vertcat(cellfun(@(x) eval(x), val.msr));

% storing the numbers in the table
for aRule = string(ruleList)
    coeffTable{:, aRule} = rulesCoeff.(aRule);
end

% saving the latex table out of the Matlab table
texFileName = char(fullfile(projectPath, subProjectPath, "docs/tex", "rulesParameters.tex"));
subroutines.table2latex(coeffTable, texFileName);

%% Create a histogram out of rules
plotFiModWithDiffRules(mmbDatabank, string(ruleList), mmbVarList, projectPath, subProjectPath);

%% local function to plot the histogram and save it
function plotFiModWithDiffRules(mmbDatabank, ruleList, mmbVarList, projectPath, subProjectPath)

    % Please specify the date range of the series
    dateRange = qq(1,1): qq(5,4);
    % thicker Line for Model-Specific-Rule
    lineWidthSelector = @(aString) 2 * strcmp(aString, "Model") + 1 * ~strcmp(aString, "Model");
    % thicker Line for Model-Specific-Rule
    lineTransparencySelector = @(aString) 1 * strcmp(aString, "Model") + 0.5 * ~strcmp(aString, "Model");

    
    % Plotting
    figure
    
    % Defining the shape of the figure
    tiledlayout_width = 3; %Specify the # of columns desired
    tiledlayout_height = 2;
    
    t = tiledlayout(tiledlayout_height, tiledlayout_width, 'TileSpacing', 'compact','Padding','compact');
    
    h = gcf;
    
    cmap = subroutines.linspecer(numel(ruleList)-1);
    % based on the following palette 
    % https://www.simplifiedsciencepublishing.com/resources/best-color-palettes-for-scientific-figures-and-data-visualizations
    % #c1272d - Dark Red
    % #0000a7 - Indigo
    % #eecc16 - Yellow
    % #008176 - Teal
    % #b3b3b3 - Light Gray
    line1color = [0, 0, 0.6549];
    cmap = [cmap; line1color];
    
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
                , 'Color', [cmap(aRule==ruleList, :), lineTransparencySelector(aRule)] ...
                , 'Linewidth', lineWidthSelector(aRule) ...
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
    moveLastToFirstFunc = @(x) [x(end), x(1:end-1)];

    % Setting of the legend   
    leg = legend(...
        moveLastToFirstFunc(struct2array(pp)) ...
        , moveLastToFirstFunc(fieldnames(pp)') ...
        , 'Orientation', 'horizontal' ...
        , 'Color', [1 1 1] ...
        , 'Fontsize', 8 ...
        , 'Interpreter', 'latex' ...
    );
    leg.Layout.Tile = 'north';
    leg.NumColumns = 5;
        
    % Save graph
    fileName = fullfile(projectPath, subProjectPath, "docs/figures", "FiModWithDiffRules");
    exportgraphics(t, sprintf('%s.png',fileName),'BackgroundColor','none');

end
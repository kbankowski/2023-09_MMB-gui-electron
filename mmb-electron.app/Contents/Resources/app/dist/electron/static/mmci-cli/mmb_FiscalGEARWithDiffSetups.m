% This driver is used to make sure that the results of the fiscal shock in
% the GEAR project are identical to these produced in the MMB; the starting
% point is that they look fine in the GEAR but not in the MMB
% //TODO: NEXT STEP; GEAR has to be based on the baseline version; set up
% MMB folder in the GEAR project and based on the baseline version create a
% model

%% Pre-amble
clear all; close all; clc
[projectPath, subProjectPath, projectPathFiMod, projectPathGEAR] = init();

%%
mmb('config_7.json','var');

%% values simulated with MMB
% reading in the json file produced with the mmb('config_2.json','var')
% command
fname = fullfile(projectPath, subProjectPath, 'out', 'DEREA_GEAR16-Model.output.json'); 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val = jsondecode(str);

% deviations as a databank
for aSer = string(reshape(fieldnames(val.data.IRF.fiscal_), 1, []))
    resMMB.(aSer) = Series(qq(0, 4), val.data.IRF.fiscal_.(aSer));
end

%% values coming from GEAR project (version 2 for the paper with FT)
matFilePath = fullfile(projectPathGEAR, "/baseline/Buba_Fiskal_Erweiterung_baseline/Output/Buba_Fiskal_Erweiterung_baseline_results.mat");
aDataGEARver2 = load(matFilePath);

% reduce the structure to a relavant shock only
fieldList = fieldnames(aDataGEARver2.oo_.irfs);
aStructSelected = rmfield(aDataGEARver2.oo_.irfs, fieldList(~endsWith(fieldList, "_nua_ecG")));
% just saving as a databank with renaming
resGEAROrigVer2 = databank.fromArray( ...
    cell2mat(struct2cell(aStructSelected))' ...
    , extractBefore(databank.fieldNames(aStructSelected), "_nua_ecG") ...
    , qq(1) ...
);

%% new GEAR version for MMB (version 3)
matFilePath = fullfile(projectPathGEAR, "/mmb/GEAR/Output/GEAR_results.mat");
aDataGEARver3 = load(matFilePath);

% reduce the structure to a relavant shock only
fieldList = fieldnames(aDataGEARver3.oo_.irfs);
aStructSelected = rmfield(aDataGEARver3.oo_.irfs, fieldList(~endsWith(fieldList, "_nua_ecG")));
% just saving as a databank with renaming
resGEAROrigVer3 = databank.fromArray( ...
    cell2mat(struct2cell(aStructSelected))' ...
    , extractBefore(databank.fieldNames(aStructSelected), "_nua_ecG") ...
    , qq(1) ...
);

%% plotting results based on various GEAR setups
allStruct.resMMB = resMMB;
allStruct.resGEAROrigVer2 = resGEAROrigVer2;
allStruct.resGEAROrigVer3 = resGEAROrigVer3;

varStruct.resMMB = ["interest", "inflation", "inflationq", "outputgap", "output"];
varStruct.resGEAROrigVer2 = ["i_EMU_obs", "pi_a_obs", "pi_a_obs", "dgdp_a_t", "dgdp_a_t"];
varStruct.resGEAROrigVer3 = ["interest", "inflation", "inflationq", "outputgap", "output"];

setupsToPlot = string(reshape(fieldnames(allStruct), 1, []));
plotFiscalGEARWithDiffSetups(allStruct, setupsToPlot,  ["MMB setup", "GEAR baseline (one-ctry shock)", "GEAR mmb"], varStruct, projectPath, subProjectPath);

%% function for plotting
function plotFiscalGEARWithDiffSetups(allStruct, setupList, setupLegendList, varStruct, projectPath, subProjectPath)

    % Please specify the date range of the series
    dateRange = qq(1,1): qq(5,4);
    
    % Plotting
    figure
    
    % Defining the shape of the figure
    tiledlayout_width = 3; %Specify the # of columns desired
    tiledlayout_height = 2;
    
    t = tiledlayout(tiledlayout_height, tiledlayout_width, 'TileSpacing', 'compact','Padding','compact');
    
    h = gcf;
    
    % replication of light gray colour for all non-GEAR models
    cmap = subroutines.linspecer(numel(setupList));
    % based on the following palette 
    % https://www.simplifiedsciencepublishing.com/resources/best-color-palettes-for-scientific-figures-and-data-visualizations
    % #c1272d - Dark Red
    % #0000a7 - Indigo
    % #eecc16 - Yellow
    % #008176 - Teal
    % #b3b3b3 - Light Gray
    
    set(h, 'Units','centimeters', 'Position',[0 0 21-2 8])
    set(h,'defaulttextinterpreter','latex');
    
    for mmbVar = varStruct.("resMMB") %for each panel
        nexttile;
        grid on
        hold on 
        
        title(mmbVar ...
            ,'Fontsize', 8 ...
            ,'Fontweight', 'normal'...
        );
            
        for aSetup = setupList

            % specifying a marker just for MMB line
            if contains(aSetup, "MMB")
                aMarkerStyle = "o";
            else
                aMarkerStyle = "none";
            end

            % re-scaling original GEAR set-up, which does not have %
            if strcmp(aSetup, "resGEAROrigVer2")
                aLineStyle = ':';            
            elseif strcmp(aSetup, "resGEAROrigVer3")
                aLineStyle = '--';            
            else
                aLineStyle = '-';            
            end

            % re-scaling original GEAR set-up, which does not have %
            if strcmp(aSetup, "resGEAROrigVer2")
                scaleFactor = 100;            
            else
                scaleFactor = 1;            
            end
            
            pp.(aSetup) = plot(...
                scaleFactor*allStruct.(aSetup).(varStruct.(aSetup)(mmbVar == varStruct.("resMMB")))(dateRange) ...
                , 'Color', [cmap(aSetup==setupList, :)] ...
                , 'LineWidth', 2 ...
                , 'LineStyle', aLineStyle ...
                , 'Marker', aMarkerStyle ...
                , 'MarkerSize', 5 ...
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
        struct2array(pp) ...
        , setupLegendList ...
        , 'Orientation', 'horizontal' ...
        , 'Color', [1 1 1] ...
        , 'Fontsize', 8 ...
        , 'Interpreter', 'latex' ...
    );
    leg.Layout.Tile = 'north';
        
    % Save graph
    fileName = fullfile(projectPath, subProjectPath, "docs/figures", sprintf('FiscalGEARWithDiffSetups'));
    exportgraphics(t, sprintf('%s.png',fileName),'BackgroundColor','none');

end

%% Pre-amble
clear all; close all; clc
[projectPath, subProjectPath, projectPathFiMod, projectPathGEAR] = init();

%%
mmb('config_2g.json','var');

%% values simulated with simult_ Dynare function
% the major advantage of this approach is that one can
% explicitely see both ss values and shock-simulated values

% creating shocks
ex_ = databank.fromArray( ...
    zeros(20, length(M_.exo_names)) ...
    , M_.exo_names ...
    , qq(1, 1) ...
);
ex_.interest_(qq(1, 1)) = 1;

% stochastic simulation
y_ = simult_( ...
    M_ ...
    , options_ ...
    , oo_.steady_state ...
    , oo_.dr ...
    , databank.toArray(ex_) ...
    , 1 ...
);

% stochastic simulation, SS and deviations as databanks
aSeriesY_ = databank.fromArray( ...
    y_' ...
    , M_.endo_names ...
    , qq(1, 1)-1: qq(5, 4) ...
);
aSeriesSS = databank.fromArray( ...
    repmat(oo_.steady_state', 21, 1) ...
    , M_.endo_names ...
    , qq(1, 1)-1: qq(5, 4) ...
);
resDynareSimult_ = dbfun(@(x, y) x - y, aSeriesY_, aSeriesSS);

%% values simulated with Dynare irf function
SS(M_.exo_names_orig_ord,M_.exo_names_orig_ord)=M_.Sigma_e+1e-14*eye(M_.exo_nbr);
cs = eye(size(SS,1));
irf_ = irf( ...
    M_ ...
    , options_ ...
    , oo_.dr ...
    , cs(M_.exo_names_orig_ord, strcmp(M_.exo_names, 'interest_')) ...
    , options_.irf ...
    , options_.drop ...
    , options_.replic ...
    , options_.order ...
);

% deviations as databanks
resDynareIrf_ = databank.fromArray( ...
    irf_' ...
    , M_.endo_names ...
    , qq(1, 1): qq(5, 4) ...
);

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
for aSer = string(reshape(fieldnames(val.data.IRF.interest_), 1, []))
    resMMB.(aSer) = Series(qq(0, 4), val.data.IRF.interest_.(aSer));
end

%% values coming from GEAR project
% //TODO: change to GEAR from the FiMod placeholder
matFilePath = fullfile(projectPathFiMod, "FiMod/Output/FiMod_results.mat");
aDataGEAR = load(matFilePath);

resGEAROrig = databank.fromArray( ...
    cell2mat(struct2cell(aDataGEAR.oo_.irfs))' ...
    , extractBefore(databank.fieldNames(aDataGEAR.oo_.irfs), "_epsii") ...
    , qq(1) ...
);

%% plotting results based on various GEAR setups
allStruct.resDynareSimult_ = resDynareSimult_;
allStruct.resDynareIrf_ = resDynareIrf_;
allStruct.resMMB = resMMB;
allStruct.resGEAROrig = resGEAROrig;

varStruct.resDynareSimult_ = ["interest", "inflation", "inflationq", "outputgap", "output"];
varStruct.resDynareIrf_ = ["interest", "inflation", "inflationq", "outputgap", "output"];
varStruct.resMMB = ["interest", "inflation", "inflationq", "outputgap", "output"];
varStruct.resGEAROrig = ["interestEA", "inflationEA", "inflationqEA", "outputEA", "outputEA"];

setupsToPlot = string(reshape(fieldnames(allStruct), 1, []));
plotGEARWithDiffSetups(allStruct, setupsToPlot(end-1: end),  ["MMB setup", "GEAR original setup"], varStruct, projectPath, subProjectPath, "short");
plotGEARWithDiffSetups(allStruct, setupsToPlot, setupsToPlot, varStruct, projectPath, subProjectPath, "long");


%% function for plotting
function plotGEARWithDiffSetups(allStruct, setupList, setupLegendList, varStruct, projectPath, subProjectPath, plotVersion)

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
    cmap = subroutines.linspecer(4);
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
            
            pp.(aSetup) = plot(...
                allStruct.(aSetup).(varStruct.(aSetup)(mmbVar == varStruct.("resMMB")))(dateRange) ...
                , 'Color', [cmap(aSetup==setupList, :)] ...
                , 'LineWidth', 2 ...
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
    fileName = fullfile(projectPath, subProjectPath, "docs/figures", sprintf('GEARWithDiffSetups_%s', plotVersion));
    exportgraphics(t, sprintf('%s.png',fileName),'BackgroundColor','none');

end

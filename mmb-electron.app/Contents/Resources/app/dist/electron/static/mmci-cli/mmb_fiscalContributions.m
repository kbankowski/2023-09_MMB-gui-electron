%% Pre-amble
clear all; close all; clc
[projectPath, subProjectPath, projectPathFiMod, projectPathGEAR] = init();

%% reading in models in Dynare
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

%% calculating the contributions
cd(fullfile(projectPath, subProjectPath, "work", "DEREA_GEAR16"));

aItemList = ["output", "inflation", "consumption"];

allItemList = aItemList(1);
for aItem = aItemList
    [ ...
        contributionSeries.total.(aItem) ...
        , contributionSeries.contrib.(aItem) ...
        , contributionSeries.lhs.(aItem) ...
        ] = subroutines.createContributions( ...
            char(aItem) ...
            , subroutines.Series2Dseries(aSeriesY_) ...
            , subroutines.Series2Dseries(aSeriesSS) ...
        );
    allItemList = [allItemList, contributionSeries.contrib.(aItem).Comment];
end

meta.allItemList = unique(allItemList);

colorTable = table( ...
    'Size',[numel(unique(allItemList)), 1] ...
    , 'VariableTypes', {'cell'} ...
    , 'VariableNames',{'colorIndex'} ...
    , 'RowNames',unique(allItemList) ...
    );
colormapSaved = subroutines.linspecer(numel(unique(allItemList)));
for aItemIndex = 1:numel(unique(allItemList))
    colorTable{aItemIndex, 1} = {colormapSaved(aItemIndex, :)};
end
contributionSeries.colorTable = colorTable;

%% investigating interest rate reaction upon the request from Sandra
load(sprintf('%s/databases/%s/OutDb_BASE_WGEMGovInv_ShocksTemp_MpExo.mat', project_path, ProjectName), 'CalcsDbRawGovDebtExo');
contributionSeries = plotContributions(project_path, "U2", ["STN", "STN_SHADOW", "G_A4_HH_COD"], CalcsDbRawGovDebtExo, ProjectName);
plotting.WPfiscal.panelContributionsWGEM(project_path, contributionSeries, ProjectName, "WGEMreport", "inflInvestigWGEMstn");

%% local functions
function [contributionSeries, meta] = plotContributions(project_path, aCountry, aVarList, CalcsDb, ProjectName)

    aItemList = textual.xlist("_", aCountry, aVarList);
    
    cd(strcat(project_path, "/modFiles/", ProjectName))
    try % To avoid json issue (here we absolutely need the json option)
        dynare('Parsed_EA_LongrunExclude.mod', 'nopreprocessoroutput');
    catch
        dynare('Parsed_EA_LongrunExclude.mod', 'nopreprocessoroutput');
    end

    % Why the effect of gov. purchases is so different across countries
    irfDseries = utils.Series2Dseries(CalcsDb.GovInv.irf_sim);
    baselineDseries = utils.Series2Dseries(CalcsDb.baseline);
    
    % we start the list with the variable that we try to decompose
    allItemList = aItemList(1);
    for aItem = aItemList
        [ ...
            contributionSeries.total.(aItem) ...
            , contributionSeries.contrib.(aItem) ...
            , contributionSeries.lhs.(aItem) ...
            ] = subroutines.createContributions(char(aItem), irfDseries, baselineDseries);
        allItemList = [allItemList, contributionSeries.contrib.(aItem).Comment];
    end
    
    meta.allItemList = unique(allItemList);

    
    colorTable = table( ...
        'Size',[numel(unique(allItemList)), 1] ...
        , 'VariableTypes', {'cell'} ...
        , 'VariableNames',{'colorIndex'} ...
        , 'RowNames',unique(allItemList) ...
        );
    colormapSaved = plotting.linspecer(numel(unique(allItemList)));
    for aItemIndex = 1:numel(unique(allItemList))
        colorTable{aItemIndex, 1} = {colormapSaved(aItemIndex, :)};
    end
    contributionSeries.colorTable = colorTable;
end
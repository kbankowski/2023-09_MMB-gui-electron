%% PREAMBLE
% clearing the workspace
clear all; close all; clc;
% Executing call_paths not tracked by GIT
addpath('../../subroutines')
call_paths;
addpath(genpath(project_path));
% Set up project name
ProjectName = "WPfiscal";
% Call our project environment
envi = environment.WPfiscal.setup();

% Call Dynare
addpath(dynare_5_1_official);
dynare_config
% Call Iris
addpath(iris_path_20211222);
iris.startup

%% running standard shocks for Section 2
CalcsDbRawGovDebtExo = WGEM_mf_report.runStndShocks(envi);
save(sprintf('%s/databases/%s/OutDb_BASE_WGEMstndShocks_%s_%s.mat', project_path, char(ProjectName), "ShocksSpec", "MpEndo"), 'CalcsDbRawGovDebtExo');

% plotting using the results and saving the figures in CSV files
load(sprintf('%s/databases/%s/OutDb_BASE_WGEMstndShocks_%s_%s.mat', project_path, char(ProjectName), "ShocksSpec", "MpEndo"), 'CalcsDbRawGovDebtExo');
plotting.WPfiscal.FSimulDeviationsReport(envi, CalcsDbRawGovDebtExo, ProjectName, "qrt");
plotting.WPfiscal.FSimulDeviationsReport(envi, CalcsDbRawGovDebtExo, ProjectName, "ann");

%% running gov investment shocks for Section 3

% temporary shock
WGEM_mf_report.runGovInvShocks(envi, "ShocksTemp", "MpEndo");
% temporary shock with MP exogenous for 8 quarters
WGEM_mf_report.runGovInvShocks(envi, "ShocksTemp", "MpExo");
% permanent shock
WGEM_mf_report.runGovInvShocks(envi, "ShocksPerm", "MpEndo");

% loading the results
load(sprintf('%s/databases/%s/OutDb_BASE_WGEMGovInv_ShocksTemp_MpEndo.mat', project_path, ProjectName), 'CalcsDbRawGovDebtExo');
PlotDb.Temp_MpEndo = CalcsDbRawGovDebtExo;
load(sprintf('%s/databases/%s/OutDb_BASE_WGEMGovInv_ShocksTemp_MpExo.mat', project_path, ProjectName), 'CalcsDbRawGovDebtExo');
PlotDb.Temp_MpExo = CalcsDbRawGovDebtExo;
load(sprintf('%s/databases/%s/OutDb_BASE_WGEMGovInv_ShocksPerm_MpEndo.mat', project_path, ProjectName), 'CalcsDbRawGovDebtExo');
PlotDb.Perm_MpEndo = CalcsDbRawGovDebtExo;

% figure
plotting.WPfiscal.IRFs_shock_gin_WGEM(envi, "GovInv", PlotDb, ProjectName, "WGEMreport");

% saving results in csv files
for aSim = ["Temp_MpEndo", "Temp_MpExo", "Perm_MpEndo"]
    databank.toCSV(...
        databank.apply(@(x) x{qq(1, 1): qq(2015, 4)}, databank.redate(databank.copy(PlotDb.(aSim).GovInv.irf_dev, "SourceNames", envi.Meta.Lists.Variables.PlottingWGEM.irf_shocks(1:end-1)), qq(2822, 2), qq(1))) ...
        , sprintf('%s/docu/%s/%s/csvFiles/%s.csv', project_path, ProjectName, "WGEMreport", aSim) ...
        , Inf ...
    );
end

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
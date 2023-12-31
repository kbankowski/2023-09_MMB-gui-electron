% initiating the project
clear all; close all; clc
[projectPath, subProjectPath, projectPathFimod] = init();

% running FiMod under different setups to make sure resutls are the same
mmb_FiModWithDiffSetups

% running FiMod under different setups to make sure resutls are the same
mmb_GEARWithDiffSetups

% running FiMod & GEAR under various monetary policy rules and constructing
% a table
mmb_FiModWithDiffRules
mmb_GEARWithDiffRules
mmb_DiffRulesCoeffTable

% running various MMB models with SW rule
% so that the results of FiMod could be put into 
% perspective
mmb_SWruleWithDiffModels

% checking common rules
mmb_checkCommonRules
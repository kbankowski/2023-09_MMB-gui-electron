% initiating the project
clear all; close all; clc
[projectPath, subProjectPath, projectPathFimod] = init();

% running FiMod under various monetary policy rules
mmb_FiModWithDiffRules

% running various MMB models with SW rule
% so that the results of FiMod could be put into 
% perspective
mmb_SWruleWithDiffModels
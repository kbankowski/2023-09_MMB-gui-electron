%% Pre-amble
clear all
close all
clc
[projectPath, subProjectPath, projectPathFimod, projectPathGEAR] = init();

%% Read to rules to see their values
fileID = fopen('docs/ruleMPvarNames.txt');
% Read the data into a cell array
data = textscan(fileID, '%s', 'Delimiter', '\n', 'Whitespace', '');
coffNames = replace(string(data{1}), " ", "_");
% Close the file
fclose(fileID);

% initiating the table
ruleListForTable = ["CEE", "CMR", "Coenen", "GR", "LWW", "OW08", "OW13", "SW", "Taylor", "FiMod", "GEAR"];
coeffTable = table( ...
    'Size', [length(coffNames) length(ruleListForTable)] ...
    , 'VariableTypes', repmat("double", 1, length(ruleListForTable)) ...
    , 'VariableNames', ruleListForTable ...
    , 'RowNames', coffNames ...
);

% reading the parameters of standard rules from json files
for aRule = string(ruleListForTable(1:end-2))
    fname = fullfile('rules', aRule, sprintf('%s.json', aRule)); 
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    val = jsondecode(str);
    rulesCoeff.(aRule) = vertcat(cellfun(@(x) eval(x), val.coefficients));
    coeffTable{:, aRule} = rulesCoeff.(aRule);
end

% reading the model specific rule - FiMod
fname = fullfile('models', 'ESREA_FIMOD12', sprintf('%s.json', 'ESREA_FIMOD12')); 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val = jsondecode(str);
rulesCoeff.("FiMod") = vertcat(cellfun(@(x) eval(x), val.msr));

% reading the model specific rule - GEAR
fname = fullfile('models', 'DEREA_GEAR16', sprintf('%s.json', 'DEREA_GEAR16')); 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val = jsondecode(str);
rulesCoeff.("GEAR") = vertcat(cellfun(@(x) eval(x), val.msr));

% storing the numbers in the table
for aRule = ruleListForTable
    coeffTable{:, aRule} = rulesCoeff.(aRule);
end

% saving the latex table out of the Matlab table
texFileName = char(fullfile(projectPath, subProjectPath, "docs/tex", "rulesParameters.tex"));
subroutines.table2latex(coeffTable, texFileName);
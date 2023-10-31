fname = 'mmb-electron.app/Contents/Resources/app/dist/electron/static/mmci-cli/models/EA_QUEST3/EA_QUEST3.json'; 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val = jsondecode(str);


%% Create a list of all models
% Define the folder you want to look in
folder = '/Users/kk/Documents/0000-00_work/2023-09_MMB-gui-electron/mmb-electron.app/Contents/Resources/app/dist/electron/static/mmci-cli/models';
% Get a list of all files and folders in this folder
files = dir(folder);
% Filter out all the files (keep only directories)
directories = files([files.isdir]);
% Remove '.' and '..' from the list
directories = directories(~ismember({directories.name}, {'.', '..'}));
% Optionally, extract a list of directory names
modelList = string({directories.name});

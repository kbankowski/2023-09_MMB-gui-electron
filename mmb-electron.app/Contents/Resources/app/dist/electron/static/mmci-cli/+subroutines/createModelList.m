function modelList = createModelList(projectPath, subProjectPath)
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
end
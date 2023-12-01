function [projectPath, subProjectPath, projectPathFimod] = init()

    restoredefaultpath;

    iris_path = "/Users/kk/Documents/0000-00_work/2021-03_iris/iris_live";

    % Loading Iris
    addpath(iris_path);
    iris.startup

    % Loading Dynare
    addpath('/Applications/Dynare/5.5-arm64/matlab');
    dynare_config()

    % Adding paths
    projectPath = '/Users/kk/Documents/0000-00_work/2023-09_MMB-gui-electron';
    addpath(genpath(projectPath));
    subProjectPath = 'mmb-electron.app/Contents/Resources/app/dist/electron/static/mmci-cli';

    projectPathFimod = '/Users/kk/Documents/0000-00_work/2023-08_fimod';    
end


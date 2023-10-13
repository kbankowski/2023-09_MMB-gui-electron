projectPath = '/Users/kk/Documents/0000-00_work/2023-09_MMB-gui-electron';
subProjectPath = 'mmb-electron.app/Contents/Resources/app/dist/electron/static/mmci-cli/out';
mmb('config_2.json','var');

%% values simulated with simult_ Dynare function
% the major advantage of this approach is that one can
% explicitely see both ss values and shock-simulated values
ex_ = databank.fromArray( ...
    zeros(20, length(M_.exo_names)) ...
    , M_.exo_names ...
    , qq(1, 1) ...
);
ex_.interest_(qq(1, 1)) = 1;

y_ = simult_( ...
    M_ ...
    , options_ ...
    , oo_.steady_state ...
    , oo_.dr ...
    , databank.toArray(ex_) ...
    , 1 ...
);

resSimValue2 = databank.fromArray( ...
    y_' ...
    , M_.endo_names ...
    , qq(1, 1)-1: qq(5, 4) ...
);

%% values simulated with MMB

%read the two json files and then plot
%read

cd out

fname = 'US_SW07-Model.output.json'; 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val3 = jsondecode(str);

cd ..

for aSer = string(reshape(fieldnames(val3.data.IRF.interest_), 1, []))
    mmbSim.(aSer) = Series(qq(0, 4), val3.data.IRF.interest_.(aSer));
end

%% comparing the results
[resSimValue2.interest, mmbSim.interest]
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

aSeriesSimult = databank.fromArray( ...
    y_' ...
    , M_.endo_names ...
    , qq(1, 1)-1: qq(5, 4) ...
) ...
- databank.fromArray( ...
    repmat(oo_.steady_state', 21, 1) ...
    , M_.endo_names ...
    , qq(1, 1)-1: qq(5, 4) ...
);

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

aSeriesIrf = databank.fromArray( ...
    irf_' ...
    , M_.endo_names ...
    , qq(1, 1): qq(5, 4) ...
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
[aSeriesSimult.interest, aSeriesIrf.interest, mmbSim.interest]
[aSeriesSimult.inflation, aSeriesIrf.inflation, mmbSim.inflation]
[aSeriesSimult.outputgap, aSeriesIrf.outputgap, mmbSim.outputgap]
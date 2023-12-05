[aSeriesY_.interest, aSeriesY_.interest{-1}, aSeriesY_.inflationq, aSeriesY_.outputgap]

M_.param_names
M_.params

paramList = string(reshape(M_.param_names, 1, []));

for aPara = paramList

    evalc([char(aPara) ' = M_.params(aPara == paramList)'])

end

400*(pop_a/(pop_b+pop_a)*log(aSeriesY_.pi_a_t/pi_ts)+(pop_b/(pop_b+pop_a)*log(aSeriesY_.pi_b_t/pi_ts)))

%% just saving the irf result in the debugging

resultsSIMULT = load('resultsSIMULT.mat');
resultsIRF = load('resultsIRF.mat');

[resultsSIMULT.out2.inflationq, resultsIRF.out2.inflationq]

openvar('resultsSIMULT.out1')
openvar('resultsIRF.out1')

openvar('resultsSIMULT.arg1')
openvar('resultsIRF.arg1')

openvar('resultsSIMULT.arg2')
openvar('resultsIRF.arg2')

openvar('resultsSIMULT.arg3')
openvar('resultsIRF.arg3')

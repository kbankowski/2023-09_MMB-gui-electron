clear all
close all
clc
clear all

%% Figure 3
projectPath = '/Users/kk/Documents/0000-00_work/2023-09_MMB-gui-electron';
subProjectPath = 'mmb-electron.app/Contents/Resources/app/dist/electron/static/mmci-cli/out';
mmb('config_2.json','var');

cd out

%read the two json files and then plot
%read
fname = 'US_SW07-Model.output.json'; 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val3 = jsondecode(str);

fname = 'US_SW07-User.output.json'; 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val2 = jsondecode(str);

fname = 'US_SW07-Taylor.output.json'; 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val1 = jsondecode(str);

cd ..

%get the variables from it
int1=val1.data.IRF.interest_.interest;
ygap1=val1.data.IRF.interest_.outputgap;
int2=val2.data.IRF.interest_.interest;
ygap2=val2.data.IRF.interest_.outputgap;
int3=val3.data.IRF.interest_.interest;
ygap3=val3.data.IRF.interest_.outputgap;

%plot 
time=0:20;
x_label_name="Quarters";
y_label_int="Percentage Point Deviation";
y_label_ygap="% Deviation";
fontSize_axis=18;
fontSize_title=20;
fontSize_numbers=16;
fontSize_legend=16;
linewidth_curves=2;
linewidth_zero=1;
title_int="Interest";
title_ygap="Output Gap";

fig = figure(1);
plot(time, int1,'-b', 'Linewidth', linewidth_curves),hold on
plot(time, int2,'-r', 'Linewidth', linewidth_curves),hold on
plot(time, int3,'--g', 'Linewidth', linewidth_curves),hold on
plot(time,0.*int1,'-k','Linewidth', linewidth_zero),hold on
legend({'Rule: Taylor', 'Rule: User', 'Rule: Model'},'FontSize',fontSize_legend)
hold off
ax = gca;
ax.FontSize = fontSize_numbers;
title(title_int,'FontSize', fontSize_title)
xlabel(x_label_name,'FontSize', fontSize_axis)
ylabel(y_label_int,'FontSize', fontSize_axis)
fileName = fullfile(projectPath, subProjectPath, "mmb_2_interest");
exportgraphics(fig, sprintf('%s.png',fileName),'BackgroundColor','none');


fig = figure(2);
plot(time, ygap1,'-b', 'Linewidth', linewidth_curves),hold on
plot(time, ygap2,'-r', 'Linewidth', linewidth_curves),hold on
plot(time, ygap3,'--g', 'Linewidth', linewidth_curves),hold on
plot(time,0.*int1,'-k','Linewidth', linewidth_zero),hold on
legend({'Rule: Taylor', 'Rule: User', 'Rule: Model'},'FontSize',fontSize_legend)
hold off
ax = gca;
ax.FontSize = fontSize_numbers;
title(title_ygap,'FontSize', fontSize_title)
xlabel(x_label_name,'FontSize', fontSize_axis)
ylabel(y_label_ygap,'FontSize', fontSize_axis)
fileName = fullfile(projectPath, subProjectPath, "mmb_2_outputGap");
exportgraphics(fig, sprintf('%s.png',fileName),'BackgroundColor','none');

%ylim(y_lim_value)

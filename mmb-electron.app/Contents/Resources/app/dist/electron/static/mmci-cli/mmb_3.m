%% Figure 4
projectPath = '/Users/kk/Documents/0000-00_work/2023-09_MMB-gui-electron';
subProjectPath = 'mmb-electron.app/Contents/Resources/app/dist/electron/static/mmci-cli/out';
mmb('config_3.json','var');

cd out

%read the two json files and then plot
%read
fname = 'G7_TAY93-CEE.output.json'; 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val1 = jsondecode(str);

fname = 'US_ACELm-CEE.output.json'; 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val2 = jsondecode(str);

fname = 'US_SW07-CEE.output.json'; 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val3 = jsondecode(str);

cd ..

%get the variables from it
int1=val1.data.IRF.interest_.interest;
y1=val1.data.IRF.interest_.output;
int2=val2.data.IRF.interest_.interest;
y2=val2.data.IRF.interest_.output;
int3=val3.data.IRF.interest_.interest;
y3=val3.data.IRF.interest_.output;

%plot 
time=0:20;
x_label_name="Quarters";
y_label_int="Percentage Point Deviation";
y_label_y="% Deviation";
title_int="Interest";
title_y="Output";

fig = figure(1);
plot(time, int1,'-b', 'Linewidth', linewidth_curves),hold on
plot(time, int2,'-r', 'Linewidth', linewidth_curves),hold on
plot(time, int3,'-g', 'Linewidth', linewidth_curves),hold on
plot(time,0.*int1,'-k','Linewidth', linewidth_zero),hold on
legend('G7\_TAY93','US\_ACELm','US\_SW07','','FontSize',fontSize_legend)
hold off
ax = gca;
ax.FontSize = fontSize_numbers;
title(title_int,'FontSize', fontSize_title)
xlabel(x_label_name,'FontSize', fontSize_axis)
ylabel(y_label_int,'FontSize', fontSize_axis)
fileName = fullfile(projectPath, subProjectPath, "mmb_3_interest");
exportgraphics(fig, sprintf('%s.png',fileName),'BackgroundColor','none');

%ylim([-0.25 1.25])
fig = figure(2);
plot(time, y1,'-b', 'Linewidth', linewidth_curves),hold on
plot(time, y2,'-r', 'Linewidth', linewidth_curves),hold on
plot(time, y3,'-g', 'Linewidth', linewidth_curves),hold on
plot(time,0.*int1,'-k','Linewidth', linewidth_zero),hold on
legend('G7\_TAY93','US\_ACELm','US\_SW07','','FontSize',fontSize_legend)
hold off
ax = gca;
ax.FontSize = fontSize_numbers;
title(title_y,'FontSize', fontSize_title)
xlabel(x_label_name,'FontSize', fontSize_axis)
ylabel(y_label_y,'FontSize', fontSize_axis)
fileName = fullfile(projectPath, subProjectPath, "mmb_3_outputGap");
exportgraphics(fig, sprintf('%s.png',fileName),'BackgroundColor','none');
%ylim([-0.4 0.1])
%ylim(y_lim_value)
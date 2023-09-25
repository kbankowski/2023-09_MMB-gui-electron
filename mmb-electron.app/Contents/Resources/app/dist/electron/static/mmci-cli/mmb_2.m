clear all
close all
clc
clear all

%% Figure 3
mmb('config_2.json','var');

cd out

%read the two json files and then plot
%read
fname = 'G7_TAY93-User.output.json'; 
fid = fopen(fname); 
raw = fread(fid,inf); 
str = char(raw'); 
fclose(fid); 
val2 = jsondecode(str);

fname = 'G7_TAY93-Taylor.output.json'; 
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

figure(1);
plot(time, int1,'-b', 'Linewidth', linewidth_curves),hold on
plot(time, int2,'-r', 'Linewidth', linewidth_curves),hold on
plot(time,0.*int1,'-k','Linewidth', linewidth_zero),hold on
%legend('G7\_TAY93, rule 1','G7\_TAY93, rule 2','')
hold off
ax = gca;
ax.FontSize = fontSize_numbers;
title(title_int,'FontSize', fontSize_title)
xlabel(x_label_name,'FontSize', fontSize_axis)
ylabel(y_label_int,'FontSize', fontSize_axis)
figure(2);
plot(time, ygap1,'-b', 'Linewidth', linewidth_curves),hold on
plot(time, ygap2,'-r', 'Linewidth', linewidth_curves),hold on
plot(time,0.*int1,'-k','Linewidth', linewidth_zero),hold on
legend('Rule (1)','Rule (2)','','FontSize',fontSize_legend)
hold off
ax = gca;
ax.FontSize = fontSize_numbers;
title(title_ygap,'FontSize', fontSize_title)
xlabel(x_label_name,'FontSize', fontSize_axis)
ylabel(y_label_ygap,'FontSize', fontSize_axis)
ylim([-0.2 0.02])
%ylim(y_lim_value)
clear all
load('results_june14.mat')

% Get values we need to plot
vars = {'pre1' 'pre2' 'pre3' 'pre4' 'pre5' 'post1' 'post2' 'post3' 'post4' 'post5' 'post6' 'post7' 'post8' 'post9' 'post10'};
RLS_w_clm = table2array(w_clm(strcmp(w_clm.Diagnosis,'RLS'),vars));
ctrl_w_clm = table2array(w_clm(strcmp(w_clm.Diagnosis,'Control'),vars));
RLS_wo_clm = table2array(wo_clm(strcmp(wo_clm.Diagnosis,'RLS'),vars));
ctrl_wo_clm = table2array(wo_clm(strcmp(wo_clm.Diagnosis,'Control'),vars));

% Calculate averages and standard errors
mean_RLS_w_CLM = mean(RLS_w_clm, 1);
mean_ctrl_w_CLM = mean(ctrl_w_clm, 1);
mean_RLS_wo_CLM = mean(RLS_wo_clm, 1);
mean_ctrl_wo_CLM = mean(ctrl_wo_clm, 1);
stderror_RLS_w_CLM = std(RLS_w_clm) / sqrt(length(RLS_w_clm));
stderror_ctrl_w_CLM = std(ctrl_w_clm) / sqrt(length(ctrl_w_clm));
stderror_RLS_wo_CLM = std(RLS_wo_clm) / sqrt(length(RLS_wo_clm));
stderror_ctrl_wo_CLM = std(ctrl_wo_clm) / sqrt(length(ctrl_wo_clm));

% Plot everything
close all
figure
hold on
ylim([0.95 1.35])
title('1-second window')
errorbar(mean_RLS_w_CLM,stderror_RLS_w_CLM,'b')
errorbar(mean_RLS_wo_CLM,stderror_RLS_wo_CLM,'g')
errorbar(mean_ctrl_w_CLM,stderror_ctrl_w_CLM,'r')
errorbar(mean_ctrl_wo_CLM,stderror_ctrl_wo_CLM,'o')
legend('RLS arousals with CLM', 'RLS arousals without CLM', ...
    'Control arousals with CLM', 'Control arousals without CLM', ...
    'location', 'northwest')

% Get values we need to plot
vars = {'pre1' 'pre2' 'pre3' 'pre4' 'pre5' 'post1' 'post2' 'post3' 'post4' 'post5' 'post6' 'post7' 'post8' 'post9' 'post10'};
RLS_tenSec_w_clm = table2array(tenSec_w_clm(strcmp(tenSec_w_clm.Diagnosis,'RLS'),vars));
ctrl_tenSec_w_clm = table2array(tenSec_w_clm(strcmp(tenSec_w_clm.Diagnosis,'Control'),vars));
RLS_tenSec_wo_clm = table2array(tenSec_wo_clm(strcmp(tenSec_wo_clm.Diagnosis,'RLS'),vars));
ctrl_tenSec_wo_clm = table2array(tenSec_wo_clm(strcmp(tenSec_wo_clm.Diagnosis,'Control'),vars));

% Calculate averages and standard errors
mean_RLS_tenSec_w_clm = mean(RLS_tenSec_w_clm, 1);
mean_ctrl_tenSec_w_clm = mean(ctrl_tenSec_w_clm, 1);
mean_RLS_tenSec_wo_clm = mean(RLS_tenSec_wo_clm, 1);
mean_ctrl_tenSec_wo_clm = mean(ctrl_tenSec_wo_clm, 1);
stderror_RLS_tenSec_w_clm = std(RLS_tenSec_w_clm) / sqrt(length(RLS_tenSec_w_clm));
stderror_ctrl_tenSec_w_clm = std(ctrl_tenSec_w_clm) / sqrt(length(ctrl_tenSec_w_clm));
stderror_RLS_tenSec_wo_clm = std(RLS_tenSec_wo_clm) / sqrt(length(RLS_tenSec_wo_clm));
stderror_ctrl_tenSec_wo_clm = std(ctrl_tenSec_wo_clm) / sqrt(length(ctrl_tenSec_wo_clm));

% Plot everything
figure
hold on
ylim([0.95 1.35])
title('10-second window')
errorbar(mean_RLS_tenSec_w_clm,stderror_RLS_tenSec_w_clm,'b')
errorbar(mean_RLS_tenSec_wo_clm,stderror_RLS_tenSec_wo_clm,'g')
errorbar(mean_ctrl_tenSec_w_clm,stderror_ctrl_tenSec_w_clm,'r')
errorbar(mean_ctrl_tenSec_wo_clm,stderror_ctrl_tenSec_wo_clm,'o')
legend('RLS arousals with CLM', 'RLS arousals without CLM', ...
    'Control arousals with CLM', 'Control arousals without CLM', ...
    'location', 'northwest')

% Get values we need to plot
vars = {'pre1' 'pre2' 'pre3' 'pre4' 'pre5' 'post1' 'post2' 'post3' 'post4' 'post5' 'post6' 'post7' 'post8' 'post9' 'post10'};
RLS_thirtySec_w_clm = table2array(thirtySec_w_clm(strcmp(thirtySec_w_clm.Diagnosis,'RLS'),vars));
ctrl_thirtySec_w_clm = table2array(thirtySec_w_clm(strcmp(thirtySec_w_clm.Diagnosis,'Control'),vars));
RLS_thirtySec_wo_clm = table2array(thirtySec_wo_clm(strcmp(thirtySec_wo_clm.Diagnosis,'RLS'),vars));
ctrl_thirtySec_wo_clm = table2array(thirtySec_wo_clm(strcmp(thirtySec_wo_clm.Diagnosis,'Control'),vars));

% Calculate averages and standard errors
mean_RLS_thirtySec_w_clm = mean(RLS_thirtySec_w_clm, 1);
mean_ctrl_thirtySec_w_clm = mean(ctrl_thirtySec_w_clm, 1);
mean_RLS_thirtySec_wo_clm = mean(RLS_thirtySec_wo_clm, 1);
mean_ctrl_thirtySec_wo_clm = mean(ctrl_thirtySec_wo_clm, 1);
stderror_RLS_thirtySec_w_clm = std(RLS_thirtySec_w_clm) / sqrt(length(RLS_thirtySec_w_clm));
stderror_ctrl_thirtySec_w_clm = std(ctrl_thirtySec_w_clm) / sqrt(length(ctrl_thirtySec_w_clm));
stderror_RLS_thirtySec_wo_clm = std(RLS_thirtySec_wo_clm) / sqrt(length(RLS_thirtySec_wo_clm));
stderror_ctrl_thirtySec_wo_clm = std(ctrl_thirtySec_wo_clm) / sqrt(length(ctrl_thirtySec_wo_clm));

% Plot everything
figure
hold on
title('30-second window')
ylim([0.95 1.35])
errorbar(mean_RLS_thirtySec_w_clm,stderror_RLS_thirtySec_w_clm,'b')
errorbar(mean_RLS_thirtySec_wo_clm,stderror_RLS_thirtySec_wo_clm,'g')
errorbar(mean_ctrl_thirtySec_w_clm,stderror_ctrl_thirtySec_w_clm,'r')
errorbar(mean_ctrl_thirtySec_wo_clm,stderror_ctrl_thirtySec_wo_clm,'o')
legend('RLS arousals with CLM', 'RLS arousals without CLM', ...
    'Control arousals with CLM', 'Control arousals without CLM', ...
    'location', 'northwest')

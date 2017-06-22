% Get values we need to plot
vars = {'pre1' 'pre2' 'pre3' 'pre4' 'pre5' 'post1' 'post2' 'post3' 'post4' 'post5' 'post6' 'post7' 'post8' 'post9' 'post10'};
RLS_w_lm = table2array(w_lm(strcmp(w_lm.Diagnosis,'RLS'),vars));
ctrl_w_lm = table2array(w_lm(strcmp(w_lm.Diagnosis,'Control'),vars));
RLS_wo_lm = table2array(wo_lm(strcmp(wo_lm.Diagnosis,'RLS'),vars));
ctrl_wo_lm = table2array(wo_lm(strcmp(wo_lm.Diagnosis,'Control'),vars));

% Calculate averages and standard errors
mean_RLS_w_lm = mean(RLS_w_lm, 1);
mean_ctrl_w_lm = mean(ctrl_w_lm, 1);
mean_RLS_wo_lm = mean(RLS_wo_lm, 1);
mean_ctrl_wo_lm = mean(ctrl_wo_lm, 1);
stderror_RLS_w_lm = std(RLS_w_lm) / sqrt(length(RLS_w_lm));
stderror_ctrl_w_lm = std(ctrl_w_lm) / sqrt(length(ctrl_w_lm));
stderror_RLS_wo_lm = std(RLS_wo_lm) / sqrt(length(RLS_wo_lm));
stderror_ctrl_wo_lm = std(ctrl_wo_lm) / sqrt(length(ctrl_wo_lm));

% Plot everything
close all
figure
hold on
ylim([0.95 1.35])
title('1-second window')
errorbar(mean_RLS_w_lm,stderror_RLS_w_lm,'b')
errorbar(mean_RLS_wo_lm,stderror_RLS_wo_lm,'g')
errorbar(mean_ctrl_w_lm,stderror_ctrl_w_lm,'r')
errorbar(mean_ctrl_wo_lm,stderror_ctrl_wo_lm,'o')
legend('RLS arousals with lm', 'RLS arousals without lm', ...
    'Control arousals with lm', 'Control arousals without lm', ...
    'location', 'northwest')

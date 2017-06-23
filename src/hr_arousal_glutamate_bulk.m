function results = hr_arousal_glutamate_bulk(lb,ub)
%% T = hr_arousal_glutamate()
% This script looks at the heart rate increases before and after arousal
% events. Right now it runs through the Glutamate study. This is a fine
% template for other hr analysis scripts, but make sure hr has already been
% calculated by python or else this will take a ridiculously long time.
% Options:
% [1] Get arousals with or without LM
% [2] Get LM with or without arousals
% [3] TBD
addpath('helper_functions');
load('names.mat'); % subjects that are used in this study

psgs = rdir('B:\Glutamate Study\**\edf_event.mat'); % path to psg

%% Just do it here...
output_names_lm_w_arous = [];
output_names_lm_wo_arous = [];
output_names_arous_w_lm = [];
output_names_arous_wo_lm = [];
output_points_lm_w_arous = [];
output_points_lm_wo_arous = [];
output_points_arous_w_lm = [];
output_points_arous_wo_lm = [];
num_lm1 = [];
num_arousals1 = [];
arousals_w_llm1 = [];
arousals_wo_llm1 = [];
num_lm2 = [];
num_arousals2 = [];
arousals_w_llm2 = [];
arousals_wo_llm2 = [];
num_lm3 = [];
num_arousals3 = [];
arousals_w_llm3 = [];
arousals_wo_llm3 = [];
num_lm4 = [];
num_arousals4 = [];
arousals_w_llm4 = [];
arousals_wo_llm4 = [];
fails = {};

for i = 1:size(psgs,1)
    %% Get subject ID
    id = split(psgs(i).folder,'\'); % hopefully slash is consistent
    id = char(id(end)); % part with subject id
    id = split(id,' ');
    id = char(id(2));
    
    %% Check if this is a subject we want
    if ~contains(hr_arousal_subs,id),continue; end
    
    %% Load psg and plm_outputs
    %  - could extract arousal so we don't have to load the whole thing
    try
        load(psgs(i).name);
        load(fullfile(psgs(i).folder,'results05-Jun-2017'));
    catch
        fprintf('Could not load data for %s\n',id);
%         fails = [fails; id];
        continue;
    end
%     CLM = plm_outputs.CLM; % includes wake and sleep for now
%     CLM = CLM(CLM(:,6) > 0,:);

    lLM = plm_outputs.lLM; % includes wake and sleep for now
    rLM = plm_outputs.rLM; % includes wake and sleep for now

    epochStage = plm_outputs.epochstage;
    
    %% Determine which arousals are associated with CLMs
    arous_vec = eventtime2points(subj_struct,'start_time','hypno_start');
    %ev_vec(:,6) = 0; % doesn't support sleep staging yet
    arous_vec(:,3) = epochStage(round(arous_vec(:,1)/30/500+.5));
    arous_vec = arous_vec(arous_vec(:,3) > 0,1:2);
    try
    bLM = getComboLM(rLM,lLM,500);
    bLM(:,3) = epochStage(round(bLM(:,1)/30/500+.5));
    bLM = bLM(bLM(:,3) > 0,1:2);
    catch
        disp('LM sleep stage error')
    end
    %% Check if we want to use arousals or LMs
    arous_assoc = associate_events(arous_vec,bLM,lb,ub,500);
    lm_assoc = associate_events(bLM,arous_vec,lb,ub,500);

    lm_w_arous = bLM(lm_assoc,:);
    lm_wo_arous = bLM(~lm_assoc,:);
    arous_w_lm = arous_vec(arous_assoc,:);
    arous_wo_lm = arous_vec(~arous_assoc,:);
    savepath = 'B:\Heart Rate Analysis\data\';
    figpath = 'B:\Heart Rate Analysis\figs\';
    
    %% Load heart rate and adjust for time relative to hypnostart
    hr = load(['B:\Heart Rate Analysis\data\hr\' id '.txt']);
    hr(:,1) = hr(:,1) - subj_struct.EDFStart2HypnoInSec;
    hr = hr(hr(:,1) > 0,:);
    
    if ~isempty(subj_struct) && ~isempty(lm_w_arous)
        hr_lm_w_arous = plot_subject_mean(hr,lm_w_arous,false);
        output_names_lm_w_arous = [output_names_lm_w_arous ; id];
        output_points_lm_w_arous = [output_points_lm_w_arous ; hr_lm_w_arous];
        num_lm1 = [num_lm1 ; size(bLM,1)];
        num_arousals1 = [num_arousals1 ; size(arous_assoc,1)];
        arousals_w_llm1 = [arousals_w_llm1 ; sum(arous_assoc)];
        arousals_wo_llm1 = [arousals_wo_llm1 ; sum(~arous_assoc)];        
%         savefig([figpath id '_lm_w_arous']); close;
        save([savepath id '_lm_w_arous'],'hr_lm_w_arous');
        clear hr_lm_w_arous lm_w_arous 
    else
        fprintf('Subject %s has empty ev_vec\n',id);
        fails = [fails; id];
    end
    if ~isempty(subj_struct) && ~isempty(lm_wo_arous)
        hr_lm_wo_arous = plot_subject_mean(hr,lm_wo_arous,false);
        output_names_lm_wo_arous = [output_names_lm_wo_arous ; id];
        output_points_lm_wo_arous = [output_points_lm_wo_arous ; hr_lm_wo_arous];
        num_lm2 = [num_lm2 ; size(bLM,1)];
        num_arousals2 = [num_arousals2 ; size(arous_assoc,1)];
        arousals_w_llm2 = [arousals_w_llm2 ; sum(arous_assoc)];
        arousals_wo_llm2 = [arousals_wo_llm2 ; sum(~arous_assoc)];        
%         savefig([figpath id '_lm_wo_arous']); close;
        save([savepath id '_lm_wo_arous'],'hr_lm_wo_arous');
        clear hr_lm_wo_arous lm_wo_arous
    else
        fprintf('Subject %s has empty ev_vec\n',id);
        fails = [fails; id];
    end
    if  ~isempty(subj_struct) && ~isempty(arous_w_lm)
        hr_arous_w_lm = plot_subject_mean(hr,arous_w_lm,false);
        output_names_arous_w_lm = [output_names_arous_w_lm ; id];
        output_points_arous_w_lm = [output_points_arous_w_lm ; hr_arous_w_lm];
        num_lm3 = [num_lm3 ; size(bLM,1)];
        num_arousals3 = [num_arousals3 ; size(arous_assoc,1)];
        arousals_w_llm3 = [arousals_w_llm3 ; sum(arous_assoc)];
        arousals_wo_llm3 = [arousals_wo_llm3 ; sum(~arous_assoc)];        
%         savefig([figpath id '_arous_w_lm']); close;
        save([savepath id '_arous_w_lm'],'hr_arous_w_lm');
        clear hr_arous_w_lm arous_w_lm
    else
        fprintf('Subject %s has empty ev_vec\n',id);
        fails = [fails; id];
    end
    if  ~isempty(subj_struct) && ~isempty(arous_wo_lm)
        hr_arous_wo_lm = plot_subject_mean(hr,arous_wo_lm,false);
        output_names_arous_wo_lm = [output_names_arous_wo_lm ; id];
        output_points_arous_wo_lm = [output_points_arous_wo_lm ; hr_arous_wo_lm];
        num_lm4 = [num_lm4 ; size(bLM,1)];
        num_arousals4 = [num_arousals4 ; size(arous_assoc,1)];
        arousals_w_llm4 = [arousals_w_llm4 ; sum(arous_assoc)];
        arousals_wo_llm4 = [arousals_wo_llm4 ; sum(~arous_assoc)];        
%         savefig([figpath id '_arous_wo_lm']); close;
        save([savepath id '_arous_wo_lm'],'hr_arous_wo_lm');
        clear hr_arous_wo_lm arous_wo_lm 
    else
        fprintf('Subject %s has empty ev_vec\n',id);
        fails = [fails; id];
    end
    clear psg subj_id bLM hr
    fprintf('Finished %d of %d records\n',i,size(psgs,1));
end

%% Assemble output tables
T1 = assemble_table(output_points_lm_w_arous, output_names_lm_w_arous, arousals_w_llm1,...
    arousals_wo_llm1, num_arousals1, num_lm1);
T1 = [T1 table(max(table2array(T1(:,7:16)),[],2),'VariableNames',{'maxChange'})...
    table(sum(table2array(T1(:,2:16)),2),'VariableNames',{'area'})];
T2 = assemble_table(output_points_lm_wo_arous, output_names_lm_wo_arous, arousals_w_llm2,...
    arousals_wo_llm2, num_arousals2, num_lm2);
T2 = [T2 table(max(table2array(T2(:,7:16)),[],2),'VariableNames',{'maxChange'})...
    table(sum(table2array(T2(:,2:16)),2),'VariableNames',{'area'})];
T3 = assemble_table(output_points_arous_w_lm, output_names_arous_w_lm, arousals_w_llm3,...
    arousals_wo_llm3, num_arousals3, num_lm3);
T3 = [T3 table(max(table2array(T3(:,7:16)),[],2),'VariableNames',{'maxChange'})...
    table(sum(table2array(T3(:,2:16)),2),'VariableNames',{'area'})];
T4 = assemble_table(output_points_arous_wo_lm, output_names_arous_wo_lm, arousals_w_llm4,...
    arousals_wo_llm4, num_arousals4, num_lm4);
T4 = [T4 table(max(table2array(T4(:,7:16)),[],2),'VariableNames',{'maxChange'})...
    table(sum(table2array(T4(:,2:16)),2),'VariableNames',{'area'})];

results = {T1 T2 T3 T4};

% f = fopen(['errors_' w a '.dat'],'w');
% for row = 1:size(fails,1)
%     fprintf(f,'%s\n',fails{row,:})
% end
end % end function

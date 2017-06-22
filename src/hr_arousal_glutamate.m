function T = hr_arousal_glutamate(withLM,option,lb,ub)
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
output_names = [];
output_points = [];
num_rlm = [];
num_llm = [];
num_arousals = [];
arousals_w_llm = [];
arousals_wo_llm = [];
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
    ev_vec = eventtime2points(subj_struct,'start_time','hypno_start');
    %ev_vec(:,6) = 0; % doesn't support sleep staging yet
    ev_vec(:,3) = epochStage(round(ev_vec(:,1)/30/500+.5));
    ev_vec = ev_vec(ev_vec(:,3) > 0,1:2);
    bLM = getComboLM(rLM,lLM);

    %% Check if we want to use arousals or LMs
    if option == 1
        assoc = associate_events(ev_vec,bLM,lb,ub,500);
        a = 'Arousal';
    elseif option == 2
        assoc = associate_events(bLM,ev_vec,lb,ub,500);
        ev_vec = bLM(:,1:2);
        a = 'LM';
    else
        disp('Invalid option.')
    end
    
    %% Check if we want arousal with or without CLM
    switch withLM
        case 1 
            ev_vec = ev_vec(assoc,:);
            savepath = 'B:\Heart Rate Analysis\data\';
            figpath = 'B:\Heart Rate Analysis\figs\';
            w = 'w';
        case 0
            ev_vec = ev_vec(~assoc,:);
            savepath = 'B:\Heart Rate Analysis\data\';
            figpath = 'B:\Heart Rate Analysis\figs\';
            w = 'wo';
    end
    
    %% Load heart rate and adjust for time relative to hypnostart
    hr = load(['B:\Heart Rate Analysis\data\hr\' id '.txt']);
    hr(:,1) = hr(:,1) - subj_struct.EDFStart2HypnoInSec;
    hr = hr(hr(:,1) > 0,:);
    
    if ~isempty(subj_struct) && ~isempty(ev_vec)
        points = plot_subject_mean(hr,ev_vec,true);
        output_names = [output_names ; id];
        output_points = [output_points ; points];
        num_rlm = [num_rlm ; size(rLM,1)];
        num_llm = [num_llm ; size(lLM,1)];
        num_arousals = [num_arousals ; size(assoc,1)];
        arousals_w_llm = [arousals_w_llm ; sum(assoc)];
        arousals_wo_llm = [arousals_wo_llm ; sum(~assoc)];
        
        savefig([figpath id]); close;
        save([savepath id],'points');
        clear psg hr ev_vec points subj_id CLM
    else
        fprintf('Subject %s has empty ev_vec\n',id);
        fails = [fails; id];
    end
    fprintf('Finished %d of %d records\n',i,size(psgs,1));
end

%% Assemble output table
point_tbl = array2table(output_points,'VariableNames',{'pre1' 'pre2' 'pre3'...
    'pre4' 'pre5' 'post1' 'post2' 'post3' 'post4' 'post5' 'post6' 'post7'...
    'post8' 'post9' 'post10'});

T = [table(output_names,'VariableNames',{'Subject_ID'}) point_tbl ...
    array2table(arousals_w_llm) array2table(arousals_wo_llm) ...
    array2table(num_arousals) array2table(num_rlm) array2table(num_llm)];

T.withCLM = repmat(withLM,size(T,1),1);
load 'diagnosis.mat';
T.Subject_ID = cellstr(T.Subject_ID);
T = innerjoin(T,TEST,'rightkeys','Subject_ID','leftkeys',...
    'Subject_ID','rightvariables','Diagnosis');
f = fopen(['errors_' w a '.dat'],'w');
for row = 1:size(fails,1)
    fprintf(f,'%s\n',fails{row,:})
end
end % end function

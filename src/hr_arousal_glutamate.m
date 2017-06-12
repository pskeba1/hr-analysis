function T = hr_arousal_glutamate(withCLM)
%% T = hr_arousal_glutamate()
% This script looks at the heart rate increases before and after arousal
% events. Right now it runs through the Glutamate study. This is a fine
% template for other hr analysis scripts, but make sure hr has already been
% calculated by python or else this will take a ridiculously long time.

addpath('helper_functions');
load('names.mat'); % subjects that are used in this study

psgs = rdir('D:\Glutamate Study\**\edf_event.mat'); % path to psg

%% Just do it here...
lb = 0.5; ub = 0.5;

output_names = [];
output_points = [];
num_clm = [];
num_arousals = [];
arousals_w_clm = [];
arousals_wo_clm = [];

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
        continue;
    end
    CLM = plm_outputs.CLM; % includes wake and sleep for now
    epochStage = plm_outputs.epochstage;
    CLM = CLM(CLM(:,6) > 0,:);
    
    %% Determine which arousals are associated with CLMs
    ev_vec = eventtime2points(subj_struct,'start_time','hypno_start');
    %ev_vec(:,6) = 0; % doesn't support sleep staging yet
    ev_vec(:,3) = epochStage(round(ev_vec(:,1)/30/500+.5));
    ev_vec = ev_vec(ev_vec(:,3) > 0,1:2);
    assoc = associate_events(ev_vec,CLM,lb,ub,500);
    
    %% Check if we want arousal with or without CLM
    switch withCLM
        case 1 
            ev_vec = ev_vec(~assoc,:);
            savepath = 'D:\Heart Rate Analysis\data\ar_w_clm 7-Jun-2017/';
            figpath = 'D:\Heart Rate Analysis\figs\ar_w_clm 7-Jun-2017/';
        case 0
            ev_vec = ev_vec(assoc,:);
            savepath = 'D:\Heart Rate Analysis\data\ar_wo_clm 7-Jun-2017/';
            figpath = 'D:\Heart Rate Analysis\figs\ar_wo_clm 7-Jun-2017/';
    end
    
    %% Load heart rate and adjust for time relative to hypnostart
    hr = load(['D:\Heart Rate Analysis\data\hr\' id '.txt']);
    hr(:,1) = hr(:,1) - subj_struct.EDFStart2HypnoInSec;
    hr = hr(hr(:,1) > 0,:);
    
    if ~isempty(subj_struct) && ~isempty(ev_vec)
        points = plot_subject_mean(hr,ev_vec,true);
        output_names = [output_names ; id];
        output_points = [output_points ; points];
        num_clm = [num_clm ; size(CLM,1)];
        num_arousals = [num_arousals ; size(assoc,1)];
        arousals_w_clm = [arousals_w_clm ; sum(assoc)];
        arousals_wo_clm = [arousals_wo_clm ; sum(~assoc)];
        
        savefig([figpath id]); close;
        save([savepath id],'points');
        clear psg hr ev_vec points subj_id CLM
    end
    fprintf('Finished %d of %d records\n',i,size(psgs,1));
end

%% Assemble output table
point_tbl = array2table(output_points,'VariableNames',{'pre1' 'pre2' 'pre3'...
    'pre4' 'pre5' 'post1' 'post2' 'post3' 'post4' 'post5' 'post6' 'post7'...
    'post8' 'post9' 'post10'});

T = [table(output_names,'VariableNames',{'Subject_ID'}) point_tbl ...
    array2table(arousals_w_clm) array2table(arousals_wo_clm) ...
    array2table(num_arousals) array2table(num_clm)];

T.withCLM = repmat(withCLM,size(T,1),1);
load 'diagnosis.mat';
T.Subject_ID = cellstr(T.Subject_ID);
T = innerjoin(T,TEST,'rightkeys','Subject_ID','leftkeys',...
    'Subject_ID','rightvariables','Diagnosis');

end % end function (hard to keep track here)








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for i = 1:size(hr_arousal_subs,1)
%     subj_id = hr_arousal_subs{i};
%     load(fullfile(study_base,subj_id))
% %     psg_path = find(not(cellfun('isempty',strfind(ids,subj_id))));
% %     psg = load([study_base f(psg_path).name '/' subj_id '.mat']);
% %     psg = psg.(subj_id); % struct needs to have subj id for now
%     
% %     load([study_base f(psg_path).name '/' subj_id '-results.mat'],'plm_outputs');
%     load(fullfile(plm_output_base,subj_id));
%     CLM = plm_outputs.CLM;
% %     CLM(:,1:2) = CLM(:,1:2) + psg.EDFStart2HypnoInSec*500; % adjust times
%     
% %     ev_vec = eventtime2points(psg,'start_time','hypno_start');
%     ev_vec = eventtime2points(subj_struct,'start_time','hypno_start');
%     ev_vec(:,6) = 0; % doesn't support sleep staging yet
%     assoc = associate_events(ev_vec,CLM,.5,.5,500);
%     
%     if withCLM
%         ev_vec = ev_vec(assoc,:); % arousal WITH CLM
%     else
%         ev_vec = ev_vec(~assoc,:); % arousal WITHOUT CLM
%     end
%     
%     % skip if there's less than 10 movements
% %     if size(ev_vec,1) < 5, continue; end
%     
%     hr = load(['G:/hr-analysis/data/hr/' subj_id '.txt']);
%     % try to adjust start times this way?
%     hr(:,1) = hr(:,1) - subj_struct.EDFStart2HypnoInSec;
%     hr = hr(hr(:,1) > 0,:);    
%     
%     if ~isempty(subj_struct) && ~isempty(ev_vec)
%         points = plot_subject_mean(hr,ev_vec,false);
%         output_names = [output_names ; subj_id];
%         output_points = [output_points ; points];
%         num_clm = [num_clm ; size(CLM,1)];
%         num_arousals = [num_arousals ; size(assoc,1)];
%         arousals_w_clm = [arousals_w_clm ; sum(assoc)];
%         arousals_wo_clm = [arousals_wo_clm ; sum(~assoc)];
%         
% %         savefig(['../figs/' subj_id]); close;
% %         save(['../data/10_beat_centered_hr_arousal/' subj_id],'points');
%         clear psg hr ev_vec points subj_id CLM
%     end
%     display(sprintf('Finished %d of %d records',i,size(hr_arousal_subs,1)));
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
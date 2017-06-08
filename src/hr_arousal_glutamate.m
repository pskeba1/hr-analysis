function T = hr_arousal_glutamate(withCLM)
%% T = hr_arousal_glutamate()
% This script looks at the heart rate increases before and after arousal
% events. Right now it runs through the Glutamate study. This is a fine
% template for other hr analysis scripts, but make sure hr has already been
% calculated by python or else this will take a ridiculously long time.

addpath('helper_functions');
load('names.mat');

%f = dir('D:/Glutamate Study/AidRLS*'); % path to psg
f = dir('../data/psg/G*');
% study_base = 'D:/Glutamate Study/';
study_base = '../data/psg';
plm_output_base = '../data/plm_outputs';
ids = extractfield(f,'name');
output_names = [];
output_points = [];
num_clm = [];
num_arousals = [];
arousals_w_clm = [];
arousals_wo_clm = [];

for i = 1:size(hr_arousal_subs,1)
    subj_id = hr_arousal_subs{i};
    try
        load(fullfile(study_base,subj_id))
    %     psg_path = find(not(cellfun('isempty',strfind(ids,subj_id))));
    %     psg = load([study_base f(psg_path).name '/' subj_id '.mat']);
    %     psg = psg.(subj_id); % struct needs to have subj id for now
    %     load([study_base f(psg_path).name '/' subj_id '-results.mat'],'plm_outputs');
        load(fullfile(plm_output_base,subj_id));
        CLM = plm_outputs.CLM;
    %     CLM(:,1:2) = CLM(:,1:2) + psg.EDFStart2HypnoInSec*500; % adjust times

    %     ev_vec = eventtime2points(psg,'start_time','hypno_start');
        ev_vec = eventtime2points(subj_struct,'start_time','hypno_start');
        ev_vec(:,6) = 0; % doesn't support sleep staging yet
        assoc = associate_events(ev_vec,CLM,.5,.5,500);

        if withCLM
            ev_vec = ev_vec(assoc,:); % arousal WITH CLM
        else
            ev_vec = ev_vec(~assoc,:); % arousal WITHOUT CLM
        end

        % skip if there's less than 10 movements
    %     if size(ev_vec,1) < 5, continue; end

        hr = load(['../data/hr/' subj_id '.txt']);
        % try to adjust start times this way?
        hr(:,1) = hr(:,1) - subj_struct.EDFStart2HypnoInSec;
        hr = hr(hr(:,1) > 0,:);    

        if ~isempty(subj_struct) && ~isempty(ev_vec)
            points = plot_subject_mean(hr,ev_vec,true);
            output_names = [output_names ; subj_id];
            output_points = [output_points ; points];
            num_clm = [num_clm ; size(CLM,1)];
            num_arousals = [num_arousals ; size(assoc,1)];
            arousals_w_clm = [arousals_w_clm ; sum(assoc)];
            arousals_wo_clm = [arousals_wo_clm ; sum(~assoc)];

            savefig(['../figs/' subj_id]); close;
            save(['../data/10_beat_centered_hr_arousal/' subj_id],'points');
            clear psg hr ev_vec points subj_id CLM
        end
    catch
        disp('Error with subject, continuing.')
    end
    display(sprintf('Finished %d of %d records',i,size(hr_arousal_subs,1)));
end

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
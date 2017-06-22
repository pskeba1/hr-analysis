function emg_timeplot(withCLM,lb,ub)

addpath('helper_functions');
load('names.mat'); % subjects that are used in this study

psgs = rdir('B:\Glutamate Study\**\edf_event.mat'); % path to psg


for i = 1:size(psgs,1)

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
        load([psgs(i).folder '\processed_emg.mat']);
        load(fullfile(psgs(i).folder,'results05-Jun-2017'));
    catch
        fprintf('Could not load data for %s\n',id);
        continue;
    end

    lLM = plm_outputs.lLM; % includes wake and sleep for now
    rLM = plm_outputs.rLM; % includes wake and sleep for now
    epochStage = plm_outputs.epochstage;
    
    %% Determine which arousals are associated with CLMs
    ev_vec = eventtime2points(subj_struct,'start_time','hypno_start');
    %ev_vec(:,6) = 0; % doesn't support sleep staging yet
    ev_vec(:,3) = epochStage(round(ev_vec(:,1)/30/500+.5));
    ev_vec = ev_vec(ev_vec(:,3) > 0,1:2);
    rAssoc = associate_events(ev_vec,rLM,lb,ub,500);
    lAssoc = associate_events(ev_vec,lLM,lb,ub,500);
    assoc = rAssoc|lAssoc;
    
    %% Check if we want arousal with or without CLM
    switch withCLM
        case 1 
            ev_vec = ev_vec(assoc,:);
            figpath = 'B:\emg_wLM_figs\';
            w_wo = 'with';
        case 0
            ev_vec = ev_vec(~assoc,:);
            figpath = 'B:\emg_woLM_figs\';
            w_wo = 'without';
    end
    
    try
        fs = plm_outputs.fs;
        EMG = max([rEMG lEMG],2);
        t = (1:size(rEMG,1))/fs/86400; t = t';
        t = t + datenum(plm_outputs.hypnostart);
        t = datetime(datevec(t));

        rEMG(:,2:3) = nan;
        for j = 1:size(ev_vec)
           rEMG(ev_vec(j,1):ev_vec(j,2),2) = ...
               rEMG(ev_vec(j,1):ev_vec(j,2),1);
        end
    %     for i = 1:size(plm_outputs.CLM)
    %        rEMG(plm_outputs.CLM(i,1):plm_outputs.CLM(i,2),2) = ...
    %            rEMG(plm_outputs.CLM(i,1):plm_outputs.CLM(i,2),1);
    %     end
    %     
    %     for i = 1:size(plm_outputs.PLM)
    %        rEMG(plm_outputs.PLM(i,1):plm_outputs.PLM(i,2),3) = ...
    %            rEMG(plm_outputs.PLM(i,1):plm_outputs.PLM(i,2),1);
    %     end

        figure
        plot(t,rEMG)
        title([id ' EMG (arousals ' w_wo ' CLM)'])

        fprintf('Finished %d of %d records\n',i,size(psgs,1));
        savefig([figpath id]);
        close;
    catch ME
        rethrow(ME)
        fprintf(['Could not generate EMG graph ' w_wo ' CLM for %s\n'],id);
        continue;
    end
end

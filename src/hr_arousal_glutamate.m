function T = hr_arousal_glutamate(withCLM,lmType)
%% T = hr_arousal_glutamate()
% This script looks at the heart rate increases before and after arousal
% events. Right now it runs through the Glutamate study. This is a fine
% template for other hr analysis scripts, but make sure hr has already been
% calculated by python or else this will take a ridiculously long time.
%
% lmType options: 0 (all lm), 1 (periodic), 2 (nonperiodic)
%                 3 (lm with arousal - reversed)

if lmType == 3
    T = hr_lm_glutamate(withCLM);
    return
end

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
%         load(psgs(i).name);
        load(['D:\Heart Rate Analysis\data\arousals\' id]);
        load(['D:\Heart Rate Analysis\data\start2hyp\' id]);
        load(fullfile(psgs(i).folder,'results05-Jun-2017'));
    catch
        fprintf('Could not load data for %s\n',id);
        continue;
    end
    
    epochStage = plm_outputs.epochstage;
    
    lLM = plm_outputs.lLM; rLM = plm_outputs.rLM;
    CLM = rOV2(lLM,rLM,500);
    
    try
        CLM(:,3) = epochStage(round(CLM(:,1)/30/500+.5));
    catch
        badi = 1;
        while round(CLM(end-badi,1)/30/500+.5) > size(epochStage,1)
            badi = badi+1;
        end
        CLM(1:end-badi,3) = epochStage(round(CLM(1:end-badi,1)/30/500+.5));
        CLM(end-badi+1:end,3) = CLM(end-badi,3);
        fprintf('Subject %s goes a little past epoch\n',id);
    end
    
    CLM = CLM(CLM(:,3) > 0,1:2);
    
    switch lmType
        case 0
            if withCLM
                savepath = 'D:\Heart Rate Analysis\data\ar_w_lm 21-Jun-2017/';
                figpath = 'D:\Heart Rate Analysis\figs\ar_w_lm 21-Jun-2017/';
            else
                savepath = 'D:\Heart Rate Analysis\data\ar_wo_lm 21-Jun-2017/';
                figpath = 'D:\Heart Rate Analysis\figs\ar_wo_lm 21-Jun-2017/';
            end
        case 1 % only periodic events
            PLM = plm_outputs.PLM; 
            PLM = PLM(PLM(:,6) > 0,:);
            CLM = PLM;
            if withCLM
                savepath = 'D:\Heart Rate Analysis\data\ar_w_per 21-Jun-2017/';
                figpath = 'D:\Heart Rate Analysis\figs\ar_w_per 21-Jun-2017/';
            else
                savepath = 'D:\Heart Rate Analysis\data\ar_wo_per 21-Jun-2017/';
                figpath = 'D:\Heart Rate Analysis\figs\ar_wo_per 21-Jun-2017/';
            end
        case 2 % only nonperiodic events
            PLM = plm_outputs.PLM; 
            PLM = PLM(PLM(:,6) > 0,:);
            non_x = setdiff(CLM(:,1),PLM(:,1));
            CLM = CLM(ismember(CLM(:,1),non_x),:);
            if withCLM
                savepath = 'D:\Heart Rate Analysis\data\ar_w_nonper 21-Jun-2017/';
                figpath = 'D:\Heart Rate Analysis\figs\ar_w_nonper 21-Jun-2017/';
            else
                savepath = 'D:\Heart Rate Analysis\data\ar_wo_nonper 21-Jun-2017/';
                figpath = 'D:\Heart Rate Analysis\figs\ar_wo_nonper 21-Jun-2017/';
            end            
    end
       
    %% Prepare event vector (arousals)
    try
        ev_vec(:,3) = epochStage(round(ev_vec(:,1)/30/500+.5));
    catch
        badi = 1;
        while round(ev_vec(end-badi,1)/30/500+.5) > size(epochStage,1)
            badi = badi+1;
        end
        ev_vec(1:end-badi,3) = epochStage(round(ev_vec(1:end-badi,1)/30/500+.5));
        ev_vec(end-badi+1:end,3) = ev_vec(end-badi,3);
        fprintf('Subject %s goes a little past epoch\n',id);
    end
    ev_vec = ev_vec(ev_vec(:,3) > 0,1:2);
    assoc = associate_events(ev_vec,CLM,lb,ub,500);
    
    %% Check if we want arousal with or without CLM
    switch withCLM
        case 0
            try
                ev_vec = ev_vec(~assoc,:);
            catch
                ev_vec = [];
            end
        case 1
            try
                ev_vec = ev_vec(assoc,:);
            catch
                ev_vec = [];
            end
    end
    
    %% Load heart rate and adjust for time relative to hypnostart
    hr = load(['D:\Heart Rate Analysis\data\hr\' id '.txt']);
    hr(:,1) = hr(:,1) - EDFStart2HypnoInSec;
    hr = hr(hr(:,1) > 0,:);
    
    if ~isempty(ev_vec)%~isempty(subj_struct) && ~isempty(ev_vec)
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
T.maxpost = max(T{:,7:16},[],2);

end % end function (hard to keep track here)

function [CLM] = rOV2(lLM,rLM,fs)
% Combine bilateral movements if they are separated by < 0.5 seconds

% combine and sort LM arrays
rLM(:,13) = 1; lLM(:,13) = 2;
combLM = [rLM;lLM];
combLM = sortrows(combLM,1); % sort by start time

% distance to next movement
CLM = combLM;
CLM(:,4) = 1;

i = 1;

while i < size(CLM,1)
    % make sure to check if this is correct logic for the half second
    % overlap period...
    if isempty(intersect(CLM(i,1):CLM(i,2),(CLM(i+1,1)-fs/2):CLM(i+1,2)))
        i = i+1;
    else
        CLM(i,2) = max(CLM(i,2),CLM(i+1,2));
        CLM(i,4) = CLM(i,4) + CLM(i+1,4);
        CLM(i,9) = max([CLM(i,9) CLM(i+1,9)]);
        if CLM(i,13) ~= CLM(i+1,13)
            CLM(i,13) = 3;
        end
        CLM(i+1,:) = [];
    end
end

end
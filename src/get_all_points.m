function T = get_all_points(withCLM,lmType)
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

all_points = [];
all_ids = [];

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
        points = get_all_stuff(hr,ev_vec);
        all_points = [all_points ; points];
        all_ids = [all_ids ; repmat(id,size(points,1),1)];
    end
    fprintf('Finished %d of %d records\n',i,size(psgs,1));    
end

T = table(all_ids,all_points(:,1:5),all_points(:,6:15),'VariableNames',...
    {'Subject_ID','pre','post'});

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

function points = get_all_stuff(hr,PLM)
%% points = plot_subject_mean(hr,PLM)
% This will create an array, points, with the means for each point. Note
% that PLM may be any time of event array, so long as it has start and stop
% times.

points = [];
imi = []; dur = [];

for i = 1:size(PLM,1)
    y = plot_beat_beat(hr,PLM,i,0);
    if size(y,2) < 2, continue; end
    points = [points ; y(:,2)']; % want in relation to mean
end

% points = mean(points,1);

end

function y = plot_beat_beat(hr,PLM,i,plt)
%%
% Heartrate should not be adjusted in this case, except to convert to
% data points from seconds
%
% Remember to add time to PLM start and stop to reflect the beginning
% of the record taking place before the occurence of hypnogram scoring

% instead of time, try 10 beats before onset and 20 beats after

fs = 500;
prenum = 5; postnum = 10;
hr(:,1) = round(hr(:,1) * fs);

point = knnsearch(hr(:,1),PLM(i,1));
if hr(point,1) >= PLM(i,1), point = point - 1; end % make sure we have preceding

if point-10 < 1 || point+11 > size(hr,1)
    y = [];
    return;
end

prepoints = hr(point-prenum:point-1,:); postpoints = hr(point+1:point+postnum,:);
y = [prepoints(:,2) ; postpoints(:,2)];
y(:,2) = y(:,1)./mean(y(1:prenum,1)); % percent of pre-PLM mean
% y(:,2) = y(:,1) - mean(y(1:prenum,1)); % percent of pre-PLM mean


if plt
    switch PLM(i,6)
        case 0 % yellowish
            c = [1,0.843137254901961,0];
        case 1 % orangish
            c = [0.929411764705882,0.694117647058824,0.125490196078431];
        case 2 % darkish blue
            c = [0,0.4,0.6];
        case 3 % darker blue
            c = [0.313725490196078,0.313725490196078,0.313725490196078];
        case 5 % pretty much black
            c = [0.6,0,0];
    end
    
    % time vector for plotting
    t = ([prepoints(:,1) ; postpoints(:,1)])/86400/500;
    
    %y = (smooth(hr_vec(PLM(i,1)-fw:PLM(i,2)+bw,1),800));
    
    
    
    display(['Max peak after PLM is ' num2str(max(y(11:end,2)) * 100) ...
        '% of the pre-PLM mean']);
    
    plm_time = PLM(i,1)/86400/500;
    
    figure
    subplot(2,1,1);
    area(t,y(:,2),'facecolor',c)
    title(['PLM during stage ' num2str(PLM(i,6))])
    ylabel('Percent of pre-PLM mean HR')
    ylim([0.7,1.5])
    datetickzoom('x','HH:MM:SS')
    f = ylim;
    line([plm_time plm_time],[f(1),f(2)])
    
    subplot(2,1,2);
    area(t,y(:,1),'facecolor',c)
    ylabel('Smoothed HR')
    datetickzoom('x','HH:MM:SS')
    f = ylim;
    line([plm_time plm_time],[f(1),f(2)])
    close;
end
end
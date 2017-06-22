function points = plot_subject_mean(hr,PLM,doplot)
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

points = mean(points,1);

if ~doplot, return; end

figure
area(points,'facecolor',[0.8,0.8,1]);
ylim([0.8,1.4])
f = ylim;
line([5.5 5.5],[f(1) f(2)],'color','r')

title('Mean HR elevation above mean')
ylabel('Percent of pre-PLMS mean HR')

% display(['Max peak after PLM is ' num2str(max(points(1,11:end)) * 100) ...
%         '% of the pre-PLM mean']);

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
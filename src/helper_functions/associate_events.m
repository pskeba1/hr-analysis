function assoc = associate_events(arousal,CLM,lb,ub,fs)
%% assoc = associate_events(primary_event,associating_event,lb,ub,fs)
% Very simple 

assoc = zeros(size(arousal,1),1);
if isempty(CLM), return; end

% event_ends = CLM(:,2);
% event_intervals = [round(event_ends - fs*lb), round(event_ends + fs*ub)];
event_intervals = [round(CLM(:,1) - fs*lb) round(CLM(:,2) + fs*ub)];
event_intervals(event_intervals(:,1) < 1,1) = 1;


ev_vec = zeros(max(event_intervals(end,2),arousal(end,2)),1);
for j = 1:size(event_intervals,1)
    ev_vec(event_intervals(j,1):event_intervals(j,2)) = 1;
end



for j = 1:size(arousal,1)
    if any(ev_vec(arousal(j,1):arousal(j,2)) == 1) 
        assoc(j) = 1;
    end
end

assoc = logical(assoc);
end
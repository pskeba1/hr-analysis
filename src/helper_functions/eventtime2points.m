function ev_vec = eventtime2points(this_subj,varargin)
%% ev_vec = eventtime2points(events)
% Convert event (arousal/apnea usually) cell array into a numerical vector
% where the start point is elapsed datapoints since the beginning of the
% EDF record. Not sure if this works for all studies, it was designed for
% RestEaze PSG. Also, the start time is adjusted based on the EDF start
% rather than hypnogram start since our EKG scoring procedure uses the
% entire EKG signal. There is a parameter to change this
%
% Inputs:
%   this_subj - subject matlab file
%
% Optional parameter inputs:
%   'event_type','NAME' - name can be arousal (default) or apnea
%   'start_time','NAME' - name can be edf_start (default) or hypno_start
%
% Used from this_subj:
%   events - cell array with start time, event, dur (yyyy mm dd HH:MM:SS)
%   dateTime - start time of EDF record (not hypnogram start!)
%
% Outputs:
%   ev_vec - numerical vector containg start and stop points of each
%       event. Points are 500 * seconds from start (EDF or hypnogram)
%
% TODO:
%   - 500 hz sampling rate is hardcoded - bad

p = inputParser;
p.CaseSensitive = false;

p.addParameter('event_type','arousal',@valid_events);
p.addParameter('start_time','edf_start',@valid_times);

p.parse(varargin{:})

tformat = 'yyyy mm dd HH:MM:SS'; % should be what event files look like

if strcmpi(p.Results.event_type,'Arousal')
    events = cell2table(this_subj.CISRE_Arousal);
elseif strcmpi(p.Results.event_type,'Apnea')
    events = cell2table(this_subj.CISRE_Apnea);
elseif strcmpi(p.Results.event_type,'PLM')
    events = cell2table(this_subj.CISRE_PLM);
end

if strcmpi(p.Results.start_time,'edf_start')
    dateTime = this_subj.dateTime;  
elseif strcmpi(p.Results.start_time,'hypno_start')
    dateTime = this_subj.CISRE_HypnogramStart;
end

% dateTime is expected to only have second precision
try 
    start_num = datevec(dateTime,'yyyy mm ddTHH:MM:SS.fff');
catch 
    start_num = datevec(dateTime,'yyyy mm dd HH:MM:SS');
end
ev_datevec = datevec(events{:,1},tformat);
ev_vec = round((etime(ev_datevec(:,1:6),start_num))*500);

%% Let's just make them all 3 seconds for now...
% ev_vec(:,2) = ev_vec(:,1) + round(cell2mat(cellfun(@str2num,events{:,3},'un',0)) * 500);
ev_vec(:,2) = ev_vec(:,1) + 3*500;
% ev_vec(:,2) = ev_vec(:,1) + round(events{:,3} * 500);
end

function isvalid = valid_events(evname)
isvalid = 0;

if strcmpi(evname,'arousal')
    isvalid = 1;
elseif strcmpi(evname,'apnea')
    isvalid = 1;
elseif strcmpi(evname,'PLM')
    isvalid = 1;
else
    error('Current options are arousal and apnea');
end

end

function isvalid = valid_times(evname)
isvalid = 0;

if strcmpi(evname,'edf_start')
    isvalid = 1;
elseif strcmpi(evname,'hypno_start')
    isvalid = 1;
else
    error('Current options are edf_start and hypno_start');
end

end



function [varargout] = hr_from_py(subjid)
f = dir('D:/Glutamate Study/AidRLS*');
study_base = 'D:/Glutamate Study/';

ids = extractfield(f,'name');
this_subj = find(not(cellfun('isempty', strfind(ids,subjid))));


if ~exist([study_base f(this_subj).name '/' subjid '.mat'],'file')
    display(['No struct for ' this_subj ' ...skipping']);
    varargout = cell(nargout,1);
    return; 
end


this_subj = load([study_base f(this_subj).name '/' subjid '.mat']);
this_subj = this_subj.(subjid); % struct needs to have subj id for now

EKG = this_subj.Signals(1).data; % hopefully this is always EKG for now
writetable(array2table(EKG),['../data/ekg/' subjid '.txt']);

ep = hypnovec(this_subj.CISRE_Hypnogram,500);
ep = [zeros(size(EKG,1)-size(ep,1),1) ; ep];
writetable(array2table(ep),['../data/epoch_stage/' subjid '.txt']);

system(['python get_hr.py ' subjid],'-echo');

nout = max(nargout,1);
s = {'this_subj','EKG','ep'};
for k = 1:min(nout,3)
   varargout{k} = eval(s{k});
end

if nout >= 4
   varargout{4} = load(['../data/hr/' subjid '.txt']); 
end

if nout >= 5
    varargout{5} = matplm_new_main(this_subj,'default_params');
end

end

function longep = hypnovec(ep,fs)
lp = repmat(ep,1,fs*30);
longep = [];

for i = 1:size(lp,1)
   longep = [longep ; lp(i,:)']; 
end

end
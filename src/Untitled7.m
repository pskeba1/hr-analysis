psgs = rdir('D:\Glutamate Study\**\results05-Jun-2017.mat');

Subject_ID = {};
TST = [];
SleepEff = [];

for i = 1:size(psgs,1)
    %% Get subject ID
    id = split(psgs(i).folder,'\'); % hopefully slash is consistent
    id = char(id(end)); % part with subject id
    id = split(id,' ');
    id = char(id(2));
        
    %% Load psg and plm_outputs
    %  - could extract arousal so we don't have to load the whole thing
    try
        load(psgs(i).name);
        ep = plm_outputs.epochstage;
        tst = sum(ep > 0)/2; % sleep time in minutes
        trt = size(ep,1)/2;  % TRT in minutes
        Subject_ID = [Subject_ID ; id];
        TST = [TST ; tst/60];
        SleepEff = [SleepEff ; tst/trt];        
    catch
        fprintf('Could not load data for %s\n',id);
        continue;
    end    
end

good_sleepers = table(Subject_ID,TST,SleepEff);
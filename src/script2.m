% w_lm = [w_lm table(max(table2array(w_lm(:,2:16)),[],2),'VariableNames',{'maxChange'})];
% wo_lm = [wo_lm table(max(table2array(wo_lm(:,2:16)),[],2),'VariableNames',{'maxChange'})];

w_arous = results1{1,1};
wo_arous = results1{1,2};
w_lm = results1{1,3};
wo_lm = results1{1,4};


% intersect(intersect(intersect(w_lm(:,1),wo_lm(:,1)),w_arous(:,1)),wo_arous(:,1))
[~,ia,ib] = intersect(w_lm(:,1),wo_lm(:,1));
[~,ja,~] = intersect(w_arous(:,1),wo_lm(:,1));
[~,ka,~] = intersect(wo_arous(:,1),wo_lm(:,1));
a = [table2array(w_lm(ia,22)) table2array(wo_lm(ib,22)) table2array(w_arous(ja,22)) table2array(wo_arous(ka,22))];
b = string(table2cell(w_lm(ia,21)));
rls = a(b(:,1)=='RLS',:);
ctrl = a(b(:,1)=='Control',:);
[p1,~]=signtest(rls(:,1),rls(:,2));
[p2,~]=signtest(ctrl(:,1),ctrl(:,2));
[p3,~]=signtest(rls(:,3),rls(:,4));
[p4,~]=signtest(ctrl(:,3),ctrl(:,4));

[p5,~]=ranksum(rls(:,2),rls(:,4));
[p6,~]=ranksum(ctrl(:,1),ctrl(:,2));

[y1,x1] = ksdensity(good_sleepers_w_all.maxpost);
[y2,x2] = ksdensity(good_sleepers_wo_all.maxpost);
[y3,x3] = ksdensity(ar_w_lm_all.maxpost(strcmp(ar_w_lm_all.Diagnosis,'RLS')));
[y4,x4] = ksdensity(ar_wo_lm_all.maxpost(strcmp(ar_wo_lm_all.Diagnosis,'RLS')));
[y5,x5] = ksdensity(ar_w_lm_all.maxpost(strcmp(ar_w_lm_all.Diagnosis,'Control') & ...
    ~contains(ar_w_lm_all.Subject_ID,good_sleepers_w_all.Subject_ID)));
[y6,x6] = ksdensity(ar_wo_lm_all.maxpost(strcmp(ar_wo_lm_all.Diagnosis,'Control')  & ...
    ~contains(ar_wo_lm_all.Subject_ID,good_sleepers_wo_all.Subject_ID)));


figure
plot(x1,y1,'r')
hold on
plot(x2,y2,'b')
plot(x3,y3,'r--')
plot(x4,y4,'b--')
plot(x5,y5,'r:','Linewidth',1.5)
plot(x6,y6,'b:','linewidth',1.5)
hold off



legend({'good_w','good_{wo}','rls_w','rls_{wo}','cntrl_w','cntrl_{wo}'});
xlabel('Max Post-Arousal hr (% of Pre-Arousal mean)')
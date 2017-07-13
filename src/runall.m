st = tic;
ar_w_lm = hr_arousal_glutamate(1,0);
ar_wo_lm = hr_arousal_glutamate(0,0);
arlm = toc(st);
fprintf('ar_lm took %.3f seconds\n',arlm);

ar_w_per = hr_arousal_glutamate(1,1);
ar_wo_per = hr_arousal_glutamate(0,1);
arper = toc(st);
fprintf('ar_per took %.3f seconds\n',arper-arlm);

ar_w_nonper = hr_arousal_glutamate(1,2);
ar_wo_nonper = hr_arousal_glutamate(0,2);
arnonper = toc(st);
fprintf('ar_nonper took %.3f seconds\n',arnonper-arper);

lm_w_ar = hr_arousal_glutamate(1,3);
lm_wo_ar = hr_arousal_glutamate(0,3);
lmper = toc(st);
fprintf('lm_ar took %.3f seconds\n',lmper-arnonper);
fprintf('Completed all sets in %.3f seconds',lmper);
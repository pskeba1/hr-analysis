function [w_only2,wo_only2] = diagnight(diagnosis,lmtablew,lmtablewo)

w_only2 = lmtablew(contains(lmtablew.Subject_ID,'V1N2'),:);
w_only2 = w_only2(strcmp(w_only2.Diagnosis,diagnosis),:);

wo_only2 = lmtablewo(contains(lmtablewo.Subject_ID,'V1N2'),:);
wo_only2 = wo_only2(strcmp(wo_only2.Diagnosis,diagnosis),:);

comm = intersect(w_only2.Subject_ID,wo_only2.Subject_ID);
w_only2 = w_only2(contains(w_only2.Subject_ID,comm),:);
wo_only2 = wo_only2(contains(wo_only2.Subject_ID,comm),:);

fprintf('Results following....\n');
fprintf('n = %d\n',size(comm,1));
fprintf('Mean maxpost with: %.2f (%.2f)\n',mean(w_only2.maxpost)-1,...
    std(w_only2.maxpost));
fprintf('Mean maxpost without: %.2f (%.2f)\n',mean(wo_only2.maxpost-1),...
    std(wo_only2.maxpost));
fprintf('p-value: %s\n',signrank(w_only2.maxpost-1,wo_only2.maxpost-1))
fprintf('End results.\n');
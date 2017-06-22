function bLM = getComboLM(rLM, lLM, fs)
% check if either array is empty
if isnan(lLM(1,1))
    bLM=rLM;
    return
elseif isnan(rLM(1,1))
    bLM=lLM;
    return
end

% combine and sort LM arrays
rLM(:,3) = 1; lLM(:,3) = 2;
bLM = [rLM;lLM];
bLM = sortrows(bLM,1);

numOverlap = ones(size(bLM,1),1); %Counter for how many monolateral LM per bilateral LM
i=1;
while i < size(bLM,1)
    
    % If no overlap
    if isempty(intersect(bLM(i,1):bLM(i,2),(bLM(i+1,1)-fs/2):bLM(i+1,2)))
        i = i+1;   
    else % There is overlap
        numOverlap(i,1) = numOverlap(i,1) + numOverlap(i+1,1);
        bLM(i,2) = max(bLM(i,2),bLM(i+1,2)); %update end of movement
%         bLM(i,9)=max(bLM(i,9),bLM(i+1,9)); %update break points
        bLM(i,3) = 3; %indicate bilateral movement
        
        bLM(i+1,:) = [];
        numOverlap(i+1,:)=[];
    end
end
end
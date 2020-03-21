% wins1 = wins(:,1340:end)
C = sortrows(wins',6)
C(C(:,6) > 2.^4.9, :) = []
C = C(:,1);
C(diff(C)==0) = []
C(C==0) = [];
m = mean(C(1:end,1))

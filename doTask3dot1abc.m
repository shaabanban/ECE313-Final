% vim:expandtab tabstop=4

% Does all things related to Task 3.1 parts (a) through (c).
% It creates the decision rules for ML and MAP using the training data.
function [Joint_HT_table] = doTask3dot1abc(HT_table_array,H1,H0)
% We will be working with features 1 and 5.
% The columns of Joint_HT_table are as follows:
% 1: X = i; Feature 1's values put in rows.
% 2: Y = j; Feature 5's values put in rows. Must match rows with row 1.
% 3: P(X=i,Y=j | H1); Prob. that X=i & Y=j where a golden alarm was at.
% 4: P(X=i,Y=j | H0); Prob. that X=i & Y=j where a golden alarm was not at.
% 5: ML Predicted Label.
% 6: MAP Predicted Label.
meanarea=HT_table_array{1};
systolic=HT_table_array{5};
Joint_HT_table = cell(0, 6);
for i=1:size(meanarea,1)
    for j=1:size(systolic,1)
        ph1=meanarea(i,2)*systolic(j,2);
        ph0=meanarea(i,3)*systolic(j,3);
        ml=0;
        map=0;
        if ph1>=ph0
            map=1;
        end;
           if ph1/(H1*H1)>=ph0/(H0 * H0)
            ml=1;
        end;
Joint_HT_table(size(Joint_HT_table,1)+1,:)=[{meanarea(i,1)},{systolic(j,1)},{ph1},{ph0},{ml},{map}];
end
end


%H1

[jj,j2,j2] = unique(cell2mat(Joint_HT_table(:,2)));
[ii,i2,i2] = unique(cell2mat(Joint_HT_table(:,1)));
out = [[NaN,ii'];
[jj,accumarray([j2,i2],cell2mat(Joint_HT_table(:,3)),[],[],NaN)]];
mesh(out(1,2:end),out(2:end,1),out(2:end,2:end));

%H0
out = [[NaN,ii'];
[jj,accumarray([j2,i2],cell2mat(Joint_HT_table(:,4)),[],[],NaN)]];
mesh(out(1,2:end),out(2:end,1),out(2:end,2:end));

end
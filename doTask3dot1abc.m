% vim:expandtab tabstop=4

% Does all things related to Task 3.1 parts (a) through (c).
% It creates the decision rules for ML and MAP using the training data.
function [Joint_HT_table] = doTask3dot1abc(HT_table_array)
% We will be working with features 1 and 5.
% The columns of Joint_HT_table are as follows:
% 1: X = i; Feature 1's values put in rows.
% 2: Y = j; Feature 5's values put in rows. Must match rows with row 1.
% 3: P(X=i,Y=j | H1); Prob. that X=i & Y=j where a golden alarm was at.
% 4: P(X=i,Y=j | H0); Prob. that X=i & Y=j where a golden alarm was not at.
% 5: ML Predicted Label.
% 6: MAP Predicted Label.
Joint_HT_table = cell(0, 6);
end
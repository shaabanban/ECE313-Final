% vim:noexpandtab tabstop=4

function [feature] = get_likelihood_h1(patient, feature_index)
feature = tabulate(patient.trainingGolden(feature_index,:));
% The probabilities are divided by 100% to make the likelihood matrix.
feature(:,3) = feature(:,3) / 100.0;
% Zero extend the feature matrix so that H1 and H0 have the same size.
% Concatenate the golden and non-golden alarms to find their min/maxes.
max_val = max([
    patient.trainingGolden(feature_index,:) ...
    patient.trainingNonGolden(feature_index,:) ]);
min_val = min([
    patient.trainingGolden(feature_index,:) ...
    patient.trainingNonGolden(feature_index,:) ]);
diff = min(feature(:,1)) - min_val;
lower_bound_zeros = zeros(diff, 3);
diff = max_val - max(feature(:,1));
upper_bound_zeros = zeros(diff, 3);
feature = [lower_bound_zeros; feature; upper_bound_zeros];
clearvars max_val min_val diff lower_bound_zeros upper_bound_zeros;
end
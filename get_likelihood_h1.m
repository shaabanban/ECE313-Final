% vim:noexpandtab tabstop=4

function [feature] = get_likelihood_h1(patient, feature_index)
% Gets the frequencies of the values in the matrix.
% However, it may not be properly bounded.
non_padded_feature = tabulate(patient.trainingGolden(feature_index,:));
% The probabilities are divided by 100% to make the likelihood matrix.
non_padded_feature (:,3) = non_padded_feature (:,3) / 100.0;

% Zero extend the feature matrix so that H1 and H0 have the same size.
% Concatenate the golden and non-golden alarms to find their min/maxes.
max_val = max([
    patient.trainingGolden(feature_index,:) ...
    patient.trainingNonGolden(feature_index,:) ]);
min_val = min([
    patient.trainingGolden(feature_index,:) ...
    patient.trainingNonGolden(feature_index,:) ]);

% Create the likelihood matrix for the feature. This is zero padded.
% It also accounts for unaccounted for indices within the min/max values.
size = max_val + abs(min_val);
feature = zeros(size, 2);
for i = 1 : size
    feature_index = find(non_padded_feature(:,1) == i + min_val - 1);
    % Copy the index directly into feature's 1st column.
    feature(i, 1) = i + min_val - 1;
    % If the value had a frequency in the original frequency matrix,
    % It will have a probability. Otherwise, we leave it at zero.
    if isempty(feature_index) == 0
        % Copy the probability into feature's 2nd column.
        % We will ignore the tabulate function's 2nd column (item count).
        feature(i, 2) = non_padded_feature(feature_index, 3);
    end
end
end
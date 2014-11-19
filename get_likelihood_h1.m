% vim:noexpandtab tabstop=4

function [feature_h1, feature_h0] = get_likelihood_h1(patient, feature_index)
% Gets the frequencies of the values in the matrix.
% However, it may not be properly bounded.
non_padded_feature_h1 = tabulate(patient.trainingGolden(feature_index,:));
% The probabilities are divided by 100% to make the likelihood matrix.
non_padded_feature_h1(:,3) = non_padded_feature_h1(:,3) / 100.0;

% Repeat the above for the non-golden alarms (when there is no alarm).
non_padded_feature_h0 = tabulate(patient.trainingNonGolden(feature_index,:));
non_padded_feature_h0(:,3) = non_padded_feature_h0(:,3) / 100.0;

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
feature_h1 = zeros(size, 2);
feature_h0 = zeros(size, 2);
for i = 1 : size
    % Try to find the value from min to max within the original
    % frequency matrix. At i = 1, this is "min_val".
    % At i = size, this is "max_val".
    feature_index = find(non_padded_feature_h1(:,1) == i + min_val - 1);
    % Copy the index directly into feature's 1st column.
    feature_h1(i, 1) = i + min_val - 1;
    % If the value had a frequency in the original frequency matrix,
    % It will have a probability. Otherwise, we leave it at zero.
    if isempty(feature_index) == 0
        % Copy the probability into feature's 2nd column.
        % We will ignore the tabulate function's 2nd column (item count).
        feature_h1(i, 2) = non_padded_feature_h1(feature_index, 3);
    end
    
    % Repeat for the non-golden alarms.
    feature_index = find(non_padded_feature_h0(:,1) == i + min_val - 1);
    feature_h0(i, 1) = i + min_val - 1;
    if isempty(feature_index) == 0
        feature_h0(i, 2) = non_padded_feature_h0(feature_index, 3);
    end
end

clearvars non_padded_feature_h1 non_padded_feature_h0 feature_index ...
    max_val min_val size;
end
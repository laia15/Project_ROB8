function [features, labels] = extract_features(EEG_data, EEG_labels, sampling_rate, window_seconds, overlap_seconds, threshold)

window_size = window_seconds*sampling_rate;
window_overlap = overlap_seconds*sampling_rate;

% Initialize the feature matrix and label vector
features_w = [];
labels_w = {};
loop_size = floor(size(EEG_data,1)/(sampling_rate*window_seconds));

% Loop through each window of data and extract features
for i = 1:loop_size
    
    % Extract the current window of data
    window = EEG_data(i:i+window_size-1,:);
    
    % Extract the features for this window
    mean_amp = mean(window, 1); % mean amplitude
    std_amp = std(window, [], 1); % standard deviation of amplitude
    [min_amp, ind] = min(window, [], 1); % position and minimum amplitude
    area = trapz(window, 1); % area under the graph
    below_thresh = window < threshold;
    durations = sum(below_thresh, 1); % duration below threshold
    
    % Concatenate the features into a single row
    row = [mean_amp, std_amp, ind, min_amp, area, durations];
    
    % Add the row to the feature matrix and the label to the label vector
    features_w = [features_w; row];
    if ~strcmp(EEG_labels, 'None')
        labels_w{i} = EEG_labels((i-1)*window_overlap+1:i*window_overlap+window_size-1);
    end
end

% Concatenate the label vectors into a single vector
if ~strcmp(EEG_labels, 'None')
    labels_w = cell2mat(labels_w);
    labels_w = labels_w(1, :);
end

% remove 0 variance features
% Calculate the variance of each feature
variance = var(features_w);

% Find the indices of features with zero variance
zero_var_indices = find(variance == 0);

% Remove the features with zero variance from the feature matrix
features_w(:, zero_var_indices) = [];

% Scale the features to have zero mean and unit variance
features_w = zscore(features_w);

labels = labels_w;
features = features_w;
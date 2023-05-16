load('EEG_Data_Alternating_Blinks.mat')
EEG_data = y(2:end, 2500:end)';

% load('Unicorn_Data.mat')
% EEG_data2 = y(2:end, 2500:end)';
% EEG_data = [EEG_data; EEG_data2];
sampling_rate = 250;% your sampling frequency here;

% Define time vector
n_samples = size(EEG_data, 1);
time = linspace(0, n_samples/sampling_rate, n_samples);

% Bandpass filter
low_cutoff = 1;
high_cutoff = 13;
[b, a] = butter(2, [low_cutoff, high_cutoff] / (sampling_rate / 2), 'bandpass');
filtered_EEG = filtfilt(b, a, EEG_data);

% Notch filter
 Wn = [48 52]/sampling_rate*2;        % Cutoff frequencies
[bn,an] = butter(2,Wn,'stop');        % Calculate filter coefficients
filtered_EEG = filtfilt(bn, an, filtered_EEG);

% Extract epochs
epoch_length = 5 * sampling_rate;
num_epochs = floor(n_samples / epoch_length);

roi_epochs = [];
roi_labels = [];

% Loop over epochs
for epoch = 1:num_epochs
    % Get the current cycle and phase within the cycle
    cycle = floor((epoch - 1) / 4);
    phase = mod(epoch - 1, 4);
    
    % Check if the phase corresponds to a Blink or No Noise/No Blink state
    if phase == 1 || phase == 3
        % If so, add this epoch to our list of interesting epochs
        start_sample = (epoch - 1) * epoch_length + 1;
        end_sample = epoch * epoch_length;
        roi_epochs = [roi_epochs; filtered_EEG(start_sample:end_sample, :)];
        
        % Also add a corresponding label
        if phase == 3
            roi_labels = [roi_labels; 1]; % Blink
        else
            roi_labels = [roi_labels; 0]; % No Noise/No Blink
        end
    end
end


labels = roi_labels;





% Choose one EEG channel to display (for example, the first one)
chosen_channel = 1;

% Define colors for each class
colors = ['r', 'b']; % For example, 'b' for non-blinking, 'r' for blinking

% Create a new figure
figure;

% Get the number of interesting epochs
num_interesting_epochs = size(roi_epochs, 1) / epoch_length;

% Loop over interesting epochs
for epoch = 1:num_interesting_epochs
    % Get the start and end sample for this epoch
    start_sample = (epoch - 1) * epoch_length + 1;
    end_sample = epoch * epoch_length;
    
    % Get the time vector for this epoch
    epoch_time = (start_sample:end_sample) / sampling_rate;
    
    % Get the EEG data for this epoch
    epoch_data = roi_epochs(start_sample:end_sample, chosen_channel);
    
    % Get the label for this epoch
    epoch_label = roi_labels(epoch);
    
    % Plot this epoch with the color corresponding to its label
    plot(epoch_time, epoch_data, colors(epoch_label + 1)); % +1 because MATLAB indices start at 1
    hold on;
end

% Add labels and title
xlabel('Time (s)');
ylabel('Amplitude');
title('EEG Data with Epoch Labels');
legend('Blinking', 'Not-Blinking');









% Calculate the number of channels
num_channels = size(roi_epochs, 2);

% Initialize feature matrix
features = zeros(num_interesting_epochs, num_channels * 3);

% Extract features from each epoch (mean, variance, kurtosis)
for epoch = 1:num_interesting_epochs
    % Get the start and end sample for this epoch
    start_sample = (epoch - 1) * epoch_length + 1;
    end_sample = epoch * epoch_length;
    
    % Get the EEG data for this epoch
    epoch_data = roi_epochs(start_sample:end_sample, :);
    
    % Calculate mean, variance, and kurtosis
    mean_features = mean(epoch_data);
    var_features = var(epoch_data);
    kurtosis_features = kurtosis(epoch_data);
    
    % Add these features to our feature matrix
    features(epoch, :) = [mean_features, var_features, kurtosis_features];
end

% Train an LDA classifier
lda = fitcdiscr(features, roi_labels);

% Train an LDA classifier with cross-validation
cvmodel = crossval(lda);

% Predict using the trained LDA classifier
predicted_labels = kfoldPredict(cvmodel);

% Calculate performance metrics
accuracy = 1 - kfoldLoss(cvmodel);
fprintf('Cross-validated Accuracy: %.2f\n', accuracy * 100);

% Plot the confusion matrix
figure;
confusionchart(labels, predicted_labels);


















% Load new data
eeg13 = load('realtime_testing_eeg.mat');
new_EEG_data = eeg13.y(2:end, 2500:end)';

% Preprocess new data (filtering)
new_filtered_EEG = filtfilt(b, a, new_EEG_data);

% Extract epochs from new data
n_samples_new = size(new_EEG_data, 1);
num_epochs_new = floor(n_samples_new / epoch_length);
new_epochs = zeros(num_epochs_new, epoch_length, 8);
for epoch = 1:num_epochs_new
    start_sample = (epoch - 1) * epoch_length + 1;
    end_sample = epoch * epoch_length;
    new_epochs(epoch, :, :) = new_filtered_EEG(start_sample:end_sample, :);
end

% Extract features from new epochs
new_features = zeros(num_epochs_new, 8 * 3);
for epoch = 1:num_epochs_new
    mean_features = squeeze(mean(new_epochs(epoch, :, :), 2));
    var_features = squeeze(var(new_epochs(epoch, :, :), 0, 2));
    kurtosis_features = squeeze(kurtosis(new_epochs(epoch, :, :), 1, 2));
    new_features(epoch, :) = [mean_features', var_features', kurtosis_features'];
end

% Predict labels for new data using the trained LDA classifier
new_predicted_labels = predict(lda, new_features);



% Choose one EEG channel to display (for example, the first one)
chosen_channel = 1;

% Define colors for each class
colors = ['r', 'b']; % For example, 'b' for non-blinking, 'r' for blinking

% Create a new figure
figure;

% Loop over epochs
for epoch = 1:num_epochs_new
    % Get the start and end sample for this epoch
    start_sample = (epoch - 1) * epoch_length + 1;
    end_sample = epoch * epoch_length;
    
    % Get the time vector for this epoch
    epoch_time = time(start_sample:end_sample);
    
    % Get the EEG data for this epoch
    epoch_data = new_EEG_data(start_sample:end_sample, chosen_channel);
    
    % Get the predicted label for this epoch
    epoch_label = new_predicted_labels(epoch);
    
    % Plot this epoch with the color corresponding to its label
    plot(epoch_time, epoch_data, colors(epoch_label + 1)); % +1 because MATLAB indices start at 1
    hold on;
end

% Add labels and title
xlabel('Time (s)');
ylabel('Amplitude');
title('EEG Data with Predicted Labels');
legend('Not-Blinking', 'Blinking');





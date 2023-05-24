clc; clear all; close all;
load('EEG_Data_Alternating_finger_press.mat')
EEG_data = y(2:end, 2500:end)';
sampling_rate = 250;
n_samples = size(EEG_data, 1);
time = linspace(0, n_samples/sampling_rate, n_samples);

filtered_EEG = bandpass_filter_8ch(EEG_data);
figure()
plot(y(1,2500:end), mean(filtered_EEG(),2).')

% Extract epochs
epoch_length = 5 * sampling_rate;
num_epochs = floor(n_samples / epoch_length);

roi_epochs = [];
roi_labels = [];
in=[];
% Loop over epochs
for epoch = 1:num_epochs
    % Get the current cycle and phase within the cycle
    cycle = floor((epoch - 1) / 4);
    phase = mod(epoch - 1, 4);
    if phase == 1 || phase == 3
        start_sample = (epoch - 1) * epoch_length + 1;
        end_sample = epoch * epoch_length;
        MIN = min(filtered_EEG(start_sample:end_sample, :), [], 2); %Get the minimum value per channel skipping the 1st second (I geuess avoids getting noise instead of data) 
        MAX = max(filtered_EEG(start_sample:end_sample, :), [], 2);
        
        %Amplitude restriction
        if max(MAX-MIN)>70
            in = [in;epoch]; %Count how many epochs passed the condition = bad data
       
        else
            roi_epochs = [roi_epochs; filtered_EEG(start_sample:end_sample, :)];
            if phase == 3
                roi_labels = [roi_labels; 1]; % Finger press
            else
                roi_labels = [roi_labels; 0]; % No finger press
            end
        end
    end   
end



labels = roi_labels;
roi_epochs = mean(roi_epochs,2);

% Choose one EEG channel to display (for example, the first one)
chosen_channel = 1;

% Define colors for each class
colors = ['r', 'b']; % For example, 'b' for mrcp, 'r' for noise

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
legend('Noise', 'MRCP');


% Calculate the number of channels
num_channels = size(roi_epochs, 2);

% Initialize feature matrix
features = zeros(num_interesting_epochs, num_channels * 7);

% Extract features from each epoch (PN, BP1, BP1 slope BP1-PN, slope BP2-PN, mean, variance)
for epoch = 1:num_interesting_epochs
    % Get the start and end sample for this epoch
    start_sample = (epoch - 1) * epoch_length + 1;
    end_sample = epoch * epoch_length;
    
    % Get the EEG data for this epoch
    epoch_data = roi_epochs(start_sample:end_sample, :);

    %Get the window with higher probability to contain an MRCP
    centrum = floor((end_sample-start_sample)/2);
    epoch_centrum = epoch_data(centrum-250:centrum+500,:);
    
    % Calculate mean and variance for the defined window
    mean_features = mean(epoch_centrum);
    var_features = var(epoch_centrum);

    %Get PN value and point
    [b, min_index] = min(epoch_centrum,[],'all');
    [min_row, ~] = ind2sub(size(epoch_centrum), min_index);    
    PN = epoch_data(centrum-250+min_row,:);
    PN_point=centrum-250+min_row;

    %Get BP1
    if PN_point<500 %If the minimum is before second 0 in the epoch
        if PN_point ==375 %If the minimum is at second -1,5 in the epoch
            epoch_BP1 = epoch_data(1:PN_point,:);
            [b, max_index] = max(epoch_BP1,[],'all');
            [max_row, ~] = ind2sub(size(epoch_BP1), max_index);
            BP1 = epoch_data(PN_point+max_row,:);
        else
            epoch_BP1 = epoch_data(1:PN_point-375,:);
            [b, max_index] = max(epoch_BP1,[],'all');
            [max_row, ~] = ind2sub(size(epoch_BP1), max_index);
            BP1 = epoch_data(PN_point-375+max_row,:);
        end
    else
        epoch_BP1 = epoch_data(PN_point-500:PN_point-375,:);
        [b, max_index] = max(epoch_BP1,[],'all');
        [max_row, ~] = ind2sub(size(epoch_BP1), max_index);
        BP1 = epoch_data(PN_point-500+max_row,:);
    end
    
    %Calculate the slope betweem BP1 and PN
    slope_BP1 = (PN-BP1)/(PN_point-max_row);

    %Get BP2
    epoch_BP2 = epoch_data(PN_point-175:PN_point-75,:);
    lower_limit = -5;
    upper_limit = -2.5;
    % Calculate the number of values within the range for each row
    num_values_within_range = sum(epoch_BP2 >= lower_limit & epoch_BP2 <= upper_limit, 2);
    % Find the row index with the maximum number of values within the range
    [max_values, max_index_BP2] = max(num_values_within_range);
    BP2 = epoch_data(PN_point-175+max_index_BP2,:);
    
    %Calculate the slope between BP2 and PN
    slope_BP2 = (PN-BP2)/(PN_point-max_index_BP2);
   
    % Add these features to our feature matrix
    features(epoch, :) = [mean_features, var_features, PN, BP1, BP2, slope_BP1, slope_BP2];
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


%% Test
% Load new data
eeg13 = load('EEG_Data_4_u.mat');
new_EEG_data = eeg13.y(2:end, 2500:end)';
% Preprocess new data (filtering)
new_filtered_EEG =  bandpass_filter_8ch(new_EEG_data);

% Extract epochs from new data
n_samples_new = size(new_EEG_data, 1);
num_epochs_new = floor(n_samples_new / epoch_length);
new_epochs = [];
time = linspace(0, n_samples_new/sampling_rate, n_samples_new);
for epoch = 1:num_epochs_new
    start_sample = (epoch - 1) * epoch_length + 1;
    end_sample = epoch * epoch_length;
    new_epochs= [new_epochs; new_filtered_EEG(start_sample:end_sample, :)];
end
new_epochs = mean(new_epochs,2);

% Extract features from new epochs
new_features = zeros(num_epochs_new, 1 * 7);
for epoch = 1:num_epochs_new
     % Get the start and end sample for this epoch
    start_sample = (epoch - 1) * epoch_length + 1;
    end_sample = epoch * epoch_length;
    
    % Get the EEG data for this epoch
    epoch_data = new_epochs(start_sample:end_sample, :);
    centrum = floor((end_sample-start_sample)/2);
    epoch_centrum = epoch_data(centrum-250:centrum+500,:);
    % Calculate mean and variance
    mean_features = mean(epoch_centrum);
    var_features = var(epoch_centrum);

    %Calculate PN
    [b, min_index] = min(epoch_centrum,[],'all');
    [min_row, ~] = ind2sub(size(epoch_centrum), min_index); 
    PN = epoch_data(centrum-250+min_row,:);
    PN_point=centrum-250+min_row;

    %Calculate BP1
    if PN_point<500
        if PN_point ==375
            epoch_BP1 = epoch_data(1:PN_point,:);
        else
            epoch_BP1 = epoch_data(1:PN_point-375,:);
        end
    else
        epoch_BP1 = epoch_data(PN_point-500:PN_point-375,:);
    end

    [b, max_index] = max(epoch_BP1,[],'all');
    [max_row, ~] = ind2sub(size(epoch_BP1), max_index);
    BP1 = epoch_data(PN_point-250+max_row,:);
    
    %Calculate slope between BP1 and PN
    slope_BP1 = (PN-BP1)/(PN_point-max_row);
    
    %Calculate BP2
    epoch_BP2 = epoch_data(PN_point-175:PN_point-75,:);
    lower_limit = -5;
    upper_limit = -2.5;
    % Calculate the number of values within the range for each row
    num_values_within_range = sum(epoch_BP2 >= lower_limit & epoch_BP2 <= upper_limit, 2);
    
    % Find the row index with the maximum number of values within the range
    [max_values, max_index_BP2] = max(num_values_within_range);
    BP2 = epoch_data(PN_point-175+max_index_BP2,:);
    
    %Calculate the slope between BP2 and PN
    slope_BP2 = (PN-BP2)/(PN_point-max_index_BP2);
    
    % Add these features to our feature matrix
    new_features(epoch, :) = [mean_features, var_features, PN, BP1, BP2, slope_BP1, slope_BP2];

end

% Predict labels for new data using the trained LDA classifier
new_predicted_labels = predict(lda, new_features);

legend_data = [];

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
    plot(epoch_time, epoch_data, 'Color',colors(epoch_label + 1)); % +1 because MATLAB indices start at 1
    hold on;
    % Store data for legend
    if ~ismember(epoch_label, legend_data)
        legend_data = [legend_data, epoch_label];
    end
end

% Add labels and title
xlabel('Time (s)');
ylabel('Amplitude');
title('EEG Data with Predicted Labels');
% Create legend
legend_str = {'No movement', 'Movement'};
legend(legend_str(legend_data + 1));






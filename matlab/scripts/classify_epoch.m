function label = classify_epoch(data)
    fs = 250;
    low_cutoff = 1;
    high_cutoff = 30;

    % Apply band-pass filter
    [b, a] = butter(2, [low_cutoff, high_cutoff] / (fs / 2), 'bandpass');
    filtered_data = filtfilt(b, a, data);
    
    % Extract features
    mean_features = mean(filtered_data, 1);
    var_features = var(filtered_data, 0, 1);
    kurtosis_features = kurtosis(filtered_data, 1, 1);
    features = [mean_features, var_features, kurtosis_features];

    % Load trained LDA classifier
    load('lda.mat', 'lda');
    
    % Classify the window
    label = predict(lda, features);
end


clc; clear all; close all;
load('EEG_Data_4_u.mat')
load('Time_Data_4_u.mat')

sampling_rate = 250;
EEG = bandpass_filter_8ch(y(2:end,:).');
%N = size(y, 2);
Nch = size(EEG, 2);
epochs = zeros(Nch, 250*4+1, 1);
valid_segments = 0; 

figure
subplot(4,1,1)
hold on;
labels = zeros(size(EEG,1),1);
for i = 1:size(simTimeData,1)
    flag = (10*i+7)*sampling_rate;
    labels(flag-2*sampling_rate:flag+2*sampling_rate) = 1;
    e =  EEG(flag-2*sampling_rate:flag+2*sampling_rate,:).';
    MIN = min(e(:,sampling_rate:3*sampling_rate), [], 2);
    MAX = max(e(:,sampling_rate:3*sampling_rate), [], 2);
    if max(MAX-MIN)>120
        plot(mean(e.', 2))
        xlabel('Time (s)')
        ylabel('Amplitude (uV)')
        title('Discarded epochs')
    else
        valid_segments = valid_segments+1; 
        epochs(:,:,valid_segments)=e;
    end
    
end

% Convert binary labels to categorical labels required for lda
labels = categorical(labels, [0, 1], {'no movement', 'movement'});


subplot(4,1,2)
t = -2:1/sampling_rate:2;
X = mean(epochs,3);
hold on
for n =1:Nch
    plot(t, X(n,:))
end
xlabel('Time (s)')
ylabel('Amplitude (uV)')
title('??')

subplot(4,1,3)
X = mean(epochs,1);
hold on
for n =1:valid_segments
    plot(t, X(1,:,n))
end
xlabel('Time (s)')
ylabel('Amplitude (uV)')
title('??')

subplot(4,1,4)
X = mean(epochs,3);
plot(t, mean(X,1));
xlabel('Time (s)')
ylabel('Amplitude (uV)')
title('Mean of all epochs')


figure; % create new figure for plotting
t = -2:1/sampling_rate:2; % time vector for plotting
for i = 1:Nch
subplot(4,2,i)
plot(t, squeeze(epochs(i,:,:)))
xlabel('Time (s)')
ylabel('Amplitude (uV)')
title(sprintf('Channel %d', i))
end

%%% Extract features


% mean_amp = mean(X, 2); % mean amplitude
% std_amp = std(X, [], 2); % standard deviation of amplitude
% [~, ind] = min(X, [], 2); % position of minimum amplitude
% min_amp = min(X, [], 2); % minimum amplitude
% slope = zeros(Nch, 1);
% 
% for i = 1:Nch
%     p = polyfit(t, X(i,:), 1);
%     slope(i) = p(1); % slope of amplitude
% end
% 
% thresh_duration = zeros(Nch, 1);
% for i = 1:Nch
%     % Count duration below threshold
%     threshold = -2; 
%     below_thresh = X(i,:) < threshold;
%     diff_thresh = diff(below_thresh);
%     starts = find(diff_thresh == 1);
%     stops = find(diff_thresh == -1);
%     if below_thresh(1)
%         starts = [1, starts];
%     end
%     if below_thresh(end)
%         stops = [stops, length(X(i,:))];
%     end
%     durations = stops - starts;
%     thresh_duration(i) = sum(durations(durations > 0)); % duration below threshold
% end


% Extract mean amplitude across all channels
mean_amplitude = mean(EEG, 2);

% Extract standard deviation of amplitude across all channels
std_amplitude = std(EEG, [], 2);

% Extract position of minimum amplitude across all channels
[min_amplitude, min_index] = min(EEG, [], 2);

% Extract minimum amplitude across all channels
min_amplitude = min(EEG, [], 2);



% Create feature matrix
feature_matrix = [mean_amplitude, std_amplitude, min_index, min_amplitude];



% Extract features and labels
X = feature_matrix;
Y = labels;

% Split the data into training and testing sets
[train_idx, test_idx] = crossvalind('HoldOut', length(Y), 0.3);
X_train = X(train_idx, :);
Y_train = Y(train_idx);
X_test = X(test_idx, :);
Y_test = Y(test_idx);

% Normalize the data
X_train = zscore(X_train);
X_test = zscore(X_test);

% Train an LDA classifier
lda = fitcdiscr(X_train, Y_train, 'DiscrimType', 'linear');

% Predict the labels for the test set
YTestPred = predict(lda, X_test);

% Evaluate the performance of the classifier
accuracy = mean(YTestPred == Y_test);
confusionMatrix = confusionmat(Y_test, YTestPred);

disp(['Accuracy = ' num2str(accuracy)]);
disp('Confusion Matrix:');
disp(confusionMatrix);


function [EEG] = bandpass_filter_8ch(eeg_data)
N_ch=size(eeg_data,2);
fsamp = 250; 
f_low = 3;
f_high = 0.1;
order = 2;

% bandpass EEG filter
Wn = [f_high, f_low]/fsamp*2;
[b,a]=butter(order,Wn,'bandpass');

for i=1:N_ch
    eeg_data(:,i)=transpose(filtfilt(b,a,eeg_data(:,i)));
end

% Notch filter
 Wn = [48 52]/fsamp*2;                % Cutoff frequencies
[bn,an] = butter(2,Wn,'stop');        % Calculate filter coefficients
for i=1:N_ch
    EEG(:,i)=transpose(filtfilt(bn,an,eeg_data(:,i)));
end

end
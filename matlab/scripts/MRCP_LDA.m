clc; clear all; close all;
load('EEG_Data_4_u.mat')
load('Time_Data_4_u.mat')

sampling_rate = 250;
EEG = bandpass_filter_8ch(y(2:end,:).');
N = floor(size(EEG, 1)/(sampling_rate*10)-1);
Nch = size(EEG, 2);
epochs = zeros(Nch, 250*4+1, 1);
valid_segments = 0; 

figure
subplot(4,1,1)
hold on;
labels = zeros(size(EEG,1),1);
for i = 1:N
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




% Extract features and labels
window_seconds = 4;
overlap_seconds = 1;
threshold = -2;
[X, Y] = extract_features(EEG, labels, sampling_rate, window_seconds, overlap_seconds, threshold);


% Split the data into training and testing sets
cv = cvpartition(size(X,1),'HoldOut',0.3);
idxTrain = training(cv); % Indices of the training set
idxTest = test(cv); % Indices of the testing set

% Split the features and labels into training and testing sets
X_train = X(idxTrain,:);
Y_train = Y(idxTrain);
X_test = X(idxTest,:);
Y_test = Y(idxTest);

% Train an LDA classifier
lda = fitcdiscr(X_train, Y_train);

% Predict labels
Y_pred = predict(lda, X_test);


% Evaluate the performance of the classifier
confusion_matrix = confusionmat(Y_test, Y_pred);

% Compute accuracy
accuracy = sum(diag(confusion_matrix)) / sum(confusion_matrix(:));

disp(['Accuracy = ' num2str(accuracy)]);
disp('Confusion Matrix:');
disp(confusion_matrix);



%%% Loading new dataset

new_EEG = load('EEG_Data_3_u.mat');
new_EEG = new_EEG.y;

new_EEG = bandpass_filter_8ch(new_EEG(2:end,:).');

[new_X, ~] = extract_features(new_EEG, 'None', sampling_rate, window_seconds, overlap_seconds, threshold);


new_Y_pred = predict(lda, new_X);
figure;
plot(new_Y_pred)




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

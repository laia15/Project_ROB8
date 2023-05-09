clc; clear all; close all; 
load('C:\Users\laiav\Documents\EEG project\Matlab data\After split/data_wet_electrodes/EEG_Data_12_unfiltered.mat')

fs = 250; %Sampling frequency
EEG = bandpass_filter_8ch(y(2:end,:).'); %EEG raw data that goes through the filter
Nch = size(EEG, 2); %number of channels
epochs = zeros(Nch, 250*4+1, 1); %As many rows as channels, columns as data points per epoch (in this case
%we want 4 seconds per epoch so 250*4 and +1 column extra
ii = 0;

%plot the mean of all channels per time
figure
hold on; 
in = 0;
out = 0;
for i = 1:11  %for each epoch (in the data set 12 unfiltered there are 11 movements)
    flag = (10*i+7)*fs;  %Get the movement index knowing the time (17,27,37...)
    e =  EEG(flag-2*fs:flag+2*fs,:).'; %Extract the data 2s before and 2s after movement
    MIN = min(e(:,fs:3*fs), [], 2); %Get the minimum value per channel skipping the 1st second (I geuess avoids getting noise instead of data) 
    MAX = max(e(:,fs:3*fs), [], 2); %Get the maximum value per channel
    if max(MAX-MIN)>120 %Checks if the amplitud is higher than a threshold (look for references to the number)
        in = in + 1; %Count how many epochs passed the condition = bad data
        plot(mean(e.', 2)) %Plot the mean per row, so the mean of all channels because the matrix is transposed. It is plotted the data points in x direction and the mean in y direction
    else
        ii = ii+1; %Next epoch
        out = out + 1; %Count how many epochs did not pass the condition = good data
        epochs(:,:,ii)=e; %Adds the new epoch to the channelsxdata matrix in a third direction
    end
end

%Mean  of all epochs per channel
figure; 
t = -2:1/fs:2; %Time vector from -2 to 2 s (0 is the movement time)
X = mean(epochs,3); %Mean of all epochs per channel
hold on
for n =1:Nch %Plot the data per channel respect to the time
    plot(t, X(n,:))
end

%Mean of all channels per epoch
figure()
X = mean(epochs,1);
hold on
for n =1:ii
    plot(t, X(1,:,n))
end

%Mean of all epochs and all channels depending on time
figure
X = mean(epochs,3);
plot(t, mean(X,1)); 



%Use alignsignals to get a better result
figure
X = mean(epochs,1);
ref = X(:,:,1);
for i=1:size(X, 3)
    [x_aligned, y_aligned] = alignsignals(x, y);
end





%% Filtering function
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
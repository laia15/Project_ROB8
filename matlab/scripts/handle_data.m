%%IMPORT AND FILTER DATA
clc; clear all; close all; 
load('C:\Users\laiav\Documents\EEG project\Matlab data\After split/teacher/EEG_Data_3_u.mat')

fs = 250; %Sampling frequency
EEG = bandpass_filter_8ch(y(2:end,:).'); %EEG raw data that goes through the filter
Nch = size(EEG, 2); %number of channels
data = EEG.';
time = y(1,:);

%%EXTRACT EPOCHS
epochs = extract_epochs(data,time);

%%DISCARD EPOCHS
figure
hold on; 
accepted = 0;
discarded = [];
f_epochs = epochs;
for i = 1:size(epochs,3)  %for each epoch (in the data set 12 unfiltered there are 11 movements)
    MIN = min(epochs(:,1.5*fs:end,i), [], 2); %Get the minimum value per channel skipping the 1st second (I geuess avoids getting noise instead of data) 
    MAX = max(epochs(:,1.5*fs:end,i), [], 2); %Get the maximum value per channel
    if max(MAX-MIN)>120 %Checks if the amplitud is higher than a threshold (look for references to the number)
        discarded = [discarded;i]; %Count how many epochs passed the condition = bad data
        X = mean(epochs(:,:,1),1);
        first_part = f_epochs(1:end,1:end,1:i-1);
        second_part = f_epochs(1:end,1:end,i+1:end);
        f_epochs = cat(3,first_part,second_part);  
        plot(X') %Plot the mean per row, so the mean of all channels because the matrix is transposed. It is plotted the data points in x direction and the mean in y direction
    else
        i = i+1; %Next epoch
        accepted = accepted + 1; %Count how many epochs did not pass the condition = good data
       
    end
end


%%PLOT EACH EPOCH (ALL CHANNELS)
fs=250;
epochs = f_epochs;
time_plot = -2:1/fs:2;
num_plots = size(epochs,3);
rows = 4;  % Number of rows in the subplot grid
cols = ceil(num_plots/rows);  % Number of columns in the subplot grid
for i = 1:num_plots
    subplot(rows, cols, i);
    plot(time_plot,epochs(:,:,i))
    hold on
    xline(0, 'r', 'LineWidth', 1); %vertical line at the movement time
    hold off
    title(sprintf('Epoch %d', i));  % Add a title to each subplot
end
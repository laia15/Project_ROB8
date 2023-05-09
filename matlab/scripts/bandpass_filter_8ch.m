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
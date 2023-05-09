function [epochs] = extract_epochs(data,time)
    load("C:\Users\laiav\Documents\EEG project\Matlab data\After split\teacher\Time_Data_3_u.mat");
    index  =simTimeData; %Consider that the first 10 seconds have been deleted
    low_index = [];
    high_index = [];
    for row = 1:(length(index))
        low_indicator = index(row)-2; %Take 2s before movement
        high_indicator = index(row)+2; %Take 2s after input
        % Find closest value
        minLDiff = min(abs(time - low_indicator));
        low_value = time(abs(time - low_indicator) == minLDiff);
        low_index = [low_index,find(time(1,:)==low_value)];
        minHDiff = min(abs(time - high_indicator));
        high_value = time(abs(time - high_indicator) == minHDiff);
        high_index = [high_index,find(time(1,:)==high_value)];
        
    end
    
    window_data = [];
    e_size = size(data(1:8,low_index(1):high_index(1)),2);
    n_epochs = size(low_index,2);
    n_ch = 8;
    epochs = zeros(n_ch, e_size, n_epochs);
    for i = 1:length(low_index)
        window_data = data(1:8,low_index(i):high_index(i));
        epochs(:,:,i) = window_data;
    
    end

end

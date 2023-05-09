%Check if there is a file with the time of pressing indicating the full
%path
if exist("C:\Users\laiav\Documents\EEG project\Matlab data\After split\data_wet_electrodes\Time_Data_12.mat", 'file') == 2
    load("C:\Users\laiav\Documents\EEG project\Matlab data\After split\data_wet_electrodes\Time_Data_12.mat");
    index  =simTimeData - 10; %Consider that the first 10 seconds have been deleted
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
    window_time = [];
    window_data = [];
    
    for i = 1:length(low_index)
        window_data = data(1:8,low_index(i):high_index(i));
        epochs{i} = window_data;
    
    end
else
    trigger = []; %Use the visual input time as identifier for movement time
    for i=1:length(time)
        time_string = num2str(time(i));
        if contains(time_string,"7.004") %Extracts the seconds 7,17,27,37...
            trigger = [trigger,time(i)];
        end
    end
    
    
    low_index = [];
    high_index = [];
    for row = 1:(length(trigger))
        low_indicator = trigger(row);%Set the visual input as 0
        high_indicator = trigger(row)+2; %Take 2s after
    
        % Find closest value
        minLDiff = min(abs(time - low_indicator));
        low_value = time(abs(time - low_indicator) == minLDiff);
        low_index = [low_index,find(time(1,:)==low_value)];
        minHDiff = min(abs(time - high_indicator));
        high_value = time(abs(time - high_indicator) == minHDiff);
        high_index = [high_index,find(time(1,:)==high_value)];
    end
    
    
    window_time = [];
    window_data = [];
    for i = 1:length(low_index)
        window_data1 = data(1:5,low_index(i):high_index(i)); %It is divided in 2 so we can delete channels if they are too noisy
        window_data2 = data(6:8,low_index(i):high_index(i));
        window_data = [window_data1;window_data2];
        epochs{i} = window_data;

    end
end


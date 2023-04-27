% ROS initialization
rosinit;

% Create a publisher to send commands to the Python node
command_publisher = rospublisher('/eeg_commands', 'std_msgs/String');

% Create a ROS message for the commands
command_arm = rosmessage(command_publisher);

% Initialize the state variable
state = 'Startup';
disp(['Starting state machine in state: ', state]);

% Loop while the state machine is running
while true
    switch state
        case 'Startup'
            % Send the 'up' command
            command_arm.Data = 'up';
            send(command_publisher, command_arm);
            
            % Wait for a short period of time
            pause(2);
            
            % Send the 'ready' command
            command_arm.Data = 'ready';
            send(command_publisher, command_arm);
            
            % Wait for a short period of time
            pause(2);
            
            % Send the 'pick' command
            command_arm.Data = 'pick';
            send(command_publisher, command_arm);
            
            % Wait for a short period of time
            pause(2);
            
            % Send the 'close' command
            command_arm.Data = 'close';
            send(command_publisher, command_arm);
            
            % Wait for a short period of time
            pause(2);
            
            % Transition to the Wait state
            state = 'Wait';
            disp(['Transitioning to state: ', state]);
            
        case 'Wait'
            % Wait for a movement signal
            movement_detected = false;
            while ~movement_detected
                % Replace this line with code that listens for a "movement" signal and sets movement_detected accordingly
                % For demonstration purposes, we'll set movement_detected to true after a fixed delay
                pause(1);
                movement_detected = true;
            end
            
            % Transition to the Movement state
            state = 'Movement';
            disp(['Transitioning to state: ', state]);
            
        case 'Movement'
            % Loop through the positions 'up', 'pos1', 'pos2', and 'pos3'
            for i = 1:4
                % Send the current position command
                switch i
                    case 1
                        command_arm.Data = 'up';
                    case 2
                        command_arm.Data = 'pos1';
                    case 3
                        command_arm.Data = 'pos2';
                    case 4
                        command_arm.Data = 'pos3';
                end
                send(command_publisher, command_arm);
                
                % Wait for a short period of time
                pause(2);
                
                % Check for movement signal
                % Replace this line with code that listens for a "movement" signal and sets movement_detected accordingly
                % For demonstration purposes, we'll set movement_detected to true after a fixed delay
                pause(1);
                movement_detected = true;
                if movement_detected
                    % Transition to the Open state
                    state = 'Open';
                    disp(['Transitioning to state: ', state]);
                    break;
                end
            end
            
            if ~movement_detected
                % Start over from 'up'
                state = 'Movement';
            end
            
        case 'Open'
                    % Send the 'open' command
                    command_arm.Data = 'open';
                    send(command_publisher, command_arm);
                    
                    % Wait for a short period of time
                    pause(2);
                    
                    % Transition back to the Startup state
                    state = 'Startup';
                    disp(['Transitioning to state: ', state]);
                otherwise
                % Handle an invalid state
                disp(['Invalid state: ', state]);
                % Transition back to the Startup state
                state = 'Startup';
                disp(['Transitioning to state: ', state]);
    end
end

    % Clean up
    rosshutdown;
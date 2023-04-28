% ROS initialization
rosinit;

% Create a publisher to send commands to the Python node
command_publisher = rospublisher('/eeg_commands', 'std_msgs/String');

% Create a ROS message for the commands
command_arm = rosmessage(command_publisher);

% Send the 'up' command
command_arm.Data = 'arm';
send(command_publisher, command_arm);

% Wait for a short period of time
pause(0.5);

% Clean up
rosshutdown;
#!/usr/bin/env python3

import rospy
from std_msgs.msg import String, Float64

#[1.63, 3.8, 0.5, 1.4, 6, 2.3] ready to pick, open = 0.8

#[1.62, 4.035, 0.61, 1.4, 6.025, 2.0] potential pick position?

#[3.19, 3.4, 0.5, 1.4, 6.2, 1.6] wait position

#[3.19, 3.6, 0.85, 1.4, 6.2, 1.6] position 1
#[3.19, 3.65, 0.925, 1.4, 6.2, 1.6] position 2
#[3.19, 3.7, 1, 1.4, 6.2, 1.6] position 3
#[3.19, 3.75, 1.0725, 1.4, 6.2, 1.6] position 4
#[3.19, 3.8, 1.15, 1.4, 6.2, 1.6] position 5


def command_callback(msg):
    # Get the command string from MATLAB message
    command_string = msg.data

    # Choose the configuration depending on the MATLAB signal (in joint angles, radians)
    command_dict =     {'arm': [3.19, 3.4, 0.5, 1.4, 6.2, 1.6],
                        'open': [0.8],
                        'close': [0.95]}
    
    joint_values_list = command_dict.get(command_string, None)

    if joint_values_list is None:
        return

    if command_string == 'open' or command_string == 'close':
            publisher_finger1.publish(Float64(joint_values_list[0]))
            publisher_finger_tip1.publish(Float64(joint_values_list[0]))
            publisher_finger2.publish(Float64(joint_values_list[0]))
            publisher_finger_tip2.publish(Float64(joint_values_list[0]))
            #publisher_finger3.publish(Float64(joint_values_list[0]))
            #publisher_finger_tip3.publish(Float64(joint_values_list[0]))
    else:
        # Publish the command message to the Float64 topics
        publisher_joint1.publish(Float64(joint_values_list[0]))
        publisher_joint2.publish(Float64(joint_values_list[1]))
        publisher_joint3.publish(Float64(joint_values_list[2]))
        publisher_joint4.publish(Float64(joint_values_list[3]))
        publisher_joint5.publish(Float64(joint_values_list[4]))
        publisher_joint6.publish(Float64(joint_values_list[5]))
        print(" ")
        print("Arm moved to: ", joint_values_list)
        print(" ")





if __name__ == '__main__':
    # ROS initialization
    rospy.init_node('command_subscriber')
    
    # Create a subscriber to receive commands from the MATLAB node
    command_sub = rospy.Subscriber('/eeg_commands', String, command_callback)
    
    # Create a publisher to send commands to the system
    publisher_joint1 = rospy.Publisher('/j2n6s300/joint_1_position_controller/command', Float64, queue_size=10)
    publisher_joint2 = rospy.Publisher('/j2n6s300/joint_2_position_controller/command', Float64, queue_size=10)
    publisher_joint3 = rospy.Publisher('/j2n6s300/joint_3_position_controller/command', Float64, queue_size=10)
    publisher_joint4 = rospy.Publisher('/j2n6s300/joint_4_position_controller/command', Float64, queue_size=10)
    publisher_joint5 = rospy.Publisher('/j2n6s300/joint_5_position_controller/command', Float64, queue_size=10)
    publisher_joint6 = rospy.Publisher('/j2n6s300/joint_6_position_controller/command', Float64, queue_size=10)

    publisher_finger1 = rospy.Publisher('/j2n6s300/finger_1_position_controller/command', Float64, queue_size=10)
    publisher_finger_tip1 = rospy.Publisher('/j2n6s300/finger_tip_1_position_controller/command', Float64, queue_size=10)
    publisher_finger2 = rospy.Publisher('/j2n6s300/finger_2_position_controller/command', Float64, queue_size=10)
    publisher_finger_tip2 = rospy.Publisher('/j2n6s300/finger_tip_2_position_controller/command', Float64, queue_size=10)
    publisher_finger3 = rospy.Publisher('/j2n6s300/finger_3_position_controller/command', Float64, queue_size=10)
    publisher_finger_tip3 = rospy.Publisher('/j2n6s300/finger_tip_3_position_controller/command', Float64, queue_size=10)


    # Spin the node until it's shut down
    rospy.spin()
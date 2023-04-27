#!/usr/bin/env python3

import rospy
from std_msgs.msg import String, Float64

def command_callback(msg):
    # Get the command string from MATLAB message
    command_string = msg.data

    # Choose the configuration depending on the MATLAB signal (in joint angles, radians)
    command_dict =     {'pick': [3.2, 4.0, 1.05, 1.4, 6, 3.8],
                       'ready': [3.2, 3.8, 0.9, 1.4, 6, 3.8],
                        'stop': [0, 0, 0, 0, 0, 0],
                        'open': [0.1],
                        'close': [0.85]}
    
    joint_values_list = command_dict.get(command_string, None)

    if joint_values_list is None:
        return

    if command_string == 'open' or command_string == 'close':
            publisher_finger1.publish(Float64(joint_values_list[0]))
            publisher_finger_tip1.publish(Float64(joint_values_list[0]))
            publisher_finger2.publish(Float64(joint_values_list[0]))
            publisher_finger_tip2.publish(Float64(joint_values_list[0]))
            publisher_finger3.publish(Float64(joint_values_list[0]))
            publisher_finger_tip3.publish(Float64(joint_values_list[0]))
    else:
        # Publish the command message to the Float64 topics
        publisher_joint1.publish(Float64(joint_values_list[0]))
        publisher_joint2.publish(Float64(joint_values_list[1]))
        publisher_joint3.publish(Float64(joint_values_list[2]))
        publisher_joint4.publish(Float64(joint_values_list[3]))
        publisher_joint5.publish(Float64(joint_values_list[4]))
        publisher_joint6.publish(Float64(joint_values_list[5]))





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



    print(" ")
    print("          =========================================================")
    print("          ===                                                   ===")
    print("          ===              ROS INTERFACE AVAIABLE               ===")
    print("          ===                                                   ===")
    print("          =========================================================")
    print(" ")


    # Spin the node until it's shut down
    rospy.spin()
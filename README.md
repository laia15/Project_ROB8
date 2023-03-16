# Project_ROB8

Remember to pull changes from the github before submitting your own: `git pull`

To push your changes, first add them `git add /file` or if you want to add everything `git add .`
Then commit them `git commit -m "A relevant message"`
Then push to the remote repository (github) `git push origin main`

Remember to use `git status` to list all new or modified files that haven't been commited yet

# Matlab development
1. Detect if there is movement or not:
We extract the mean, standard deviation and variance from sections of data. https://www.youtube.com/watch?v=In_f4mwDnzk <br/>
"one_movement_detection" file (inside matlab folder) detects the part where there is movement when the data is divided in sections and there is only one movement. <br/>
Just need to load the data called "one_movement_detection_data.mat" and run the script.


## Useful links
  Gazebo materials list: http://wiki.ros.org/simulator_gazebo/Tutorials/ListOfMaterials <br/>
  Repository jaco arm xacro: https://github.com/Kinovarobotics/kinova-ros <br/>
  Object parameters: https://campus-rover.gitbook.io/lab-notebook/faq/bouncy-objects <br/>
  Reference connect4 game: https://www.amazon.com/Hasbro-A5640-Connect-4-Game/dp/B00D8STBHY

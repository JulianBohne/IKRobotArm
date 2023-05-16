# Robot Arm Thingy
An ad hoc inverse kinematics thing for robot arms.

WARNING: The code is not documented, but you can look at the pictures below for a glimpse of the capabilities.

## Usage
This was written in [Processing](https://processing.org) which makes it easy to draw something to the screen. The code should just run by opening any file from the RoboThingy folder in the Processing editor and pressing the play button. You can rotate the camera by holding the left mouse button and moving the mouse. You can zoom using the mouse wheel. Pressing 'p' will pause or unpause the simulation. When paused, you can use the right arrow key to skip forward a single frame. If you press 'd', the names of the joints will be shown next to them for debug purposes (they won't be rotated in a nice way though). You can press 'c' to clear the path that has been drawn by the robot arm.

## Here are some cool pics:
The graphs show the joint angles (made to look nice, not really practical because the scale keeps changing).
The bar on the right and the color of the path drawn by the arm indicate how large the error is.

The toolpath is randomly generated and the arm follows it. The 'tool' (red ball) at the end of the arm follows the path, but it's rotation is not restricted. This could be added in the future though.

![Test2](https://user-images.githubusercontent.com/57051885/205487631-2aec6be9-a0a7-4b1e-820c-a15d387c8ad1.gif)
![Screenshot 2022-12-02 194154](https://user-images.githubusercontent.com/57051885/205363880-c59deda6-6b38-4f8d-a5f5-558b0ecb00b7.png)
![Example](https://user-images.githubusercontent.com/57051885/195630308-ba640372-aaca-40e1-a069-3018957cde6a.png)
![Screenshot 2022-11-04 110908](https://user-images.githubusercontent.com/57051885/199947645-2cc91066-a194-4078-ae75-a7094f7be474.png)

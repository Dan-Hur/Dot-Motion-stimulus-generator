# Dot-Motion-stimulus-generator
A MATLAB program that creates "dot motion" stimuli. In these stimuli there are two groups of moving dots for witch the size, motion patterns and speed can be determined.
There are three possible motion patterns: translational, rotational and random. The translating dots move coherently in one (determinable) direction. Rotating dots move coherently clockwise or counterclockwise. Random dots move in a translational motion where each dot moves in a different (random) direction.
This code includes GUI for ease of use. After adjusting the parameters, you can export a video with the set parameters. you can choose the quality, length and type of video for export.

In order to run the program, open "motion_stimulus_generator.m" (notice the correct ) and run the code from MATLAB. the following interface should appear:

<img width="491" alt="Gui_example" src="https://user-images.githubusercontent.com/120125680/210794564-f51e1bf1-8abb-4bb8-bff3-868e656c876d.PNG">

The "Play" button will play an animation of the stimulus with the set parameters that are currently chosen.
The "Set Paramerters" button needs to be pressed affter changing either the motion pattern, number of dots, direction of motion or dot color, in order for the new parameters to be set. the "Dot size" and "Dot speed" sliders change the dots in real time.
The "Export Videos" button will prompt a series of questions for the waned format of the exported video, after which the video will be created and saved.

Here is an example for such a video:



https://user-images.githubusercontent.com/120125680/210796653-abc3c92e-33e4-4a2d-8339-b0bde6d6cec8.mp4


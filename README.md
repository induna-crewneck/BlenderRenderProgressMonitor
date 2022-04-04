# Blender Render Progress Monitor
A script I made to keep a better eye on the progress of blender renders. Especially when doing command line rendering this is a nice tool.

![Title](https://i.imgur.com/MngMXRl.png)

## Setup
In the file I specified where you have to enter what data. You'll need your Output folder, the number of frames that are being rendered and your file extension. The latter usually is PNG and is entered as such in the file. No need to change this unless you render in another format. The output folder path should not contain any spaces.

![SetupGuide](https://i.imgur.com/8yzSnWc.png)

Note: The screenshots used can be subject to future changes to either my script or blender. The basic elements should remain the same, though.

## Preview
[PreviewOnImgur](https://imgur.com/8oiKa7D)
As you can see it shows you prety much all the info you could want and *should* update itself within 5 seconds of a new render appearing in your target folder.

## Attributions
Code to calculate elapsed time was adapted from code by Antonio Perez Ayala aka [Aacini](https://stackoverflow.com/users/778560/aacini) in [this thread](https://stackoverflow.com/questions/51082845/calculate-a-duration-between-two-dates-dd-mm-yyyy-hhmmss-in-batch-file)

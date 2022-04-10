# Blender Render Progress Monitor
A script I made to keep a better eye on the progress of blender renders. Especially when doing command line rendering this is a nice tool.

![Title](https://i.imgur.com/R7ixkO9.png)

## Setup
In the file I specified where you have to enter what data. You'll need your Output folder, the number of frames that are being rendered and your file extension. The latter usually is PNG and is entered as such in the file. No need to change this unless you render in another format. The output folder path should not contain any spaces.

![SetupGuide](https://i.imgur.com/8yzSnWc.png)

Note: The screenshots used can be subject to future changes to either my script or blender. The basic elements should remain the same, though.

## Telegram
There is a version of the script available that will send a Telegram message to you notifying you of the completed render process.
To use this, you will have to create a Telegrambot or use one you have already created (as you will need the bot token) and you will need your own ID to send the message to. These two will be entered into the script the same way the blender info was.

As of version 3.2 the Telegram version is the main version. The non-Telegram version is a fork with the telegram code taken out but not separately tested.

## Preview
[PreviewOnImgur](https://imgur.com/a/Jeen0q2)
As you can see it shows you prety much all the info you could want and *should* update itself within 30 seconds of a new render appearing in your target folder until it is done

## Attributions
Code to calculate elapsed time was adapted from code by Antonio Perez Ayala aka [Aacini](https://stackoverflow.com/users/778560/aacini) in [this thread](https://stackoverflow.com/questions/51082845/calculate-a-duration-between-two-dates-dd-mm-yyyy-hhmmss-in-batch-file)

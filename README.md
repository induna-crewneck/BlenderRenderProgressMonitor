# Blender Render Progress Monitor
A little script I made to keep a better eye on the progress of blender renders. Especially when doing command line rendering this is a nice tool.

![Title](https://i.imgur.com/Uzxxo9R.jpg)

## Setup
In the file I specified where you have to enter what data. You'll need your Output folder, the number of frames that are being rendered and your file extension. The latter usually is PNG and is entered as such in the file. No need to change this unless you render in another format.

![RenderPath](https://i.imgur.com/1vD1jyk.png)

![Frames](https://i.imgur.com/VcschBe.png)

The screenshots below are of an old version. The highlighted parts are the same, just don't get confused if the rest changed.

## Preview
![](https://i.imgur.com/9sxTbBb.gif)

As you can see it shows you prety much all the info you could want and *should* update itself within 5 seconds of a new render appearing in your target folder.

## Disclaimer
Current version probably does not handle months very well so if you're starting in one month and rendering into another it will get janky, since the days passed are only calculated by the day number.
If you have an idea how to implement this properly please let me know :)

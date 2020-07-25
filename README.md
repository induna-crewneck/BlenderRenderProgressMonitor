# Blender Render Progress Monitor
A little script I made to keep a better eye on the progress of blender renders. Especially when doing command line rendering this is a nice tool.

![Title](https://i.imgur.com/5CHWyQ7.png)

## Setup
In the file I specified where you have to enter what data. You'll need your Output folder, the number of frames that are being rendered and the time at which it's going to be done.

![RenderPath](https://i.imgur.com/1vD1jyk.png)

![Frames](https://i.imgur.com/VcschBe.png)

For the time unfortunately I don't have a nice solution, yet. So you'll need to calculate that yourself.
Render a frame and check the time it took

![RenderTimeFrame](https://i.imgur.com/PAXLQtB.png)
.48 seconds in this case.

## Example
I'll show this with my current render for which I made the script as an example. I start the render and then open the script and enter my data.

Animation start is 1888, End is 2385 which brings us to 497 frames to render (after the first one, you'll see why in a moment).

By now the first frame is rendered and I can see that it took 2:27.10, so 147.10 seconds. 
```
497 frames * 147.1 seconds = 73108.7 seconds total render time
```
If you're good at math, calculate what that is in hours and minutes. If you're like me use [this site](https://www.tools4noobs.com/online_tools/seconds_to_hh_mm_ss/).
Anyhow I got 20h 18min 28.7s.

Now I go to my output folder and check the creation time of my first frame: 09:42.

The good news is we don't have to worry about days here (If you used the link above and got something with days you need to multiply the days with 24 and add them to the hours). In my case I just need to add my render time to the time of the first frame (I calculated with one frame less because the render time of the first frame isn't taken into account).

So 9:20 + 20:18 = 29.38 which is the theoretical finish time.

My script looks like this:
![ExampleScript](https://i.imgur.com/QQbzw9J.png)

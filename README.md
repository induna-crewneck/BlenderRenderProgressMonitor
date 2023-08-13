# Blender Render Progress Monitor
A script I made to keep a better eye on the progress of blender renders. Especially when doing command line rendering this is a nice tool.
The script monitors your rendered frames, calculates average render time for one frame, calculates when the render approximately will finish and (optionally) informs you via Telegram message once it is finished.

![Title](https://i.imgur.com/O1j11eH.png)

# Usage
Just open your Terminal / CMD / Console and run `python /Path/to/BRPM.py`. On most operating systems you can drag&drop, so you just need to write 'python' and drag the downloaded Python script behind it.
Now enter the info that is detailed below and you're done.

# Preparation
Firstly, you will need Python 3. If you don't have it, you can download it [here](https://www.python.org/downloads/).

## Telegram
The script has the abbility to send a Telegram message to you notifying you of the completed render process.
To use this, you will have to create a Telegrambot or use one you have already created (as you will need the bot token) and you will need your own ID to send the message to. These two will be entered into the script the same way the blender info was.
### Creating a Bot and obtaining the token
On Telegram, search for [@BotFather](https://t.me/botfather) and send `/newbot`. Follow the steps until you are sent your bot's token. It will look something like `4839574812:AAFD39kkdpWt3ywyRZergyOLMaJhac60qc`.
### Get your ChatID
Visit [https://api.telegram.org/botXXX:YYYYY/getUpdates](https://api.telegram.org/botXXX:YYYYY/getUpdates) (replace the XXX: YYYYY with your BOT HTTP API Token you just got from the Telegram BotFather)
Now through Telegram, send any message to the bot. Refresh the page and you should see something like this:
```
{"ok":true,"result":[{"update_id":123456789,
"message":{"message_id":62,"from":{"id":123456789,"is_bot":false,"first_name":"yourfirstname","username":"yourusername","language_code":"en"},"chat":{"id":YOURCHATID,"first_name":"yourfirstname","username":"yourusername","type":"private"},"date":1691939143,"text":"youtmessage"}}]}
```
Write down your chat ID (YOURCHATID).

## Render info
You only need a few pieces of info about your render to input into the script.
![Image](https://i.imgur.com/2e5KP7z.png)

# Advanced
## Command arguments
You can run this script with command line arguments. To do this, place the script inside your render target folder. Also create a txt-file named `telegramdata.txt` and write your telegram bot token and chat id inside. The file should look like this:
```
telegrambottoken = 4839574812:AAFD39kkdpWt3ywyRZergyOLMaJhac60qc
mytelegramid = 123456789
```
Now you need to CD into your target folder and append frame count and file format to the execution command. For example:
```
cd /Path/to/your/render/detination/
python BRPM.py 69 PNG
```
If you do not want to use the Telegram functionality, just don't create the txt-file.

"""
Blender Render Progress Monitor	v4.0 (20230813)
	-Rebuilt in Python 3

https://github.com/induna-crewneck/BlenderRenderProgressMonitor
"""

import re
import os
import sys
import fnmatch
import time
import datetime
from datetime import datetime as datetime2
import pathlib
import requests

# ==== UNIVERSAL VARIABLES ===============================================================
DEBUG = 0
ARGUMENTS = 0
waittime = 30
extensions = ["png","bmp","rgb","jpg","jp2","jpeg","tga","cin","dpx","exr","hdr","tif","webp"]

# ==== COMMAND LINE ARGUMENT PARSING =====================================================
# script needs to be placed inside the render target directory and run with this syntax:
# BRPM.py [debug (optional)][FRAMES][EXTENSION]
try:
	sysarg = sys.argv[1]
	if "debug" in sysarg:
		DEBUG = 1
		#print("DEBUG output enabled by user")
	if "help" in sysarg:
		print("\nInfo about program:		github.com/induna-crewneck/BlenderRenderProgressMonitor")
		print("To enable debug info output use 'debug'")
		print("To run via command line: Syntax:\n	BRPM.py [debug (optional)][FRAMES][EXTENSION] \n	eg. 'python BRPM.py 3600 png'")
		exit()
	if len(sys.argv) == 4:
		#print("Command line arguments detected")
		try:
			ARGUMENTS = 1
			if sys.argv[3] in extensions:
				extension = sys.argv[3]
				#print("	Valid file format:	"+extension)
				if int(sys.argv[2]) > 1:
					totalframes = int(sys.argv[2])
					#print("	Number of frames:	"+str(totalframes))
			else:
				print("	No valid file format found. Valid formats:\n	"+",".join(extensions))
		except Exception as e:
			ARGUMENTS = 0
			if DEBUG == 1: print("Error processing data from arguments:",e)
			exit()
	elif len(sys.argv) == 3:
		#print("Command line arguments detected")
		try:
			ARGUMENTS = 1
			if sys.argv[2] in extensions:
				extension = sys.argv[2]
				#print("	Valid file format:	"+extension)
				if int(sys.argv[1]) > 1:
					totalframes = int(sys.argv[1])
					#print("	Number of frames:	"+str(totalframes))
			else:
				print("	No valid file format found. Valid formats:\n	"+",".join(extensions))
		except Exception as e:
			ARGUMENTS = 0
			if DEBUG == 1: print("Error processing data from arguments:",e)
			exit()
	elif len(sys.argv) != 2:
		print("Invalid number of arguments. Examples for valid commands:\npython BPRM.py debug 360 PNG\npython BPRM.py 1200 JPG")
		exit()
	renderpath = os.getcwd()
except Exception as e:
	if DEBUG == 1: print("no arguments added to execution command "+e)

# ==== VARIABLES =========================================================================
if ARGUMENTS == 0:
	renderpath = input("Render target directory:	").strip()
	if os.path.exists(renderpath):
		print("	Directory found")
		if renderpath[-1:] == "/":
			renderpath = renderpath[:-1]
			if DEBUG == 1: print("		reformatted: "+renderpath)
	else:	
		print("	Directory not found")
		exit()
	try: totalframes = int(input("Number of frames:		"))
	except:
		print("	Wrong formatting")
		exit()
	extension = input("File format:			")
	if extension.lower() not in extensions:
		print("	Invalid file format")
		exit()

try:
	telegram = False
	telegramcheck = False
	f = open("telegramdata.txt", "r").read()
	if ARGUMENTS == 0: print("Telegram Data file found")
	telegrambottoken = re.findall("\d{8,}\:\w{30,}",f)
	telegramID = re.findall("\d{6,}$",f)
	try:
		telegrambottoken
		telegramID
		if len(telegrambottoken) > 0:
			if ARGUMENTS == 0: print("	Bot token and ID detected")
			telegram = True
			telegramcheck = True
		else:
			telegramcheck = False
			print("	Could not read Telegram Bot token and ID from file")
	except NameError:
			print("	Could not read Telegram Bot token and ID from file")
except Exception as e:
	if DEBUG == 1: print("	ERROR: "+str(e)[0:50].replace("\n"," "))
if telegram == False and ARGUMENTS == 0:
		telq = input("Do you want to enable Telegram notification on job completion? (y/n) ")
		if telq.lower() == "y":
			while telegramcheck is False:
				telegrambottoken = input("Telegram Bot Token:	")
				try:
					telegrambottoken = re.findall("\d{8,}\:\w{30,}",telegrambottoken)
					if len(telegrambottoken) > 0: botcheck = True
					else: botcheck = False
				except: botcheck = False
				if botcheck == True:
					telegramID = input("Telegram ID:		")
					try:
						telegramID = re.findall("\d{6,}$",telegramID)
						if len(telegramID) > 0: telegramcheck = True
						else: telegramcheck = False
					except:
						telegramcheck = False
						print("	Chat ID formatting seems wrong")
				else:
					print("	Bot Token formatting seems wrong")
					telegramcheck = False
		elif telq.lower() != "n":
			print("	Invalid answer")
			exit()

taggedrootdir = pathlib.Path(renderpath)

# ==== FUNCTIONS =========================================================================	
def find(pattern, path):
    result = []
    #for root, dirs, files in os.walk(path):
    for root, dirs, files in os.walk(path):
        for name in files:
            if fnmatch.fnmatch(name, pattern):
                result.append(os.path.join(root, name))
    return result

def header():
	if os.name == 'nt':_ = os.system('cls')
	else:_ = os.system('clear')
	if DEBUG == 1: print("======================= Blender Render Progress Monitor ===================DEBUG")
	else: print("======================= Blender Render Progress Monitor ========================")
	print("=========== github.com/induna-crewneck/BlenderRenderProgressMonitor ============\n")
	print("Path:		"+renderpath+"\n")

def pause():
	for i in range(int(waittime),0,-1):
		if waittime > 60:
			waittime2 = str(datetime.timedelta(seconds=int(i)))
			if waittime < 3600 :print("	Rechecking in "+waittime2[2:]+" (avg. frame render time)",end="\r")
		else: print("	Rechecking in "+str(i),end="\r")
		time.sleep(1)
	
def findfirst():
	oldestfile = str(min([f for f in taggedrootdir.resolve().glob('**/*.'+extension) if f.is_file()], key=os.path.getctime))
	oldesttime_unix = os.path.getmtime(oldestfile)
	#oldesttime = time.ctime(oldesttime_unix)
	oldesttime = datetime2.utcfromtimestamp(oldesttime_unix).strftime('%Y-%m-%d %H:%M:%S')
	return oldestfile.replace(renderpath+"/","").replace(renderpath+"\\",""),oldesttime_unix,oldesttime

def findlatest():
	newestfile = str(max([f for f in taggedrootdir.resolve().glob('**/*.'+extension) if f.is_file()], key=os.path.getctime))
	newesttime_unix = os.path.getmtime(newestfile)
	#newesttime = time.ctime(newesttime_unix)
	newesttime = datetime2.utcfromtimestamp(newesttime_unix).strftime('%Y-%m-%d %H:%M:%S')
	return newestfile.replace(renderpath+"/","").replace(renderpath+"\\",""),newesttime_unix,newesttime

def avgframetimecalc(oldesttime_unix,newesttime_unix,renderedframes):
	timepassed_unix = newesttime_unix-oldesttime_unix
	timepassed = str(datetime.timedelta(seconds=int(timepassed_unix)))
	avgframetime_unix = timepassed_unix/renderedframes
	avgframetime = str(datetime.timedelta(seconds=int(avgframetime_unix)))
	return timepassed,avgframetime,avgframetime_unix

def remaining(renderedframes,avgframetime_unix):
	currenttime_unix = int(time.time())
	remainingframes = totalframes-renderedframes
	remainingtime_unix = int(remainingframes*avgframetime_unix)
	remainingtime = str(datetime.timedelta(seconds=int(remainingtime_unix)))
	ETA_unix = currenttime_unix+remainingtime_unix
	ETA = datetime2.utcfromtimestamp(ETA_unix).strftime('%Y-%m-%d %H:%M:%S')
	return remainingtime,ETA

# ==== EXECUTION =========================================================================
header()
while len(find('*.'+extension, renderpath)) == 0:
	print("Waiting for first frame.")
	pause()

oldestfile,oldesttime_unix,oldesttime = findfirst()

while len(find('*.'+extension, renderpath)) < totalframes:
	newestfile,newesttime_unix,newesttime = findlatest()
	renderedframes = len(find('*.'+extension, renderpath))
	timepassed,avgframetime,avgframetime_unix = avgframetimecalc(oldesttime_unix,newesttime_unix,renderedframes)
	remainingtime,ETA = remaining(renderedframes,avgframetime_unix)
	percentage = round(renderedframes/totalframes*100,2)
	if renderedframes > 3 and avgframetime_unix > 30: waittime = int(avgframetime_unix)
	header()
	if len(oldestfile) > 35: print("First file:		"+oldesttime+"  "+oldestfile[0:32]+"...")
	else: print("First file:		"+oldesttime+"  "+oldestfile)
	if len(newestfile) > 35: print("Newest file:		"+newesttime+"  "+newestfile[0:32]+"...\n")
	else: print("Newest file:		"+newesttime+"  "+newestfile+"\n")
	print("Time passed:			"+timepassed)
	print("Average frame render time:	"+avgframetime)
	print("Approx. time left:		"+remainingtime)
	print("Estimated completion:		"+ETA+"\n")
	print("#"*(int(percentage/100*80))+"_"*int((80-(percentage)/100*80)))
	print(renderedframes,"/",totalframes,"frames rendered ("+str(percentage)+"%)")
	pause()

print("\nRender completed\n")

if telegram == True:
	telemsg = "Blender%20render%20has%20finished%20rendering%20"+str(renderedframes)+"%20frames%20in%20"+str(timepassed).replace(":","%3A")
	#telemsg = "test"
	URL = "https://api.telegram.org/bot"+''.join(telegrambottoken)+"/sendMessage?chat_id="+''.join(telegramID)+"&text="+telemsg
	s = requests.get(URL)
	if "200" in str(s): print("Telegram message sent")
	else: print("Telegram: ",s)
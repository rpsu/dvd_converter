# dvd_converter
Script to convert home DVDs to MPEG-4, OGG or WEBM. No DRM handling. 

This is a geek way to move old family history cinemas to something of more current technology without using any applications with bloated UI, ads or similar cruft. If you do not fee that geek, feel free to use any [DVD to WEBM conversion tool](https://lmgtfy.com/?q=DVD+to+webm+conversion+tool) (and pay for it in one way or the other).

This script is absolutely free to use, and comes with your money back -guarantee :) (ie. no guarantee whatsovever).

## Requirements
These instructions assume you are using OS X and do have ```ffmpeg``` -binary installed. If you are not sure, type this in your terminal (omit the ```$```):  
```$ which ffmpeg```  
and you should see something like this:  
```/usr/local/bin/ffmpeg```

If you do not see it, install it with [Homebrew](https://brew.sh/):  
```$ brew install ffmpeg```

If you are using Linux, check that you have ```ffmpeg``` installed. Any fairly recent version of ```ffmpeg``` provided by your package manager should do it.

If you're facing any issues, check the [Issue queue](https://github.com/rpsu/dvd_converter/issues) and create a new issue if needed.


## Usage

1. Copy the ```converter.sh``` to any location of your choosing.
1. Mount your DVD.  
**Example:** Assuming you have a DVD called "Family_vacation" you should have now a folder ```/Volumes/Family_vacation``` and a file  ```/Volumes/Family_vacation/VIDEO_TS/VIDEO_TS.VOB```.
1. Create a target folder inside you Home directory. 
**Example:** Create folder in ```~/Desktop/converted_videos```
1. Use the script. Source (-s, --source), destination (-d, --destination) and 
mode (-m, --mode) are required values. Optionally you may select the ```ffmpeg```
conversion process verbosity with -v or --verbosity (default 'error') flags,
and choose to blindly delete any existing target files with -o=1 (default  0). 
```$ bash converter.sh --source=SRC --destination=DEST --mode=MP4```  
**Example:** 
```$ bash converter.sh --source=Family_vacation --destination=Desktop/converted_videos --mode=MP4,WEBM```  
To  make sure to override any previously interrupted conversions:  
```$ bash converter.sh -s=Family_vacation -d=Desktop/converted_videos -m=WEBM -o=1 -v=info```  
To make conversion more verbose, set verbosity -parameter to a valid [ffmpeg -loglevel](https://www.ffmpeg.org/ffmpeg.html#Generic-options) -value, such as 'info' (defaults to 'error'):  
```$ bash converter.sh -s=Family_vacation -d=Desktop/converted_videos -m=MP4,WEBM,OGV -v=debug ```  

## Warning

Please note, that *converting* videos will take time and effort from your computer. As an example fairly recent MacBook laptop spent some 30 hours converting DVD (with mpeg2video) to WEBM  - converted track was approximately 22 minutes long. On the other hand "conversion" to MPEG-4 video is actually just a copy of the original DVD track, so it took around one minute.

## References

This script relies fully on [FFmpeg](https://www.ffmpeg.org) converter. It has a very useful [Documentation page](https://www.ffmpeg.org/ffmpeg.html). 

---

**NOTE:** This script does not handle DRM locked DVDs at all (feel free to try). Script is targeted for people willing to store old home DVDs (cinema, VHS) in more modern formats for example in USB sticks. However, as the [license](https://github.com/rpsu/dvd_converter/blob/master/LICENSE) is states, feel free to modify it to suit to you needs. 


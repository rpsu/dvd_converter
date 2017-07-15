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
1. Use the script:  
```$ bash converter.sh SRC DEST```  
**Example:** 
```$ bash converter.sh Family_vacation Desktop/converted_videos```  
or to make sure to override any previously interrupted conversions:
```$ bash converter.sh Family_vacation Desktop/converted_videos 1```  

## Warning

Please note, that *converting* videos will take time and effort from your computer. As an example fairly recent MacBook laptop spent some 30 hours converting DVD (with mpeg2video) to WEBM  - converted track was approximately 22 minutes long. On the other hand "conversion" to MPEG-4 video is actually just a copy of the original DVD track, so it took around one minute.

---

**NOTE:** This script does not handle DRM locked DVDs at all (feel free to try). Script is targeted for people willing to store old home DVDs (cinema, VHS) in more modern formats for example in USB sticks. However, as the [license](https://github.com/rpsu/dvd_converter/blob/master/LICENSE) is states, feel free to modify it to suit to you needs. 


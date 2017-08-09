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
2. Mount your DVD.  
**Example:** Assuming you have a DVD called "Family_vacation" you should have now a folder ```/Volumes/Family_vacation``` and a file ```/Volumes/Family_vacation/VIDEO_TS/VTS_01_1.VOB```.
3. Create a target folder inside you Home directory. 
**Example:** Create folder in ```~/Desktop/converted_videos```
4. Use the script. Source (-s, --source), destination (-d, --destination) and 
  mode (-m, --mode) are required values. Optionally you may select the ```ffmpeg```
  conversion process verbosity with -v or --verbosity (default is 'error') flags,
  and choose to blindly delete any existing target files with -o=1 (default is 0).  
  ```$ bash converter.sh --source=SRC --destination=DEST --mode=MP4```  

**Example:**  
Convert your _Family_vacation_ -DVD to both MP4 and WEBM video in one go:  
```$ bash converter.sh --source=Family_vacation --destination=Desktop/converted_videos --mode=MP4,WEBM```  

Make sure any previously existing destination files are removed by using **-o** -flag (--overwrite):  
```$ bash converter.sh -s=Family_vacation -d=Desktop/converted_videos -m=MP4,WEBM -o=1```  

Choose output quality (does not affect MP4 mode at all) by using **-bv** -flag. By default conversion tries to use 10M as a bitrate (equals "-bv=100"), which should not lower the WEBM and OGG video quality compared to the original noticeable (--bitrate-video). This example tries to use less disk space in the expense of video quality:  
```$ bash converter.sh -s=Family_vacation -d=Desktop/converted_videos -m=MP4,WEBM -o=1 -bv=10```  

To make conversion process more verbose, set **-v** -parameter to a valid [ffmpeg -loglevel](https://www.ffmpeg.org/ffmpeg.html#Generic-options) -value, such as 'info' (default is 'error'). Also convert to OGG along with MP4 and WEBM (--verbosity):  
```$ bash converter.sh -s=Family_vacation -d=Desktop/converted_videos -m=MP4,WEBM,OGG -v=debug -bv=100 ```  

## Warning

Please note, that *converting* videos will take time and effort from your computer. As an example fairly recent MacBook laptop spends some 5-30 hours converting DVD (with mpeg2video) to WEBM  - converted track was approximately 22 minutes long. Time spent depends heavily on end result compression - higher '-bv' -values compress and calculate less, and are faster with higher quality but bigger result file sizes.

On the other hand "conversion" to MPEG-4 video is actually just a copy of the original DVD track, so it takes just a couple of minutes usually.

## References

This script relies fully on [FFmpeg](https://www.ffmpeg.org) converter. It has a 
very useful [Documentation page](https://www.ffmpeg.org/ffmpeg.html). When you 
are at it take also look at the [encoding section in FFmpeg wiki](https://trac.ffmpeg.org/wiki#Encoding). **Some very good stuff, if you are in need of altering
the conversion details here.**

---

**NOTE:** This script does not handle DRM locked DVDs at all (feel free to try). Script is targeted for people willing to store old home DVDs (cinema, VHS) in more modern formats for example in USB sticks. However, as the [license](https://github.com/rpsu/dvd_converter/blob/master/LICENSE) is states, feel free to modify it to suit to you needs. 


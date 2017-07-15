#!/bin/bash
# 
# Author: Perttu Ehn, @ropsue
# Source: https://github.com/rpsu/dvd_converter
# License: GPLv3, @see file LICENSE for more information
# 
# = = = = = = =
# Change this to where ever you've mounted your DVD. This assumes
# also that you are using OS X, since the mounted DVD's are found
# under /Volumes directory.
src_dir="/Volumes/$1"
target_dir="$HOME/$2"
overwrite="$3"

# CONVERSION FLAGS. NOTE that you may convert DVD to different formats in a row.
MP4=0
WEBM=1
OGG=0

# Make sure we have at least 1st and 2nd arguments. 
# 3rd argument is optional, but must be 1 (numeric one) if present.
if [ ! -d "$src_dir" ]; then
  echo "Source dir '$src_dir' does not exists. Your 1st argument must be a folder inside /Volumes, for example Matrix for /Volumes/Matrix."
  exit 1
fi
if [ ! -d "$target_dir" ]; then
  echo "Target dir '$target_dir' does not exists. Your 2nd argument must be an existing folder inside your home directory, for example 'Desktop/convert' for /Volumes/$HOME/Desktop/convert."
  exit 1
fi
if [ ! -z "$overwrite" ] && [ "$overwrite" != "1" ]; then
  echo "3rd parameter must be '1' if present. It means you will" echo "override any previously converted videos. "
  echo "** Be careful if you are using it! **"
  exit 1
else
  if [ "$overwrite" == "1" ]; then
    echo 'You are going to destroy previously converted files,' 
    echo 'right - even if they would be fully converted already? If not, hit "CMD + C" RIGHT NOW (waiting 3 secs in case you regret your descision...)'
    sleep 3
    echo 'Continuing...'
fi

# Clean up all possible previously build tracks list files.
rm -f $target_dir/dvd_*_tracks_*.txt

# If set, remove old converted files.
if [ "$overwrite" == "1" ]; then 
  if [ "$MP4" == "1" ]; then
    rm -rf $target_dir/*.mp4 > /dev/null
  fi
  if [ "$WEBM" == "1" ]; then
    rm -rf $target_dir/*.webm > /dev/null
  fi
  if [ "$OGG" == "1" ]; then
    rm -rf $target_dir/*.ogv > /dev/null
  fi
fi

# for dvd in {1..9}; do
for dvd in 1; do
  echo "Working on DVD $dvd..."
  for track in {1..5}; do
    echo "Working on DVD $dvd track $track..."
    trackname="$target_dir/DVD_$(echo $dvd)_track_$(echo $track)"
    track_parts_list="$target_dir/dvd_$(echo $dvd)_tracks_$(echo $track).txt"
    echo "============================================="
    echo "Track $trackname"
    echo 
    echo "Looking for stuff with $src_dir/VIDEO_TS/VTS_0$(echo $track)_*.VOB"
    list=$(ls $src_dir/VIDEO_TS/VTS_0$(echo $track)_*.VOB)
    echo found: $list
    if [ -z "$list" ]
    then
      echo "$src_dir/VIDEO_TS/VTS_0$(echo $track)_*.VOB => nothing found" 
      sleep 3
    else
      for f in $list; do
        echo "Found track $f" 
        echo "file '$f'" >> $track_parts_list; 
      done
      sleep 3
    fi
    echo  "= = = = = ="
    echo  -n "Next the actual work, try with $track_parts_list ... "
    if [ -f "$track_parts_list" ] && [ -r "$track_parts_list" ] && [ -s "$track_parts_list" ]; then
      echo " -- Good to go!!"
      sleep 3
        if [ "$MP4" == "1" ]; then
          ### MPEG-4 ###
          # '-c copy' meand does not decode + encode (but just use the stream as 
          # it is), since it is not loseless conversion.
          if [ -f $trackname.mp4 ]; then
            echo "$trackname.mp4 exists already. Skipping..."
            echo "Please remove $trackname.mp4 if you wish to re-convert your DVD to this format, OR set 3rd script parameter to 1."
          else 
            echo "$trackname.mp4 not yet converted. Start working."
            ffmpeg -f concat -safe 0 -i "$track_parts_list" -c copy -b:v 800k -g 300 -bf 2 -an $trackname.mp4
          fi
        fi
        
        if [ "$WEBM" == "1" ]; then
          ### .WEBM -format (slow, becase of re-encoding) ###
          # vp8 videe codec, no audio ('-an') 
          # This will compress video a lot, 1Gb MPEG-2 video will become 150 MB 
          # (85 % of the original size!).
          if [ -f $trackname.webm ]; then
            echo "$trackname.webm exists already. Skipping..."
          else 
            echo "$trackname.webm not yet converted. Start working."
            ffmpeg -f concat -safe 0 -i "$track_parts_list" -c:v vp9 -an -b:v 1000k -crf 10 -strict -2 $trackname.webm
          fi
        fi
        
        if [ "$OGG" == "1" ]; then
          ###  .OGG -format (slow, becase of re-encoding) ###
          if [ -f $trackname.ogv ]; then
            echo "$trackname.ogv exists already. Skipping..."
          else 
            echo "$trackname.ogv not yet converted. Start working."
            ffmpeg -f concat -safe 0 -i "$track_parts_list" -an $trackname.ogv
          fi
        fi
    else 
      echo " -- oh crap, no tracks found to work with: DVD $dvd, track $track."
    fi
    echo "--------"
    echo 
  done
  echo "DVD $dvd converted, tracks combined into one."
  echo 
  echo 
  echo 
done

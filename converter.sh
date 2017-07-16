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
src_name="$1"
target_dir="$HOME/$2"
overwrite="$3"
verbosity="$4"

if [ -z $verbosity ]; then
  verbosity="error"
fi

# Output colors:
RED='\033[0;31m'
GRN='\033[0;32m'
YLLW='\033[1;33m'
NC='\033[0m' # No Color

START=$(date +%s)
# CONVERSION FLAGS. NOTE that you may convert DVD to different formats in a row.
MP4=1
WEBM=1
OGG=1

# Make sure we have 2 requiree arguments. 
if [ ! -d "$src_dir" ]; then
  echo -e "${RED}ERROR: Source dir '$src_dir' does not exists."
  echo "Your 1st argument must be a folder inside /Volumes, "
  echo "for example old_home_cine for a mounted DVD in /Volumes/old_home_cine."
  echo -e "${NC}"
  exit 1
fi

if [ ! -d "$target_dir" ]; then
  echo -e "${RED}ERROR: Target dir '$target_dir' does not exists."
  echo "Your 2nd argument must be an existing folder inside your home directory, for example 'Desktop/convert' for /Volumes/$HOME/Desktop/convert."
  echo -e "${NC}"
  exit 1
fi

# 3rd argument is optional, but must be 1 (numeric one) if present.
if [ ! -z "$overwrite" ] && [ "$overwrite" != "1" ] && [ "$overwrite" != "0" ]; then
  echo -e "${RED}ERROR: Parameter error."
  echo "3rd parameter must be '1' or '0' if present. Feel free to omit it."
  echo "'1' means you will override any previously converted videos."
  echo "${YLLW}** Be careful if you are using it! **${NC}"
  echo -e "${NC}"
  exit 1
else
  if [ "$overwrite" == "1" ]; then
    echo -e "${YLLW}** WARNING **${NC}"
    echo 'You are going to destroy previously converted files,' 
    echo 'right - even if they would be fully converted already?'
    echo 'If not, hit "CMD + C" RIGHT NOW (waiting 3 secs in case'
    echo 'you regret your decision...)'
    sleep 3
    echo 'Continuing...'
  fi
fi
# 4th argument is optional, but must match a valid "ffmpeg -loglevel" -value.
if [ $verbosity != 'quiet' ] && 
   [ $verbosity != 'panic' ] &&
   [ $verbosity != 'fatal' ] &&
   [ $verbosity != 'error' ] &&
   [ $verbosity != 'info' ] && 
   [ $verbosity != 'verbose' ] &&
   [ $verbosity != 'debug' ] &&
   [ $verbosity != 'trace' ]; then
  echo -e "${RED}ERROR: Verbosity level (4th argument) is not a valid value."
  echo "See 'man ffmpeg' and '-loglevel' -argument for valid values. "
  echo -e "${NC}"
  exit 1
fi

# Clean up all possible previously build tracks list files.
rm -f $target_dir/dvd_$(echo $src_name)_tracks_*.txt
rm -f $target_dir/dvd_$(echo $src_name).log

# If so requested, remove old converted files.
if [ "$overwrite" == "1" ]; then 
  if [ "$MP4" == "1" ]; then
    count=$(ls -lh $target_dir/*.mp4 | wc -l)
    echo "Removing $count x .mp4 files from $target_dir " | tee -a $target_dir/dvd_$(echo $src_name).log
    rm -rf $target_dir/*.mp4 > /dev/null
  fi
  if [ "$WEBM" == "1" ]; then
    count=$(ls -lh $target_dir/*.webm | wc -l)
    echo "Removing $count x .webm files from $target_dir "  | tee -a $target_dir/dvd_$(echo $src_name).log
    rm -rf $target_dir/*.webm > /dev/null
  fi
  if [ "$OGG" == "1" ]; then
    count=$(ls -lh $target_dir/*.ogv | wc -l)
    echo "Removing $count x .ogv files from $target_dir "  | tee -a $target_dir/dvd_$(echo $src_name).log
    rm -rf $target_dir/*.ogv > /dev/null
  fi
fi

# Let us just hope that DVDs may have max 100 tracks.
echo "============================================="
for track in {1..99}; do
  if [ ${#track} == 1 ]; then
    track=0$(echo $track)
  fi
  trackname="$target_dir/DVD_$(echo $src_name)_track_$(echo $track)"
  track_parts_list="$target_dir/dvd_$(echo $src_name)_tracks_$(echo $track).txt"
  list=$(ls $src_dir/VIDEO_TS/VTS_$(echo $track)_*.VOB 2>/dev/null )
  echo -n "Working on DVD $src_name track $track... " | tee -a $target_dir/dvd_$(echo $src_name).log
  if [ -z "$list" ]; then
    echo "Nothing in $src_dir/VIDEO_TS/VTS_$(echo $track)_*.VOB" | tee -a $target_dir/dvd_$(echo $src_name).log
  else
    echo  | tee -a $target_dir/dvd_$(echo $src_name).log
    for f in $list; do
      echo "Found track $f"  | tee -a $target_dir/dvd_$(echo $src_name).log
      echo "file '$f'" >> $track_parts_list; 
    done
  fi
  if [ -f "$track_parts_list" ] && [ -r "$track_parts_list" ] && [ -s "$track_parts_list" ]; then
    echo  "= = = = = =" | tee -a $target_dir/dvd_$(echo $src_name).log
    echo  "Next the actual conversion, working with track info in $track_parts_list ... " | tee -a $target_dir/dvd_$(echo $src_name).log
    sleep 3
    if [ "$MP4" == "1" ]; then
      ### MPEG-4 ###
      # '-c copy' means video isn't decoded & encode (but just used the 
      #  stream as it is), since it is not loseless conversion.
      if [ -f $trackname.mp4 ]; then
        echo "$trackname.mp4 exists already. Skipping..." | tee -a $target_dir/dvd_$(echo $src_name).log
        echo "Please remove $trackname.mp4 if you wish to re-convert your DVD to this format, OR set 3rd script parameter to 1."
        sleep 3
      else 
        echo "$trackname.mp4 not yet converted. Start working at $(date)." | tee -a $target_dir/dvd_$(echo $src_name).log
        cmd="ffmpeg -v $verbosity -hide_banner -f concat -safe 0 -i "$track_parts_list" -c copy -b:v 800k -b:a 128k -g 300 -bf 2  $trackname.mp4"
        echo $cmd | tee -a $target_dir/dvd_$(echo $src_name).log
        $cmd
        echo "$trackname.mp4 converted. Finished working at $(date)." | tee -a $target_dir/dvd_$(echo $src_name).log
      fi
    fi
    
    if [ "$WEBM" == "1" ]; then
      ### .WEBM -format (slow, becase of re-encoding) ###
      # vp8 videe codec, audio as MP3
      # This will compress video a lot, 1Gb MPEG-2 video will become 150 MB 
      # (85 % of the original size!).
      if [ -f $trackname.webm ]; then
        echo "$trackname.webm exists already. Skipping..." | tee -a $target_dir/dvd_$(echo $src_name).log
        echo "Please remove $trackname.webm if you wish to re-convert your DVD to this format, OR set 3rd script parameter to 1."
        sleep 3
      else 
        echo "$trackname.webm not yet converted. Start working at $(date)."  | tee -a $target_dir/dvd_$(echo $src_name).log
        # Convert vidos to WEBM. 
        cmd="ffmpeg -v $verbosity -hide_banner -f concat -safe 0 -i "$track_parts_list" -c:v vp9 -b:v 1000k -c:a libmp3lame -b:a 128k -crf 10 -strict -2 $trackname.webm"
        echo $cmd | tee -a $target_dir/dvd_$(echo $src_name).log
        $cmd
        echo "$trackname.webm converted. Finished working at $(date)." | tee -a $target_dir/dvd_$(echo $src_name).log
      fi
    fi
    
    if [ "$OGG" == "1" ]; then
      ###  .OGG -format (slow, becase of re-encoding) ###
      if [ -f $trackname.ogv ]; then
        echo "$trackname.ogv exists already. Skipping..." | tee -a $target_dir/dvd_$(echo $src_name).log
        echo "Please remove $trackname.ogv if you wish to re-convert your DVD to this format, OR set 3rd script parameter to 1."
        sleep 3
      else 
        echo "$trackname.ogv not yet converted. Start working at $(date)." | tee -a $target_dir/dvd_$(echo $src_name).log
        cmd="ffmpeg -v $verbosity -hide_banner -f concat -safe 0 -i "$track_parts_list" -c:v libvpx -crf 10 -b:v 1M -c:a libvorbis $trackname.ogv"
        echo $cmd | tee -a $target_dir/dvd_$(echo $src_name).log
        $cmd
        echo "$trackname.ogv converted. Finished working at $(date)." | tee -a $target_dir/dvd_$(echo $src_name).log
      fi
    fi
  fi
done

DURATION=$(( $(date +%s) - $START))

echo -e -n "${GRN}DVD $src_name converted.${NC} "
echo -e -n "Conversion took " | tee -a $target_dir/dvd_$(echo $src_name).log
printf '%dh:%dm:%ds\n' $(($DURATION/3600)) $(($DURATION%3600/60)) $(($DURATION%60)) | tee -a $target_dir/dvd_$(echo $src_name).log
echo "Finished at $(date)." | tee -a $target_dir/dvd_$(echo $src_name).log
echo 

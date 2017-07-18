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

START=$(date +%s)

# Output colors:
RED='\033[0;31m'
GRN='\033[0;32m'
YLLW='\033[1;33m'
NC='\033[0m' # No Color

# Parse Command Line Arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -s=*|--src=*)
      src="${1#*=}"
      src_dir="/Volumes/$src"
      ;;
    -d=*|--destination=*)
        dest="${1#*=}"
        destination="$HOME/$dest"
        ;;
    -m=*|--mode=*)
        MODE="${1#*=}"
        ;;
    -o=*|--overwrite=*)
        overwrite="${1#*=}"
        ;;
    -v=*|--verbosity=*)
        verbosity="${1#*=}"
        ;;
    *)
    echo "Error, invalid argument '$1'."
    exit 1
  esac
  shift
done

# Set default $verbosity value, if not set.
if [ -z $verbosity ]; then
  verbosity="error"
fi

# CONVERSION FLAGS. NOTE that you may convert DVD to different formats in a row.
# Split string to an array. Assume comma-separated list.
while [ "$MODE" ] ;do
  # Get the 1st comma separated item in the $MODE string. 
  ITEM=${MODE%%,*}
  # Use of 'declare' allows us to use dynamic variable names.
  declare $ITEM=1
  # Set new value for the $MODE, ie. drop the 1st value.
  if [ "$MODE" = "$ITEM" ]; then
     MODE='' 
  else 
    MODE="${MODE#*,}"
  fi
done

if [ -z $verbosity ]; then
  verbosity="error"
fi

# Make sure we have 2 requiree arguments. 
if [ ! -d "$src_dir" ]; then
  echo -e "${RED}ERROR: Source dir '$src_dir' does not exists."
  echo "Your 1st argument must be a folder inside /Volumes, "
  echo "for example old_home_cine for a mounted DVD in /Volumes/old_home_cine."
  echo -e "${NC}"
  exit 1
fi

if [ ! -d "$destination" ]; then
  echo -e "${RED}ERROR: Target dir '$destination' does not exists."
  echo "Your 2nd argument must be an existing folder inside your home directory, for example 'Desktop/convert' for /Volumes/$HOME/Desktop/convert."
  echo -e "${NC}"
  exit 1
fi

if [ -z $MP4 ] && [ -z $WEBM ] && [ -z $OGV ]; then
  echo "Error, value for --mode/-m is required."
  echo "Allowed values are MP4, WEBM and OGV. Multiple values can be separated "
  echo "with comma. "
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

# Clean up all possible previously build tracks list and log files.
rm -f $destination/dvd_$(echo $src)_tracks_*.txt
rm -f $destination/dvd_$(echo $src).log

# If so requested, remove old converted files.
if [ "$overwrite" == "1" ]; then
  if [ "$MP4" == "1" ]; then
    count=$(ls -lh $destination/*.mp4 | wc -l)
    echo "Remove $count x .mp4 files from $destination " | tee -a $destination/dvd_$(echo $src).log
    rm -rf $destination/*.mp4 > /dev/null
  fi
  if [ "$WEBM" == "1" ]; then
    count=$(ls -lh $destination/*.webm | wc -l)
    echo "Remove $count x .webm files from $destination "  | tee -a $destination/dvd_$(echo $src).log
    rm -rf $destination/*.webm > /dev/null
  fi
  if [ "$OGV" == "1" ]; then
    count=$(ls -lh $destination/*.ogv | wc -l)
    echo "Remove $count x .ogv files from $destination "  | tee -a $destination/dvd_$(echo $src).log
    rm -rf $destination/*.ogv > /dev/null
  fi
fi

# Let us just hope that DVDs may have max 100 tracks.
echo "============================================="
for track in {1..99}; do
  if [ ${#track} == 1 ]; then
    track=0$(echo $track)
  fi
  trackname="$destination/DVD_$(echo $src)_track_$(echo $track)"
  track_parts_list="$destination/dvd_$(echo $src)_tracks_$(echo $track).txt"
  list=$(ls $src_dir/VIDEO_TS/VTS_$(echo $track)_*.VOB 2>/dev/null )
  echo -n "Working on DVD $src track $track... " | tee -a $destination/dvd_$(echo $src).log
  if [ -z "$list" ]; then
    echo "Nothing in $src_dir/VIDEO_TS/VTS_$(echo $track)_*.VOB" | tee -a $destination/dvd_$(echo $src).log
  else
    echo  | tee -a $destination/dvd_$(echo $src).log
    for f in $list; do
      echo "Found track $f"  | tee -a $destination/dvd_$(echo $src).log
      echo "file '$f'" >> $track_parts_list; 
    done
  fi
  if [ -f "$track_parts_list" ] && [ -r "$track_parts_list" ] && [ -s "$track_parts_list" ]; then
    echo  "= = = = = =" | tee -a $destination/dvd_$(echo $src).log
    echo  "Next the actual conversion, working with track info in $track_parts_list ... " | tee -a $destination/dvd_$(echo $src).log
    sleep 3
    if [ "$MP4" == "1" ]; then
      ### MPEG-4 ###
      # '-c copy' means video isn't decoded & encode (but just used the 
      #  stream as it is), since it is not loseless conversion.
      if [ -f $trackname.mp4 ]; then
        echo "$trackname.mp4 exists already. Skipping..." | tee -a $destination/dvd_$(echo $src).log
        echo "Please remove $trackname.mp4 if you wish to re-convert your DVD to this format, OR set 3rd script parameter to 1."
        sleep 3
      else 
        echo "$trackname.mp4 not yet converted. Start working at $(date)." | tee -a $destination/dvd_$(echo $src).log
        cmd="ffmpeg -v $verbosity -hide_banner -f concat -safe 0 -i "$track_parts_list" -c copy -b:v 800k -b:a 128k -g 300 -bf 2  $trackname.mp4"
        echo $cmd | tee -a $destination/dvd_$(echo $src).log
        $cmd
        echo "$trackname.mp4 converted. Finished working at $(date)." | tee -a $destination/dvd_$(echo $src).log
      fi
    fi
    
    if [ "$WEBM" == "1" ]; then
      ### .WEBM -format (slow, becase of re-encoding) ###
      # vp8 videe codec, audio as MP3
      # This will compress video a lot, 1Gb MPEG-2 video will become 150 MB 
      # (85 % of the original size!).
      if [ -f $trackname.webm ]; then
        echo "$trackname.webm exists already. Skipping..." | tee -a $destination/dvd_$(echo $src).log
        echo "Please remove $trackname.webm if you wish to re-convert your DVD to this format, OR set 3rd script parameter to 1."
        sleep 3
      else 
        echo "$trackname.webm not yet converted. Start working at $(date)."  | tee -a $destination/dvd_$(echo $src).log
        # Convert vidos to WEBM. 
        cmd="ffmpeg -v $verbosity -hide_banner -f concat -safe 0 -i "$track_parts_list" -c:v vp9 -b:v 1000k -c:a libmp3lame -b:a 128k -crf 10 -strict -2 $trackname.webm"
        # SRC: http://diveintohtml5.info/video.html#webm-cli
        ffmpeg -pass 1 -passlogfile pr6.dv -threads 16  -keyint_min 0 -g 250 -skip_threshold 0 -qmin 1 -qmax 51 -i pr6.dv -vcodec libvpx -b 614400 -s 320x240 -aspect 4:3 -an -y NUL
        ffmpeg -pass 2 -passlogfile pr6.dv -threads 16  -keyint_min 0 -g 250 -skip_threshold 0 -qmin 1 -qmax 51 -i pr6.dv -vcodec libvpx -b 614400 -s 320x240 -aspect 4:3 -acodec libvorbis -y pr6.webm
        # used: 
        ffmpeg -v error -hide_banner -f concat -safe 0 -i /Users/PerttuEhn/Movies/DVD/1/dvd_nummi_dvd1_tracks_03.txt -pass 2 -passlogfile pr6.dv -threads 16  -keyint_min 0 -g 250 -skip_threshold 0 -qmin 1 -qmax 51  -c:v libvpx -v:b 614400 -s 720x576 -aspect 5:4 /Users/PerttuEhn/Movies/DVD/1/some-file.ogv
        ffmpeg -v error -hide_banner -f concat -safe 0 -i /Users/PerttuEhn/Movies/DVD/1/dvd_nummi_dvd1_tracks_03.txt -pass 1 -passlogfile pr6.dv -threads 16  -keyint_min 0 -g 250 -skip_threshold 0 -qmin 1 -qmax 51  -c:v libvpx -v:b 614400 -s 720x576 -aspect 5:4 /Users/PerttuEhn/Movies/DVD/1/some-file.ogv
        echo $cmd | tee -a $destination/dvd_$(echo $src).log
        $cmd
        echo "$trackname.webm converted. Finished working at $(date)." | tee -a $destination/dvd_$(echo $src).log
      fi
    fi
    
    if [ "$OGV" == "1" ]; then
      ###  .ogv -format (slow, becase of re-encoding) ###
      if [ -f $trackname.ogv ]; then
        echo "$trackname.ogv exists already. Skipping..." | tee -a $destination/dvd_$(echo $src).log
        echo "Please remove $trackname.ogv if you wish to re-convert your DVD to this format, OR set 3rd script parameter to 1."
        sleep 3
      else 
        echo "$trackname.ogv not yet converted. Start working at $(date)." | tee -a $destination/dvd_$(echo $src).log
        cmd="ffmpeg -v $verbosity -hide_banner -f concat -safe 0 -i "$track_parts_list" -c:v libvpx -crf 10 -b:v 1M -c:a libvorbis $trackname.ogv"
        echo $cmd | tee -a $destination/dvd_$(echo $src).log
        $cmd
        echo "$trackname.ogv converted. Finished working at $(date)." | tee -a $destination/dvd_$(echo $src).log
      fi
    fi
  fi
done

DURATION=$(( $(date +%s) - $START))

echo -e -n "${GRN}DVD $src converted.${NC} "
echo -e -n "Conversion took " | tee -a $destination/dvd_$(echo $src).log
printf '%dh:%dm:%ds\n' $(($DURATION/3600)) $(($DURATION%3600/60)) $(($DURATION%60)) | tee -a $destination/dvd_$(echo $src).log
echo "Finished at $(date)." | tee -a $destination/dvd_$(echo $src).log
echo 

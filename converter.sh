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
# Helpful partial string matching info found in
# https://stackoverflow.com/a/15988793
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


[ ! -d "$destination" ] &&   mkdir -p $destination >/dev/null

if [ ! -d "$destination" ]; then
  echo -e "${RED}ERROR: Target dir '$destination' did not valid, maybe it is a file?"
  echo -e "Creating the target dir seems to be failed.${NC}"
  exit 1
fi

if [ -z $MP4 ] && [ -z $WEBM ] && [ -z $OGV ]; then
  echo -e "${RED}Error, value for --mode/-m is required.${NC}"
  echo "Allowed values are MP4, WEBM and OGV. Multiple values can be separated "
  echo "with comma. "
  exit 1
fi
# 3rd argument is optional, but must be 1 (numeric one) if present.
if [ ! -z "$overwrite" ] && [ "$overwrite" != "1" ] && [ "$overwrite" != "0" ]; then
  echo -e "${RED}ERROR: Parameter error.${NC}"
  echo "3rd parameter must be '1' or '0' if present. Feel free to omit it."
  echo "'1' means you will override any previously converted videos."
  echo -e "${YLLW}** Be careful if you are using it! **${NC}"
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
  echo -e "${RED}ERROR: Verbosity level (4th argument) is not a valid value.${NC}"
  echo "See 'man ffmpeg' and '-loglevel' -argument for valid values. "
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
  trackname="$destination/$(echo $src)__trackno_$(echo $track)"
  track_parts_list="$trackname.track_fragments.txt"
  list=$(ls $src_dir/VIDEO_TS/VTS_$(echo $track)_*.VOB 2>/dev/null )
  [ ! -z $MP4 ] && CONVERSIONS=$(echo "$CONVERSIONS MP4,")
  [ ! -z $OGV ] && CONVERSIONS=$(echo "$CONVERSIONS OGV,")
  [ ! -z $WEBM ] && CONVERSIONS=$(echo "$CONVERSIONS WEBM,")
  # Helpful partial string matching info found in
  # https://stackoverflow.com/a/15988793
  CONVERSIONS=${CONVERSIONS%,*}
  
  if [ ! -z "$list" ]; then
    echo "Working on DVD $src track $track. Converting to $CONVERSIONS. " | tee -a $destination/dvd_$(echo $src).log
    rm -f $track_parts_list
    for f in $list; do
      echo "Found track $f"  | tee -a $destination/dvd_$(echo $src).log
      echo "file '$f'" >> $track_parts_list; 
    done
  fi
  if [ -f "$track_parts_list" ] && [ -r "$track_parts_list" ] && [ -s "$track_parts_list" ]; then
    echo -e "\n= = = = = =\n" | tee -a $destination/dvd_$(echo $src).log
    echo  "Next the actual conversion job (per track, merging *track* parts into one track), working with track info in $track_parts_list ... " | tee -a $destination/dvd_$(echo $src).log
    sleep 3
    if [ "$MP4" == "1" ]; then
      TRACK_START=$(date +%s)
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
        echo -e "Next executing this command:\n\$ $cmd" | tee -a $destination/dvd_$(echo $src).log
        $cmd
        TRACK_DURATION=$(( $(date +%s) - $TRACK_START))
        echo "$trackname.mp4 converted. Finished working at $(date)." | tee -a $destination/dvd_$(echo $src).log
        printf 'Track conversin took %dh:%dm:%ds\n' $(( $TRACK_DURATION / 3600 )) $(( $TRACK_DURATION%3600 / 60 )) $(( $TRACK_DURATION%60 )) | tee -a $destination/dvd_$(echo $src).log
      fi
    fi
    
    if [ "$WEBM" == "1" ]; then
      TRACK_START=$(date +%s)
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
        # @see http://diveintohtml5.info/video.html#webm-cli
        # @see https://www.ffmpeg.org/ffmpeg.html
        # @see https://www.ffmpeg.org/ffmpeg-codecs.html 
        # 1st round for analyzing the content. No audio conversion required on
        # the 1st round (hence the "-an" -parameter, and no audio codec ).
        cmd="ffmpeg -v $verbosity -hide_banner -f concat -safe 0 -i "$track_parts_list" -pass 1 -passlogfile $trackname.webm -keyint_min 0 -g 250 -skip_threshold 0 -qmin 1 -qmax 51 -c:v libvpx -v:b 614400 -s 720x576 -aspect 5:4 -an -crf 10 -strict -2 -f webm -y /dev/null"
        echo -e "Next executing this command:\n\$ $cmd" | tee -a $destination/dvd_$(echo $src).log
        $cmd
        # 2nd round for the actual conversion. Now grab the audio, too, and set
        # the final target file name (outfile).
        cmd="ffmpeg -v $verbosity -hide_banner -f concat -safe 0 -i "$track_parts_list" -pass 2 -passlogfile $trackname.webm -keyint_min 0 -g 250 -skip_threshold 0 -qmin 1 -qmax 51 -c:v libvpx -v:b 614400 -c:a vorbis -b:a 128k -s 720x576 -aspect 5:4 -crf 10 -strict -2 $trackname.webm"
        echo -e "Next executing this command:\n\$ $cmd" | tee -a $destination/dvd_$(echo $src).log
        $cmd
        TRACK_DURATION=$(( $(date +%s) - $TRACK_START))
        echo "$trackname.webm converted. Finished working at $(date)." | tee -a $destination/dvd_$(echo $src).log
        printf 'Track conversin took %dh:%dm:%ds\n' $(( $TRACK_DURATION / 3600 )) $(( $TRACK_DURATION%3600 / 60 )) $(( $TRACK_DURATION%60 )) | tee -a $destination/dvd_$(echo $src).log
      fi
    fi
    
    if [ "$OGV" == "1" ]; then
      TRACK_START=$(date +%s)
      ###  .ogv -format (slow, becase of re-encoding) ###
      if [ -f $trackname.ogv ]; then
        echo "$trackname.ogv exists already. Skipping..." | tee -a $destination/dvd_$(echo $src).log
        echo "Please remove $trackname.ogv if you wish to re-convert your DVD to this format, OR set 3rd script parameter to 1."
        sleep 3
      else
        echo "$trackname.ogv not yet converted. Start working at $(date)." | tee -a $destination/dvd_$(echo $src).log
        cmd="ffmpeg -v $verbosity -hide_banner -f concat -safe 0 -i "$track_parts_list" -c:v libvpx -crf 10 -b:v 1M -c:a libvorbis $trackname.ogv"
        echo -e "Next executing this command:\n\$ $cmd" | tee -a $destination/dvd_$(echo $src).log
        $cmd
        TRACK_DURATION=$(( $(date +%s) - $TRACK_START))
        echo "$trackname.ogv converted. Finished working at $(date)." | tee -a $destination/dvd_$(echo $src).log
        printf 'Track conversin took %dh:%dm:%ds\n' $(( $TRACK_DURATION / 3600 )) $(( $TRACK_DURATION%3600 / 60 )) $(( $TRACK_DURATION%60 )) | tee -a $destination/dvd_$(echo $src).log
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

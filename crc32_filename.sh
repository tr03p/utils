#!/bin/sh

DRY=0

usage() {
  echo "Append the CRC32 to filename of each file in a directory"
  echo ""
  echo "usage: $0 [-hn] directory_path"
  echo "  -h, --help    print out this help"
  echo "  -n, --dry     dry run, do not rename files"
  exit 0
}

# Check parameters
while :
do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
      
    -n | --dry)
      DRY=1
      shift
      ;;

    --) # End of all options
      shift
      break
      ;;
    -*)
      echo "Error: Invalid option: $1" >&2
      echo "Try '$0 --help' for more information."
      exit 1 
      ;;
    *)  # No more options
      break
      ;;
  esac
done

if [ "$#" -ne 1 ]
then
  usage
  exit 1
fi

for FILENAME in "$1"/*; do
  if [ -d "$FILENAME" ]; then
    continue
  fi
  HASH=$(crc32 "$FILENAME")
  #HASH=${HASH^^} # Bashism
  HASH=`echo $HASH | tr '[a-z]' '[A-Z]'` # Uppercase
  if [ ${#HASH} -ne 8 ]; then
    continue
  fi
  
  TYPE=${FILENAME##*.}
  NEW_FILENAME=${FILENAME%.$TYPE}[$HASH].$TYPE # Append CRC32 to filename
  echo $NEW_FILENAME
  if [ $DRY = 0 ]; then
    mv "$FILENAME" "$NEW_FILENAME"
  fi
done
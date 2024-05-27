#!/bin/bash

# Check if file argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

# Check if file exists
if [ ! -f "$1" ]; then
    echo "Error: bin File '$file' not found."
    exit 1
fi

# Get the operating system name
OS=$(uname)
if [ "$OS" != "Linux" ]; then
    echo "Need to run under Linux"
    exit
fi





# --- Variables
BINARY_FILE=$1
HEADER_FILE="header.bin"
CRC_FILE="crc.bin"
OUTPUT_FILE=${BINARY_FILE%.*}".SYS"




# --- Define the header components in Big Endian
FILE_ID_HEX="73AC" # Example:171 (ABh) Sirius FW, 172 (ACh) Kenetics FW
FILE_ID_BYTES="\x${FILE_ID_HEX:0:2}\x${FILE_ID_HEX:2:2}"

FORMAT_VERSION_BYTE="\x01"

PARAM_VERSION="0001"
PARAM_VERSION_BYTES="\x${PARAM_VERSION:0:2}\x${PARAM_VERSION:2:2}"

FILE_LENGTH=$(stat -c%s "$BINARY_FILE") # Get the length of the binary file
# FILE_LENGTH=$((FILE_LENGTH + 4)) # add 4 bytes CRC32
FILE_LENGTH_HEX=$(printf "%08X" $FILE_LENGTH)
FILE_LENGTH_BYTES=$(echo $FILE_LENGTH_HEX | sed 's/../\\x& /g' | awk '{print $1$2$3$4}')

DATE_TIME=$(date +'%s') # Current date and time as seconds since epoch
DATE_TIME_HEX=$(printf "%08X" $DATE_TIME)
DATE_TIME_BYTES=$(echo $DATE_TIME_HEX | sed 's/../\\x& /g' | awk '{print $1$2$3$4}')

LOCATION_ID_BYTES="\x00\x00"

SPARE_BYTE="\x00"


# --- printout
echo -ne "\t" && echo "-----"
echo -ne "\t" && echo "FILE_ID           $FILE_ID_BYTES"
echo -ne "\t" && echo "FORMAT_VERSION    $FORMAT_VERSION_BYTE"
echo -ne "\t" && echo "PARAM_VERSION     $PARAM_VERSION_BYTES"
echo -ne "\t" && echo "FILE_LENGTH       $FILE_LENGTH_BYTES"
echo -ne "\t" && echo "DATE_TIME         $DATE_TIME_BYTES"
echo -ne "\t" && echo "LOCATION_ID       $LOCATION_ID_BYTES"
echo -ne "\t" && echo "SPARE             $SPARE_BYTE"
echo ""
# Create the 16-byte header
echo -ne "${FILE_ID_BYTES}${FORMAT_VERSION_BYTE}${PARAM_VERSION_BYTES}${FILE_LENGTH_BYTES}${DATE_TIME_BYTES}${LOCATION_ID_BYTES}${SPARE_BYTE}" > "$HEADER_FILE"



# --- calculate CRC

# Function to calculate CRC32 using system crc32 command on Linux
crc32_linux() {
    if command -v crc32 &> /dev/null; then
        CRC=$(crc32 "$BINARY_FILE" | awk '{print toupper($1)}')
		return 0
    elif [ -x "./crc32_linux" ]; then
		# CRC_DEBUG_OUTPUT=$(./crc32_linux "$BINARY_FILE")
        # if [[ $CRC_DEBUG_OUTPUT =~ crc32=([0-9a-fA-F]+) ]]; then
            # CRC="${BASH_REMATCH[1]}"
            # return 0  # Success
        # else
            # echo "Error: Output does not contain CRC32 value"
            # return 1  # Error
        # fi
		CRC=$(./crc32_linux "$BINARY_FILE")
		return 0
	else
		echo "Error: crc32 not found or executable"
        return 1  # Error
    fi
}

crc32_linux
CRC_BYTES=$(echo "$CRC" | sed 's/../\\x& /g' | awk '{print $1$2$3$4}')
echo -ne "\t" && echo "CRC               $CRC_BYTES"
echo -ne "\t" && echo "-----"
echo -ne "${CRC_BYTES}" > "$CRC_FILE"



# --- Concatenate header, binary file, and CRC
cat "$HEADER_FILE" "$BINARY_FILE" "$CRC_FILE" > "$OUTPUT_FILE"

rm "$HEADER_FILE" "$CRC_FILE"

echo "Packed $BINARY_FILE -> $OUTPUT_FILE."
echo ""
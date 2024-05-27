#!/bin/bash


# initial variables
compilation_dir=./os_patch
MEA_version_str=""
RF_version_str=""
timestamp=""
fw_input=""
mea_input=""

input_string="$@"  # Use "$@" to capture all command-line arguments as a single string
# Check if input_string is empty
if [ -z "$input_string" ]; then
    # default MEA
    echo "Empty input. Use local MEA"
    mea_input=/home/sirius/workspace/NTRU/xmsdk/Debug-Board-Slave/MEA
    
    MEA_FILE_FW_VERSION=/home/sirius/workspace/NTRU/xmsdk/src/include/mlsCompileSwitches.h
    if [ -e "${MEA_FILE_FW_VERSION}" ]; then
        MEA1=$(grep DEV_FIRMWARE_MEA_VERSION_MAJOR ${MEA_FILE_FW_VERSION} | tr -d '\r\n' | awk '{print $NF}')
        MEA2=$(grep DEV_FIRMWARE_MEA_VERSION_MINOR ${MEA_FILE_FW_VERSION} | tr -d '\r\n' | awk '{print $NF}')
        MEA3=$(grep DEV_FIRMWARE_MEA_REVISION      ${MEA_FILE_FW_VERSION} | tr -d '\r\n' | awk '{print $NF}')
        MEA_version="${MEA1}${MEA2}${MEA3}"
        MEA_version_str=".MEA${MEA1}${MEA2}${MEA3}"
        echo detected MEA version: $MEA_version
    fi
    
    # ask for RF
    echo "Please enter RF file if any"
    echo -n ": "
    read -e fileRF_input
    if [[ $fileRF_input =~ ^fw ]]; then
        fw_input=$fileRF_input
    else
        echo "No RF to compile"
        fw_input=
    fi
else
    # Split the input string by spaces
    read -ra input_parts <<< "$input_string"
    timestamp=".$(date +"%Y%m%d_%H%M%S")"
    # Loop through each part and assign values based on prefix
    for part in "${input_parts[@]}"; do
        if [[ $part =~ ^fw ]]; then
            fw_input="$part"
        elif [[ $part =~ ^MEA ]]; then
            mea_input="$part"
            MEA_version_str=".MEA"
        else
            echo "Invalid input: Parts must start with either 'fw' or 'MEA'."
            exit 1
        fi
    done
fi
# Output the extracted values
echo -e "\tRF : $fw_input"
echo -e "\tMEA: $mea_input"



# --- os_patch folders & script
# RF dir
if [ ! -d "$compilation_dir/fw_storage" ]; then
	# If the directory doesn't exist, create it
	mkdir -p "$compilation_dir/fw_storage"
	echo "Directory '$compilation_dir/fw_storage' created."
fi
# MEA dir
if [ ! -d "$compilation_dir/home/root" ]; then
	# If the directory doesn't exist, create it
	mkdir -p "$compilation_dir/home/root"
	echo "Directory '$compilation_dir/home/root' created."
fi

create_rf_script() {
	local filename="rfpro_fw_update.sh"
	if [ ! -f "$compilation_dir/fw_storage/$filename" ]; then
		# If the file doesn't exist, create it
		cat << 'EOF' > "$compilation_dir/fw_storage/$filename"
#!/bin/sh

echo "update rf pro firmware..."
Update_Enc_Sign_Fw /fw_storage/sr14v2_app_enc.bin /fw_storage/sr14v2_app.sig
EOF
		echo "File '$filename' created."
	else
		echo "File '$filename' already exists."
	fi
}


# --- prepare RF
# clean up
if [ -e "$compilation_dir/fw_storage/sr14v2_app.sig" ]; then rm $compilation_dir/fw_storage/sr14v2_app.sig; fi
if [ -e "$compilation_dir/fw_storage/sr14v2_app_enc.bin" ]; then rm $compilation_dir/fw_storage/sr14v2_app_enc.bin; fi
if [ -e "$compilation_dir/fw_storage/rfpro_fw_update.sh" ]; then rm $compilation_dir/fw_storage/rfpro_fw_update.sh; fi

fileRF=$fw_input
if [ -n "$fileRF" ]; then
    if [ -e "${fileRF}" ]; then 
        echo "extract RF '$fileRF' to fw_storage"
        tar zxf "${fileRF}" -C $compilation_dir/fw_storage/
        RF_version_str=".$(basename "${fileRF}" .tar.gz)"
		create_rf_script
    else
        echo "unable to find RF"
		exit 1
    fi
fi


# --- prepare MEA
# clean up
if [ -e "$compilation_dir/home/root/MEA" ]; then rm $compilation_dir/home/root/MEA; fi

fileApp=$mea_input
if [ -n "$fileApp" ]; then
    if [ -e "${fileApp}" ]; then 
        cp -fp "${fileApp}" $compilation_dir/home/root/
    else
        echo "unable to find <${fileApp}>"
        echo "Please re-enter MEA file"
        echo -n ": "
        read -e fileApp_input
        if [ -z "${fileApp_input}" ]; then 
            echo "No MEA file name entered. Exiting."
            exit 1
        else
            fileApp=$fileApp_input
        fi
        if [ -e "${fileApp}" ]; then 
            cp -fp "${fileApp}" $compilation_dir/home/root/
        else
            echo "cannot find the MEA <${fileApp}>"
            exit 1
        fi
    fi
fi



# --- Define the name of .bin file
bin_file="os_patch${MEA_version_str}${RF_version_str}${timestamp}.bin"
# echo "bin file: ${bin_file}"



# --- compile .bin
pushd $compilation_dir > /dev/null
echo "go into folder $(dirs +0)"
find ./ -type f -exec chmod +x {} \;
tar zcf ../${bin_file} ./*
echo "compiled <${bin_file}>"
popd > /dev/null
echo "back into $(dirs +0)"


# --- pack .bin file with header and crc as .SYS file
./pack_header_bin_crc.sh ${bin_file}
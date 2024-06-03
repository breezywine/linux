# Check if the file already exists
compilation_dir=./os_patch
filename="rfpro_fw_update.sh"

if [ ! -f "$compilation_dir/fw_storage/$filename" ]; then
    # If the file doesn't exist, create it
    cat << 'EOF' > "$compilation_dir/fw_storage/$filename"
#!/bin/bash

echo "update rf pro firmware..."
Update_Enc_Sign_Fw /fw_storage/sr14v2_app_enc.bin /fw_storage/sr14v2_app.sig
EOF
    echo "File '$filename' created."
else
    echo "File '$filename' already exists."
fi

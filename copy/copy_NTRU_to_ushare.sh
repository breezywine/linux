
src_dir=/home/sirius/workspace/NTRU/
[ ! -d $src_dir ] && echo "missing directory <$src_dir>" && exit
cd $src_dir


# MEA1=$(grep DEV_FIRMWARE_MEA_VERSION_MAJOR /home/sirius/workspace/NTRU/xmsdk/src/include/mlsCompileSwitches.h | hexdump -c)
# MEA1=$(grep DEV_FIRMWARE_MEA_VERSION_MAJOR /home/sirius/workspace/NTRU/xmsdk/src/include/mlsCompileSwitches.h | tr -d '\r\n' | awk '{print $NF}')
# MEA2=$(grep DEV_FIRMWARE_MEA_VERSION_MINOR /home/sirius/workspace/NTRU/xmsdk/src/include/mlsCompileSwitches.h | tr -d '\r\n' | awk '{print $NF}')
# MEA3=$(grep DEV_FIRMWARE_MEA_REVISION      /home/sirius/workspace/NTRU/xmsdk/src/include/mlsCompileSwitches.h | tr -d '\r\n' | awk '{print $NF}')
# folder_version=${MEA1}${MEA2}${MEA3}
# echo detected MEA version: $folder_version

# read -p "NTRU version : " folder_version
# NTRU_folder=NTRU_${folder_version}
# dest_dir=/mnt/hgfs/ushare/$NTRU_folder
dest_dir=/mnt/hgfs/ushare/NTRU/
[ -d $dest_dir ] && echo "Directory <$dest_dir> exists" || mkdir $dest_dir
echo copying folders
# cp -a C2Lib $dest_dir
# cp -a C3Lib $dest_dir
# cp -a C4Lib $dest_dir
# cp -a DBLib $dest_dir
# cp -a EMVLib $dest_dir
# cp -a EntryPointLib $dest_dir
# cp -a xmsdk $dest_dir

# rsync -ah --progress source-file destination-file
rsync_opt="-azh --info=progress1,flist --itemize-changes"
rsync $rsync_opt C2Lib $dest_dir
rsync $rsync_opt C3Lib $dest_dir
rsync $rsync_opt C4Lib $dest_dir
rsync $rsync_opt DBLib $dest_dir
rsync $rsync_opt EMVLib $dest_dir
rsync $rsync_opt EntryPointLib $dest_dir
rsync $rsync_opt --exclude '*openssl*' xmsdk $dest_dir
rsync $rsync_opt xmsdk/src/openssl/ ${dest_dir}xmsdk/src/openssl/

echo copy completed


sleep 3
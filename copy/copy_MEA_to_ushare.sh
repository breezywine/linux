
src_dir=/home/sirius/workspace/NTRU/xmsdk/Debug-Board-Slave
[ ! -d $src_dir ] && echo "missing directory <$src_dir>" && exit
cd $src_dir

MEA1=$(grep DEV_FIRMWARE_MEA_VERSION_MAJOR /home/sirius/workspace/NTRU/xmsdk/src/include/mlsCompileSwitches.h | tr -d '\r\n' | awk '{print $NF}')
MEA2=$(grep DEV_FIRMWARE_MEA_VERSION_MINOR /home/sirius/workspace/NTRU/xmsdk/src/include/mlsCompileSwitches.h | tr -d '\r\n' | awk '{print $NF}')
MEA3=$(grep DEV_FIRMWARE_MEA_REVISION      /home/sirius/workspace/NTRU/xmsdk/src/include/mlsCompileSwitches.h | tr -d '\r\n' | awk '{print $NF}')
detect_version=${MEA1}${MEA2}${MEA3}
echo detected MEA version: $detect_version

# read -p "MEA version : " MEA_version
MEA_folder="MEA_"$detect_version
# echo MEA folder $MEA_folder
dest_dir=/mnt/hgfs/ushare/$MEA_folder

#mkdir -p $dest_dir
[ -d $dest_dir ] && echo "Directory <$dest_dir> exists" || mkdir $dest_dir

# kinectics reader copy
cp -p emv*Chksum.dat $dest_dir
cp -p MEA $dest_dir

echo done copy

sleep 3
#read -r -p "Wait 5 seconds or press any key to continue immediately" -t 5 -n 1 -s

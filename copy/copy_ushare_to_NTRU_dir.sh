#!/bin/bash

# read -p "xmsdk version : " xmsdk_version
# src_dir=/mnt/hgfs/ushare/xmsdk_${xmsdk_version}/
src_dir=/mnt/hgfs/ushare/NTRU/
[ ! -d $src_dir ] && echo "missing directory <$src_dir>" && exit


dest_dir=/home/sirius/workspace/NTRU/


# sirius reader copy
# cp -a $src_dir $dest_dir
rsync -azh --info=progress1,flist --itemize-changes --exclude *openssl* $src_dir $dest_dir 

sleep 3
# read -p "Press enter to continue"
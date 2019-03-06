#!/bin/sh

set -x
#prog=ftp.sna
#labels=startup.lab
prog=
labels=wc_ftp.lab

unreal="${HOME}/zx-speccy/unreal-ts"

wc_plugin="FTP.WMF"

for i in ${wc_plugin};do
 if [ ! -f ${i} ];then
  echo "no file ${i} found"
  exit 1
 fi
done

sudo mount -t vfat ~/zx-speccy/unreal-ts/wc.img /mnt/tmp -o loop
if [ $? -ne 0 ];then
 echo "error mount image"
 exit 1
fi
for i in ${wc_plugin}; do
 sudo rm -f /mnt/tmp/WC/${i}
 sudo cp $i /mnt/tmp/WC
done
sudo umount /mnt/tmp

if [ -f  ${unreal}/${labels} ]; then
 rm -f ${unreal}/${labels}
fi

if [ -f ${labels} ];then
 pwd
 cp ${labels} ${unreal}/
fi


cd ${unreal}

if [ -z ${prog} ];then
 if [ -z ${labels} ];then
  wine "Unreal.exe"
 else
  wine "Unreal.exe" "-l${labels}"
 fi
else
 if [ -z ${labels} ];then
  wine "Unreal.exe" "${prog}"
 else
  wine "Unreal.exe" "-l${labels} ${prog}"
 fi
fi
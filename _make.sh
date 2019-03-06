#!/bin/sh

frompage=02
topage=62

for i in FTP.WMF ftp.sna; do
 if [ -f ${i} ];then
  rm -f ${i}
 fi
done

for i in wc_ftp startup; do
 echo "**** Compile $i  ****"
 sjasmplus --labels ${i}.asm

 if [ -f ${i}.lab ];then
  sed -i "s/${frompage}:/${topage}:/g" ${i}.lab
 fi

done

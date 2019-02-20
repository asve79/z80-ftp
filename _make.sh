#!/bin/sh

for i in FTP.WMF ftp.sna; do
 if [ -f ${i} ];then
  rm -f ${i}
 fi
done

for i in wc_ftp startup; do
 echo "**** Compile $i  ****"
 sjasmplus ${i}.asm
done

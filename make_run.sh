#!/bin/sh

prog=ftp.sna

./_make.sh
if [ $? -eq 0 ];then
 ./_run.sh
else
 rm $prog
fi

# z80-ftp

**Product is under construction!**

Now I decide which platform to choose for working with files. 
1st: ZX Evolution (TS-Conf)
2nd: ZX Spectrum Next (Now I don’t know anything about input / output of files in this system)

FTP client for z80 (developing and testing on ts-conf machine emulator)

Client use RS232 (#F8EF+REGS) connection & socket server on host machine.

* windows library: https://github.com/asve79/xasconv
* socket library: https://github.com/HackerVBI/ZiFi/tree/master/_rs232
* socket server: https://github.com/HackerVBI/ZiFi/tree/master/_rs232/ic_emul_0.2
* Emulator: https://github.com/tslabs/zx-evo/raw/master/pentevo/unreal/Unreal/bin/unreal.7z or https://github.com/asve79/Xpeccy

## Support commands
* open
* ls
* dir
* cd <directory>
* quit
* close
* bye
* mkdir <directory>
* rmdir <directory>
* rm <filename>
* pwd
* cat <filename>
* cdup
* size

## To Do
* 'get' command
* 'put' command
* 'user' command
* Paging when output support
* Trap exception when code 500 seceved

## Build
Assembler:  https://github.com/z00m128/sjasmplus
```bash
git clone git@github.com:asve79/z80-ftp.git

cd z80-ftp
./get_depencies.sh
./_make.sh
```
## Demo
![Demo](https://github.com/asve79/z80-ftp/blob/master/demo/ftp-client-demo.gif)

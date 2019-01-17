# z80-ftp

Product is under construction!

FTP client for z80 (developing and testing on ts-conf machine emulator)

Client use RS232 (#F8EF+REGS) connection & socket server on host machine.

* windows library: https://github.com/asve79/xasconv
* socket library: https://github.com/HackerVBI/ZiFi/tree/master/_rs232
* socket server: https://github.com/HackerVBI/ZiFi/tree/master/_rs232/ic_emul_0.2
* Emulator: https://github.com/tslabs/zx-evo/raw/master/pentevo/unreal/Unreal/bin/unreal.7z or https://github.com/asve79/Xpeccy

Support commands:
* ls
* dir
* cd
* quit
* close
* bye

To do:
* 'cdup' command
* 'get' command
* 'put' command
* 'open' command on terminal
* 'user' command

build:
```bash
git clone git@github.com:asve79/z80-ftp.git

cd z80-ftp
./get_depencies.sh
./_make.sh
```
Demo:
![Demo](https://github.com/asve79/z80-ftp/blob/master/demo/ftp-client-demo.gif)

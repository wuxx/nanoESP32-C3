nanoESP32-C3
-----------
[中文](./README_cn.md) [English](./README.md)

* [nanoESP32-C3介绍](#nanoESP32-C3介绍)
* [模组规格](#模组规格)
* [ESPLink](#ESPLink)
* [产品链接](#产品链接)
* [参考](#参考)


# nanoESP32-C3介绍
nanoESP32-C3 是MuseLab基于乐鑫ESP32-C3模组推出的开发板，板载USB转串口，TYPE-C、全彩LED，引脚兼容官方开发板，板载的下载器支持拖拽烧录和jtag调试，方便客户进行快速的原型验证及开发。


<div align=center>
<img src="https://github.com/wuxx/nanoESP32-C3/blob/master/doc/nanoESP32-C3-1.jpg" width = "500" alt="" align=center />
</div>

# 模组规格
nanoESP32-C3 开发板使用乐鑫官方模组ESP32-C3-MINI-1, 以下为具体规格参数

Component|Detail |
----|----|
MCU         | 32bit RISC-V ESP32-C3FN4 up to 160MHz |
ROM         | 384KB |
SRAM        | 400KB(16KB for cache) |
Flash       | 4MB |
WiFi        | IEEE 802.11bgn |
Bluetooth   | BLE 5.0 & mesh |
GPIO        | 22 |
SPI         | 3 |
UART        | 2 |
I2C         | 1 |
RMT         | 2T+2R |
DMA         | 3T+3R |
LED-PWMC    | 6 channel |
TWAI        | 1 |
ADC         | 2 x 12bit, 6 channel |
Temp sensor | 1 |
Timer       | 6 |
Security    | OTP/AES/SHA/RSA/RNG/HMAC |

# ESPLink
nanoESP32-C3 板载一个称之为ESPLink的下载器，支持USB转串口、拖拽烧录、JTAG调试，以下是详细的说明
## USB-to-Serial
和传统的使用方式兼容（替代CP2102、CH340之类的USB转串口芯片），可使用esptool.py进行烧录或串口调试，举例如下：
```
$idf.py -p /dev/ttyACM0 flash monitor
$esptool.py --chip esp32c3 \
           -p /dev/ttyACM0 \
           -b 115200 \
           --before=default_reset \
           --after=hard_reset \
           --no-stub \
           write_flash \
           --flash_mode dio \
           --flash_freq 80m \
           --flash_size 2MB \
           0x0     esp32c3/bootloader.bin \
           0x8000  esp32c3/partition-table.bin \
           0x10000 esp32c3/blink_100.bin
```

## 拖拽烧录
板载的下载器ESPLink支持拖拽烧录，将开发板上电之后，PC将会出现一个名为`ESPLink`的虚拟U盘，此时只需将flash镜像文件拖拽至`ESPLink`虚拟U盘中，稍等片刻，即可自动完成烧录。此功能使得烧录无需依赖任何外部工具以及操作系统，
典型的使用场景列举如下：快速的原型验证、在云端服务器进行编译、然后在任意PC上烧录、或者在商业的产品中实现固件的快速升级。
注意：flash镜像文件为三个文件(bootloader.bin/partition-table.bin/app.bin)拼接而成，需要将`bootloader.bin`填充至0x8000，`partition-table.bin`填充至0x10000，然后将三个文件直接合并。tools目录下提供了一个脚本以供使用，举例如下：
```
$./tools/esppad.sh bootloader.bin partition-table.bin app.bin flash_image.bin
```

## JTAG Debug
ESPLink 支持使用jtag调试ESP32-C3, 对于想学习RISC-V 架构汇编原理图的爱好者非常有用，若您是商用产品的开发者，这也可以方便的让您在系统崩溃时查找原因。具体使用说明如下：

### Openocd 安装

openocd-esp32 仓库的预编译包缺乏对本模块的 ESPLink 支持，所以需要手动编译。

```
$ git clone https://github.com/espressif/openocd-esp32.git
$ cd openocd-esp32
$ git checkout v0.11.0-esp32-20220706
```

openocd-esp32 并不太稳定，所以建议 checkout 某个特定的版本，比如 `v0.11.0-esp32-20220706`，注意不要 checkout `v0.11.0`，它缺乏对 esp32 芯片的支持。

```
$ ./bootstrap
```

如果出现 AC_INIT 错误，更改文件 configure.ac 的第二行，从 `AC_INIT([openocd], [ ]` 改为 `AC_INIT([openocd], [ "" ]` 即可（即添加一对空的双引号）。

```
$./configure --enable-cmsis-dap --disable-werror
$make -j
$sudo make install
```

如果你的系统里有多个定制版本的 openocd，建议不要运行 `sudo make install`，只在有需要时，直接运行上面编译得到的 `openocd-esp32/src/openocd` 即可，比如：

```
./src/openocd -f interface/cmsis-dap.cfg -f target/esp32c3.cfg -s "tcl" -c 'adapter_khz 10000'
```

### 烧录efuse
efuse JTAG_SEL_ENABLE bit需要烧录来启用jtag功能.
```
$espefuse.py -p /dev/ttyACM0 burn_efuse JTAG_SEL_ENABLE
```

### Attach to ESP32-C3
将GPIO10 拉低到GND以启用GPIO的JTAG功能，上电开发板然后执行以下脚本，若一切正常，则可检测到ESP32-C3的idcode
```
$sudo openocd -f tcl/interface/cmsis-dap.cfg -f tcl/target/esp32c3.cfg -c 'adapter_khz 10000'
Open On-Chip Debugger  v0.10.0-esp32-20201202-30-gddf07692 (2021-03-22-16:48)
Licensed under GNU GPL v2
For bug reports, read
        http://openocd.org/doc/doxygen/bugs.html
adapter speed: 10000 kHz

force hard breakpoints
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
Info : CMSIS-DAP: SWD  Supported
Info : CMSIS-DAP: JTAG Supported
Info : CMSIS-DAP: FW Version = 0255
Info : CMSIS-DAP: Serial# = 0800000100430028430000014e504332a5a5a5a597969908
Info : CMSIS-DAP: Interface Initialised (JTAG)
Info : SWCLK/TCK = 1 SWDIO/TMS = 1 TDI = 1 TDO = 1 nTRST = 0 nRESET = 1
Info : CMSIS-DAP: Interface ready
Info : High speed (adapter_khz 10000) may be limited by adapter firmware.
Info : clock speed 10000 kHz
Info : cmsis-dap JTAG TLR_RESET
Info : cmsis-dap JTAG TLR_RESET
Info : JTAG tap: esp32c3.cpu tap/device found: 0x00005c25 (mfg: 0x612 (Espressif Systems), part: 0x0005, ver: 0x0)
Info : datacount=2 progbufsize=16
Info : Examined RISC-V core; found 1 harts
Info :  hart 0: XLEN=32, misa=0x40101104
Info : Listening on port 3333 for gdb connections
```

### Debug
attach 成功之后，另外打开一个终端窗口，可以使用telnet或者gdb来进行调试

#### Debug with Gdb
```
$riscv32-esp-elf-gdb -ex 'target remote 127.0.0.1:3333' ./build/blink.elf
(gdb) info reg
(gdb) s
(gdb) continue
```

#### Debug with telnet
```
$telnet localhost 4444
>reset
>halt
>reg
>step
>reg pc
>resume
```

# 产品链接
[nanoESP32-C3 Board](https://item.taobao.com/item.htm?spm=a1z10.5-c.w4002-21349689069.14.146848aeEGVAz9&id=652515479052)

# 参考
### esp-idf
https://github.com/espressif/esp-idf
### esp32-c3 get-started
https://docs.espressif.com/projects/esp-idf/en/latest/esp32c3/get-started/
### esp32-c3
https://www.espressif.com/zh-hans/products/socs/esp32-c3

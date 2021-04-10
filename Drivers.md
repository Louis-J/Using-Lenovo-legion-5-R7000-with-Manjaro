## 显卡

r7000为双显卡机型， 需要进Bios设置为混合模式， 然后再继续装系统。

装好后， 可以安装三个驱动：

+ amd开源驱动， 主要用作显示功能

  + ```shell
    xf86-video-amdgpu
    mhwd-amdgpu
    (由于没有vulkan需求， 因此我未安装vulkan驱动)
    ```

+ amd闭源驱动， 似乎某些情况下性能更好， 但相对与开源驱动没有质变， 非必需

  + ```shell
    amdgpu-pro-libgl
    vulkan-amdgpu-pro(由于没有vulkan需求， 因此我未安装vulkan驱动)
    ```
+ nvidia闭源驱动， 使用cuda等需要

  + ```shell
    nvidia-prime
    nvidia-utils
    mhwd-nvidia
    ```

manjaro安装时选择闭源驱动，已自动装好双显卡切换程序， amd开源驱动， nvidia闭源驱动。 如果不需要amd闭源驱动**<u>则不用任何操作开箱即用</u>**。 如果由于个别原因需要手动安装， 只需要禁用nouveau， 和安装amd闭源驱动即可。

### 禁用nouveau

nouveau是nvidia开源驱动， 可能装机时未选择闭源驱动等等原因用上了这个驱动。使用闭源驱动需禁用此驱动。

检查是否载入：

`lsmod | grep nouveau`

禁用：

`kate /etc/modprobe.d/blacklist.conf`

加入如下代码并重启

```shell
blacklist nouveau
options nouveau modeset=0
```

### 安装n卡闭源驱动（非自带的prime双显卡驱动）

首先从官网下载对应驱动， 为.sh文件

`Ctrl + Alt + F2`进入tty界面， 登入并安装.sh文件， 之后可`startx`进入图形桌面

### 安装a卡闭源驱动

直接使用`yay`从`aur`中安装`amdgpu-pro-libgl`并重启

### 安装后效果和操作

默认情况下， `nvidia-settings`可以看到`GPU0`为1650显卡。由于我是默认的双显卡模式因此n卡不连接屏幕。从系统信息可以看到实际是a卡连接屏幕。

用a卡闭源驱动时， 驱动信息显示为`amd`全称而非默认的`amd`

切换显卡的操作：

+ 默认执行程序时使用a卡开源驱动。
+ 使用`progl xxx`执行时使用a卡闭源驱动
+ 使用`prime-run xxx`执行时使用n卡闭源驱动
  + `pytorch`，`tf2`等无需手动设置

### 注1：

默认安装为双显卡模式， 也可以按别人教程安装两个显卡单独运行的模式：

+ `https://blog.csdn.net/L_Y_Fei/article/details/101113785`
+ `https://blog.csdn.net/xyt723916/article/details/106317594/`

### 注2:

我安装的方式下遇到了显卡亮度无法保存， 服务失败的小问题， 不影响使用但难免有些不适。

问题现象：

+ `systemctl --failed`看到对应的两个服务失败
+ 每次开机都是90%亮度， 超时睡眠重新登录后亮度都从0开始
+ 开关机会有红色警告，且略微降低开关机速度

经排查和尝试，猜测问题原因如下：

+ 系统有多个显卡， 在`/sys/class/backlight/`对应生成了多个文件夹，启动后只保留了`amdgpu_bl1`这个文件夹， 因此开机时设置失败，关机时对应的`gpu-monitor`亮度会读取失败
+ `/sys/class/backlight/amdgpu_bl1/actual_brightness`的值固定不变，为90%亮度，开机后无法读取和写入， 开关机时系统读写的是这个文件；实际调整亮度用的是`/sys/class/backlight/amdgpu_bl1/brightness`， 系统未操作

暂时的解决方法是：

+ 屏蔽对应服务

  ```
  systemctl mask systemd-backlight@backlight:acpi_video1.service
  systemctl mask systemd-backlight@backlight:amdgpu_bl1.service
  ```

+ grub中更改启动脚本

    ```
    ls /sys/class/backlight/
    amdgpu_bl1
    kate /etc/default/grub
    GRUB_CMDLINE_LINUX_DEFAULT="quiet acpi_backlight=amdgpu_bl1 ..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    ```
+ 重启

现状：开机后亮度为最大值，无警告

有另外两个亮度服务，似乎不起作用。

最好是自己重写一个服务， 开关机和睡眠唤醒时读写`/sys/class/backlight/amdgpu_bl1/brightness的`值。



## 触摸板

r7000的触摸板驱动已经集成到5.11以上的内核了， `manjaro`可直接切换至新内核就能使用



## 联想的电池模式功能

联想在win下适配了一个不错的功能：切换电池模式：

+ 普通充电
+ 快充
+ 保护电池，限定在55-60之间

`win`下可通过注册表开启并在联想电脑管家中启用， `linux`下也有办法使用， 通过调用`acpi_call`实现

具体已写进shell脚本(`power-manage`)， 安装`acpi_call`，将脚本放入`/usr/bin`， 即可使用。可通过`sudo sh power-manage`运行



## `ryzen`处理器电池模式问题

电池模式下， 默认的设置有缺陷， 一旦负载过高仍然会自动开启`cpu`升频， 导致电池模式下耗电较快。 需配合工具进行设置。

`ryzenadj`工具可设置功耗等， 功能强大， 但此工具并不非常好用， 可留待以后升级后使用。

默认的`tlp`即可进行设置：`kate /etc/tlp.conf`

我的配置如下， 可供参考：
```
TLP_ENABLE=1
#TLP_DEFAULT_MODE=AC
TLP_PERSISTENT_DEFAULT=0
TLP_PS_IGNORE=BAT
DISK_IDLE_SECS_ON_AC=0
DISK_IDLE_SECS_ON_BAT=2

MAX_LOST_WORK_SECS_ON_AC=15
MAX_LOST_WORK_SECS_ON_BAT=60



CPU_SCALING_MIN_FREQ_ON_AC=1400000
CPU_SCALING_MAX_FREQ_ON_AC=2900000
CPU_SCALING_MIN_FREQ_ON_BAT=1400000
CPU_SCALING_MAX_FREQ_ON_BAT=1700000

CPU_MIN_PERF_ON_AC=0
CPU_MAX_PERF_ON_AC=100
CPU_MIN_PERF_ON_BAT=0
CPU_MAX_PERF_ON_BAT=30

CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0



DISK_APM_LEVEL_ON_AC="254 254"
DISK_APM_LEVEL_ON_BAT="128 128"

SATA_LINKPWR_ON_AC="med_power_with_dipm max_performance"
SATA_LINKPWR_ON_BAT="med_power_with_dipm min_power"



WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

RUNTIME_PM_ON_AC=on
RUNTIME_PM_ON_BAT=auto

START_CHARGE_THRESH_BAT0=65
STOP_CHARGE_THRESH_BAT0=80
```


## 蓝牙耳机及声卡

默认声卡软件为`pulseaudio`， 但对于华为的`freelace pro`实际使用时效果一般， 无法支持`sbc`和`aac`模式， 且经常掉线。

安装`pipewire`软件：

```
pipewire pipewire-alsa pipewire-docs pipewire-jack pipewire-media-session pipewire-pulse
```

可代替`pulseaudio`，且`pavucontrol`设置界面、 `kde`通知栏和设置界面、 蓝牙连接界面、 wine均可直接使用， 无变化

注：

+ 当前`pipewire`稳定版本在`aac`模式下有问题， 会有奇怪报错， 需要在`bluez`（相当于蓝牙驱动软件）中禁用`aac`，使用`sbc`模式

  + ```
    kate /etc/pipewire/media-session.d/bluez-monitor.conf
    
    properties中加入（主要是第一条）：
    
    bluez5.codecs = [sbc]
    bluez5.msbc-support   = true
    bluez5.sbc-xq-support = true
    bluez5.headset-roles = [ hsp_hs hsp_ag hfp_hf hfp_ag ]
    ```

  + 

+ 可能我没配置好`pulseaudio`， 网上有人使用`sbc`和`aac`成功的， 可能掉线也是配置问题。

+ `pipewire`对蓝牙通话支持一般， 无法自动切换通话模式（蓝牙通话模式下不是`a2dp`，且音质下降）， 需要手动设置并重启相关软件才能使用蓝牙通话。



## 无线网卡及驱动

`ax200`在校使用会经常掉线， 经排查和尝试， 发现问题如下：

+ `networkmanager`默认使用自带的`dhcp`客户端， 使用`dhcp`获取`ip`时每次都是随机`mac` ， `wifi`设置界面固定`mac`的配置会隔一段时间自动失效
+ 隔一段时间会自动扫描网络， 且扫描时使用随机`mac`， 固定`mac`的配置无效

解决方法：

+ 从`intel`官网下载安装最新的`ucode`驱动文件（似乎并没有区别）

+ 使用`dhclient`而非自带的`dhcp`客户端， 且在`wifi`设置界面设置固定`mac`， 且设置扫描时使用固定`mac`

  + 使用`dhclient`：`kate /etc/NetworkManager/conf.d/dhcp-client.conf`

    ```
    [main]
    dhcp=dhclient
    ```
  
+ 使用固定`mac`：`kate /etc/NetworkManager/NetworkManager.conf `
    ```
    # Configuration file for NetworkManager.
    # See "man 5 NetworkManager.conf" for details.
    [device]
    wifi.scan-rand-mac-address=no
    
  [connection]
    wifi.cloned-mac-address=preserve
  ```

+ `https://wiki.archlinux.org/index.php/NetworkManager#DHCP_client`
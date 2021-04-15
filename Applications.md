## 中文输入法

尝试了谷歌，搜狗等各类输入法，觉得最好用的还是四叶草输入法。

安装`fcitx`输入框架：

```
pacman -S fcitx fcitx-configtool fcitx-qt5
```

安装`rime`框架和四叶草输入法：

```
pacman -S fcitx-rime rime-cloverpinyin
```

设置项等可以到四叶草输入法的官网查看。

注：

+ `fcitx5`配合`rime`问题较多， 且缺少一些设置， 建议使用`fcitx（fcitx4）`

+ 可以不用手动设置环境变量， 可以安装`manjaro-asian-input-support-{ibus,fcitx,fcitx5}`自动配置



## 键盘布局

我使用的是`norman`布局， 且做了一些小修改。

修改`/usr/share/X11/xkb/symbols/us`并重启；

修改系统设置->键盘设置；

修改系统设置->输入设备->键盘；

修改`fcitx`和`rime`中的键盘布局；

针对睡眠唤醒后键盘失效问题， 增加`/usr/lib/systemd/system-sleep/xcb_norman`：

```
#!/bin/sh

case $1 in
    pre)
#         echo "$(date)-  $1: 1" >> /tmp/nordvpn/suspend.txt
        /usr/bin/setxkbmap -layout us -variant norman
#         echo "$(/usr/bin/setxkbmap -print -verbose 10)" >> /tmp/nordvpn/suspend.txt
#         echo "$(date)-  $1: 2" >> /tmp/nordvpn/suspend.txt
        ;;
    post)
#         echo "$(date)-  $1: 1" >> /tmp/nordvpn/resume.txt
#         echo "$(date)-  $1: 2" >> /tmp/nordvpn/resume.txt
        ;;
esac

```



## 微信及wine配置

微信作为国内重要聊天软件， 没有`linux`版本， 只能使用wine模拟运行`win`版本。尝试许久发现许多坑， 现已基本解决。

### wine

主要有三个版本， 区别如下

+ `deepin-wine5`：国内厂商深度定制的版本， 做了许多对国内软件的适配和优化， 据说配合`deepin-linux`已经非常好用了。但违反`GPL`开源协议，且许多处理也仅停留在补丁式的适配上， 而非帮助`wine`改进， 且检索后发现`deepin`仅给`wine`提交过一次代码。在`manjaro`平台无法使用摄像头，但无`wine`官方版的其他问题

+ `wine for wechat`：国人大佬的wine补丁版， 加入了针对微信阴影的补丁， 但不知为何我遇到`jpeg`解码错误问题， 微信浏览动图就会崩溃退出。

+ `wine`：官方版。不会因为浏览动图退出， 且摄像头使用正常。 但有三个问题：使用微信截图会崩溃；文件夹选择及浏览未适配， 仍然用`wine`内置的；有透明阴影问题。

综上， 建议使用`wine`或`wine-staging`官方版。

`yay -S q4wine wine-gecko wine-mono wine-staging winetricks`

wine安装好后使用q4wine和winetricks进行配置， 安装里面提供的各类dll， 字体等， 配置好后可以支持许多win程序， 不会出现乱码等情形。 复杂的程序如微信需要有专门适配， 可以找别人的包使用。 感谢各位无私奉献的打包者！

### 微信

有许多适配的版本，经测试`deepin-wine-wechat`适配的最好， 基本可随微信官方更新， 可选使用wine或`deepin-wine`。

针对微信窗口透明阴影， 可以简单的编写小程序解决。 这个阴影实为一个半透明的窗口， 可在系统挂钩子监听时间前台切换事件， 并定时检查， 将窗口隐藏， 且定时检测微信进程是否还在并自动关闭。修改微信快捷方式，在开启微信前加载此程序即可。

本机测试仅截图功能无法使用， 摄像头， 小程序等都正常无崩溃。

## `7z`压缩软件

未在`linux`上找到好用的压缩软件图形管理界面， 因此使用`wine`和`7zip`， 辅助`ark`等使用。

`7z`的优势：可解压许多`exe`文件；无中文乱码问题；`7z`压缩率和压缩速度均强于`zstd`、`lz4`、`zx`、`brotli`等各类格式（已实测）；且支持多线程的`lzma2`压缩；配合`wine`使用及为方便。

安装步骤：

+ `wine`安装`7z`且配置`wine`中文件管理；
+ `~/.local/share/applications/wine-extension-7z.desktop`中，修改`Exec=env WINEPREFIX="~/.wine" wine /ProgIDOpen 7-Zip.7z %f`， 这样可以打开对应格式文件了

+ `~/.local/share/kservices5/ServiceMenus/`添加`open_in_7zfm.desktop`， 这样dolphin右键可以直接进入`7z`打开



## dolphin右键配置

可支持软件：

+ `meld`
+ `dolphin as root`
+ `7z`
+ `vscode`
+ `yakuake`

`~/.local/share/kservices5/ServiceMenus/`添加， 不再赘述



## 可直接安装使用的常用软件

### 文字类办公软件

+ `wps`：`ttf-wps-fonts wps-office wps-office-fonts wps-office-mui-zh-cn`
+ 邮件：经测试，`mailspring`、雷鸟、`kube`均有各种奇怪问题， `kmail`实在难以使用， 现使用`geary`
+ 阅读器：`fbreader`，`kchmviewer`，`okular`，`typora`
+ 思维导图：`xmind2020`

### 网络应用软件

+ 百度云盘：`linux`原生版无法登录，而命令行的`baidupcs-go`非常好用
+ 浏览器：火狐，谷歌
+ 下载：`xdman`用起来顺手，未尝试其他
+ 远程：`teamviewer`
+ 设备文件同步：`syncthing gtk`
+ 网络饭抢：`clash`，管理界面使用`yacd`和`qclash`

### 系统工具

+ 磁盘使用情况分析：baobab
+ 硬件检测：cpu-x zenmonitor nvtop radeontop
+ iso写入：multiwriter
+ 备份：timeshift
+ 终端：yakuake，zsh
+ 快捷运行：rofi

### 开发软件

+ python：anaconda，pycharm
+ c++：cmake， clang
+ 编译器：sublime-text， vscode
+ 文件比较工具：meld
+ 项目管理：git， smartgit

### 娱乐

+ 播放器：vlc， 网易云
+ 小游戏：knetwalk， kpatience

## Clash自启动

建立系统服务，自动启动clash：

`kate /etc/systemd/system/clash.service`

内容编辑如下：

```
[Unit]
#服务描述，写有意义的内容，便于识别
Description=Clash service
Documentation=
#放在该服务启动后启动，如果是Before，则是之前
# After=network-online.target
After=network.target
#Wants=依赖起他unit,弱依赖，如果是Requires，强依赖
# Wants=network-online.target

[Service]
Type=simple
#服务执行的路径
User=louisj
ExecStart=/usr/bin/clash
#指明停止unit要运行的命令或脚本
# ExecStop=/bin/kill -s QUIT $MAINPID
#当意外中止时是否重启
Restart=always

[Install]
WantedBy=multi-user.target

```

更新并启动：

```
sudo systemctl daemon-reload
sudo systemctl enable clash
sudo systemctl start clash
sudo systemctl status clash
```


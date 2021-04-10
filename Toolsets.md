## 源设置

设置`manjaro`的国内源：`sudo pacman-mirrors -i -c China -m rank`



添加`archlinuxcn`源（其实是`arch`的用户维护的仓库，不过和`manjaro`不兼容的情况很少）：`kate /etc/pacman.conf`

```
[archlinuxcn]
SigLevel = Never
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
```

或者安装`archlinuxcn-keyring` 包以导入`GPG key`，且添加内容为

```
[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
```

安装`yay`以使用`aur`源（`arch`用户库，有各类软件，且`yay`兼容`pacman`操作）：`pacman -S yay`



## 常用底层库

```
pacman -S binutils
```

```
pacman -S git make cmake openssh gcc g++ gdb vim wget sshpass net-tools ntfs-3g
```




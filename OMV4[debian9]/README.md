omv4的kvm安装脚本
替换成了国内源
dockerhub替换成了国内加速器,daocloud加速网址可自行获得.
安装了一个webui(需要提前装好docker)

#以下是安装方法和过程

就是一个openmediavault4(简称OMV是debian9_nas)整合KVM(虚拟机)的方案
文字很多但是需要动手的内容并不多
不废话直接开始

首先安装openmediavault4最新版本4.1.3
https://sourceforge.net/projects/openmediavault/files/
安装注意root密码设置,源建议选择ustc

安装完成后登入webui,
默认账号:admin
        密码:openmediavault
下载个omv_extra(omv第三方扩展)
```bash
https://bintray.com/openmediavault-plugin-developers/arrakis/download_file?file_path=pool/main/o/openmediavault-omvextrasorg/openmediavault-omvextrasorg_4.1.11_all.deb
```
把这个deb文件到插件里上传上去更新
然后在插件中安装(快捷方法 打 omvextr出现的插件就是 √点安装)
OPENMEDIAVAULT-OMVEXTRASORG


鉴于国内网络状况无论更新/安装debian和docker-ce都是很难成功,所以这里建议换国内源.如果你有酸酸乳则忽略这步
下载一个ssh客户端软件
比如
https://mobaxterm.mobatek.net/

登录你的nas
账号:root
密码:<你安装设置的>
替换下源
```bash
sudo sed -i 's|security.debian.org/debian-security|mirrors.ustc.edu.cn/debian-security|g' /etc/apt/sources.list
```


再次登录 
webui右侧
点OMV-Extras-添加
如图设置
 
其他填写内容和Docker CE一致
修改的地方
源#1密钥清空
源#2把"download.docker.com"替换成"mirrors.ustc.edu.cn"
添加后启用.
然后到插件中点"检查",在把docker-ui安装上(快捷方法打docker出现的插件就是 √点安装)



可以直接命令github下载脚本
也可以把脚本内容拷入(直接下载论坛附件也可)
```bash
"http://440d3ed3.m.daocloud.io"
```
是网络随便找的,这个可以daocloud注册得到(也可以自行寻找ustc hub源的替换方法),不注册直接用这个应该也行.
```bash
wget https://raw.githubusercontent.com/voidcode00/my_script/master/OMV4[debian9]/omv4_KVM_webui.sh
```

执行命令
```bash
chmod 750 omv4_KVM_webui.sh
```

运行脚本
```bash
./omv4_KVM_webui.sh
```

最后设置WebVirtMgr密码完成.

<nasIP>:8080
既可以登录
账号:admin
密码:脚本运行最后设置的

WebVirtMgr功能比较简陋,但是用来远程控制虚拟系统足够了.

真正管理虚拟机用
virt-manager
debian-9.5.0-amd64-xfce-CD(不过debian国内更新很难,不行就换别的linux)等上安装很简单
debian9下直接在新立得软件包管理搜virt-manager安装上即可

虚拟交换机:
不再需要openvswitch没什么用,一般直接桥接网卡即可,有特殊需求直接用virt-manager中管理新建kvm虚拟网络

宿主机和虚拟机之间通讯问题:
一般是不能直接通讯的解决方法有如下几种
1可以使用virt-manager建立隔离网络通讯
2使用某个老外的 MACVLAN.sh脚本拷贝到/root/下 其中HWLINK=enp1s0  "enp1s0 " 要改成你的网卡名称
下载中有添加rc.local脚本和MACVLAN.sh可以按需修改
3两个网口,不能通讯的意思是不能在同一个网口通讯,那么你只要有两个链接内部网络的网口网卡就可以直接通讯了.


安全问题:
安装后默认是无密码root登录管理虚拟机的,内部网络用户一般是不需要的.
这里介绍一种sas密码登录,当然还有其他方法.
/etc/libvirt/libvirtd.conf 直接跳到最后 改成
auth_tcp = "sasl"
命令参考:
```bash
apt install sasl2-bin
saslpasswd2 -a libvirt tqkm # add user tqkm
sasldblistusers2 -f /etc/libvirt/passwd.db # list users
saslpasswd2 -a libvirt -d tqkm # delete user tqkm
```
登录就用tqkm@<nas主机名默认是openmediavault>也就是
```bash
tqkm@openmediavault
```


设备开启直通命令:
```bash
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="iommu=pt intel_iommu=on"/' /etc/default/grub
update-grub
```
之后重启,然后就可以直接用virt-manager编辑PCI设备进行直通了.
AMD用户请自行百度替换intel_iommu=on词条

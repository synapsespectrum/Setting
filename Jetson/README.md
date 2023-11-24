

# Table of contents
- [JETSON ORIN NANO Specs](##jetson-orin-nano)
- [Fundamentals installation](##fundamentals-installation)
- [Control the jetson orin GUI remotely](##headless-servers)
    - [1. On Jetson Orin](###1.-on-jetson-orin)
        - [1.1. Setup VNC server on the Jetson developer kit](####1.1.-setup-vnc-server-on-the-jetson-developer-kit)
        - [1.2. Enable virtual display for VNC](####1.2.-enable-virtual-display-for-vnc)
    - [2. On LINUX Client to access Jetson remotely via VNC service](###2.-on-linux-client-to-access-jetson-remotely-via-vnc-service)


## JETSON ORIN NANO
<table border="0">
 <tr>
    <td style="width: 50%; vertical-align: top">
        <img src="https://developer-blogs.nvidia.com/ko-kr/wp-content/uploads/sites/5/2023/04/jetson-orin-nano-developer-kit-3d-render-1536x864-1.png" style="height:100%;max-height:300px;"> 
    </td>
    <td>
        Jetson Orin Nano Developer Kit:
        <br>
        - Deliver up to <b>80x</b> the performance over the Jetson Nano
        <br>
        - Supports for external <b>NVMe</b>
        <br>
        - 802.11ac/abgn wireless network interface controller
        <br>
        - <b>DisplayPort</b>
        <br> 
        - <b>AI Performance:</b> 40 TOPS
        <br>
        - <b>CPU</b>: 6-core Arm® Cortex®-A78AE v8.2 64-bit CPU 1.5MB L2 + 4MB L3
        <br>
        - <b>GPU</b>: 1024-core NVIDIA Ampere architecture GPU with 32 Tensor Cores	
        <br>
        - <b>RAM </b>: 8GB 128-bit LPDDR5
        <br>
        <b>Details: <a href="https://www.nvidia.com/en-us/autonomous-machines/embedded-systems/jetson-orin/">developer.nvidia</a>
    </td>
 </tr>
</table>

## Fundamentals installation
- Update and upgrade: `sudo apt-get update && sudo apt-get upgrade`
- Install SSH-server: `sudo apt-get install openssh-server`
- Install nano: `sudo apt-get install nano`
- Install pip: `sudo apt install python3-pip`
- Install `jtop`: `sudo pip3 install jetson-stats`
- 


## Headless Servers
> Configure VNC to control the jetson orin GUI remotely (a.k.a Headless Servers)
### 1. On Jetson Orin:
#### 1.1. Setup VNC server on the Jetson developer kit
- Step 1: Enable the VNC server to start each time you log in
```shell
mkdir -p ~/.config/autostart
cp /usr/share/applications/vino-server.desktop ~/.config/autostart/.
```

- Step 2: Configure the VNC server
```shell
gsettings set org.gnome.Vino prompt-enabled false
gsettings set org.gnome.Vino require-encryption false
```
- Step 3: Set a password to access the VNC server
```shell
gsettings set org.gnome.Vino authentication-methods "['vnc']"
gsettings set org.gnome.Vino vnc-password $(echo -n 'thepassword' | base64) # Replace thepassword with your desired password
sudo reboot # Reboot the system so that the settings take effect
```


Check detail here: [developer.nvidia.com](https://developer.nvidia.com/embedded/learn/tutorials/vnc-setup)
#### 1.2. Enable virtual display for VNC 
**Step 1: Update and install xserver-xorg-video-dummy**

This driver is used to create a virtual display, which is useful when you need a graphical environment without a physical monitor attached.

```
$ sudo apt update
$ sudo apt install xserver-xorg-video-dummy
```

**Step 2: Create config for dummy virtual display**
```
$ cd /etc/X11
$ sudo nano xorg.conf.dummy
```

**Step 3: Add the following contents in xorg.conf.dummy (resolution 1920*1080 as example)**
- Check the suitable resolution: `xrandr --verbose`
```
Section "Device"
    Identifier "DummyDevice"
    Driver "dummy"
    VideoRam 256000
EndSection
 
Section "Screen"
    Identifier "DummyScreen"
    Device "DummyDevice"
    Monitor "DummyMonitor"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        # Modes "1920x1080_60.0"
        # Modes "1280x800"
        Modes "1440x900"
    EndSubSection
EndSection
 
Section "Monitor"
    Identifier "DummyMonitor"
    HorizSync 30-70
    VertRefresh 50-75
    # ModeLine "1920x1080" 148.50 1920 2448 2492 2640 1080 1084 1089 1125 +Hsync +Vsync
    # ModeLine "1280x800" 83.5 1280 1352 1480 1680 800 803 809 831 -HSync +Vsync
    ModeLine "1440x900" 106.5 1440 1520 1672 1904 900 903 909 934 -HSync +Vsync
EndSection
```

**Step 4: Update /etc/X11/xorg.conf**
```
$ cp xorg.conf xorg.conf.backup
$ cp xorg.conf.dummy xorg.conf
```

**Step 5: Reboot the board**
```
$ sudo reboot
```

##### Discussing here: 
- [What is the best way to control the jetson Orin GUI remotely?](https://forums.developer.nvidia.com/t/what-is-the-best-way-to-control-the-jetson-orin-gui-remotely/239615/5)
- [GUIDE: Headless Remote Access on Jeston Orin Nano (and other devices using linux nVidia drivers)](https://forums.developer.nvidia.com/t/guide-headless-remote-access-on-jeston-orin-nano-and-other-devices-using-linux-nvidia-drivers/267941)


### 2. On LINUX Client to access Jetson remotely via VNC service
***Note: You’ll need to know the IP address of your Jetson developer kit to connect from another computer***
- Step 1: Install gvncviewer by executing following commands:
```shell
sudo apt update
sudo apt install gvncviewer
```
- Step 2: Launch gvncviewer
```shell
gvncviewer 192.168.1.23 # replace this IP to Jetson's IP
```
- Step 3: If you have configured the VNC server for authentication, provide the VNC password
![vnc_passwd.png](imgs%2Fvnc_passwd.png)

![gvncViewer.png](imgs%2FgvncViewer.png)

Check detail here: [developer.nvidia.com](https://developer.nvidia.com/embedded/learn/tutorials/vnc-setup)

## Setup AI environment 
### 1. Setup CUDA Environment
- Check CUDA version, "command not found" is shown, and you need to configure the following environment:  `nvcc -V`
 ```
 Note: the command "nvcc" we used here can not view the version. You can enter the /usr/local/ directory to see if there is a CUDA directory.
If not, refer to the SDK (including CUDA) installation, and then configure the environment after the installation is complete.
```
- Setup environment variables.
```shell
sudo vim .bashrc
Add the following at the end of the file:
export LD_LIBRARY_PATH=/usr/local/cuda/lib
export PATH=$PATH:/usr/local/cuda/bin
```

- Update the environment variables: `source .bashrc`
- View the CUDA version again: `nvcc -V`
```
Copyright (c) 2005-2022 NVIDIA Corporation
Built on Sun_Oct_23_22:16:07_PDT_2022
Cuda compilation tools, release 11.4, V11.4.315
Build cuda_11.4.r11.4/compiler.31964100_0
```
### 2. PyTorch on Jetson Platform
- Install system packages required by PyTorch:
```shell
sudo apt-get -y install autoconf bc build-essential g++-8 gcc-8 clang-8 lld-8 gettext-base gfortran-8 iputils-ping libbz2-dev libc++-dev libcgal-dev libffi-dev libfreetype6-dev libhdf5-dev libjpeg-dev liblzma-dev libncurses5-dev libncursesw5-dev libpng-dev libreadline-dev libssl-dev libsqlite3-dev libxml2-dev libxslt-dev locales moreutils openssl python-openssl rsync scons python3-pip libopenblas-dev;
```

Next, install PyTorch with the following steps:

- Export with the following command:



```shell
export TORCH_INSTALL=https://developer.download.nvidia.cn/compute/redist/jp/v511/pytorch/torch-2.0.0+nv23.05-cp38-cp38-linux_aarch64.whl
```
- Install PyTorch for super User:


```shell
sudo python3 -m pip install aiohttp numpy=='1.19.4' scipy=='1.5.3' export "LD_LIBRARY_PATH=/usr/lib/llvm-8/lib:$LD_LIBRARY_PATH"; python3 -m pip install --upgrade protobuf; sudo python3 -m pip install --no-cache $TORCH_INSTALL
```

- Install Torch for User's environment:

```shell
wget https://nvidia.box.com/shared/static/i8pukc49h3lhak4kkn67tg9j4goqm0m7.whl -o torch-2.0.0-cp38-cp38m-linux_aarch64.whl
```

```shell
sudo pip3 install i8pukc49h3lhak4kkn67tg9j4goqm0m7.whl
```

- Install Torchvision

```shell
git clone --branch v0.14.1 https://github.com/pytorch/vision torchvision
```

```shell
cd torchvision
export BUILD_VERSION=0.14.1
python3 setup.py install
```




Check detail: [nvidia.jetson](https://docs.nvidia.com/deeplearning/frameworks/install-pytorch-jetson-platform/index.html) 
and [waveshare.com](https://www.waveshare.com/wiki/Jetson_Orin_Nano)

# Refs:
- [developer.nvidia](https://developer.nvidia.com/embedded/learn/jetson-orin-nano-devkit-user-guide/hardware_spec.html)
- [waveshare.com](https://www.waveshare.com/wiki/Jetson_Orin_Nano)


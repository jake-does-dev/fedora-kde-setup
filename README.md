# Fedora KDE Setup

## Overview

These steps are for Fedora 40 running Plasma 6.1.4

## Notes

- Still have to run games at 120Hz, with the Adaptive Sync as `Automatic`

## Steps

### Propietary NVIDIA Driver (on 3090)

Check that the propietary NVIDIA driver has been installed - this should have happened alongside the install of Fedora 40:
```
lshw -class video
```
The output should contain this line, where `driver=nvidia` (and not `driver=nouveau`):
```
configuration: driver=nvidia latency=0
```

If this is not the case, then install the NVIDIA propietary driver using the steps outlined in RPMFusion: https://rpmfusion.org/Howto/NVIDIA

### Disable the option `nvidia.NVreg_EnableGpuFirmware` in GRUB

For me on 2024-09-18, I was having stuttering both:
- in games (Dead by Daylight tested, screen set to 120Hz with Adaptive Sync on `Automatic` in )
- for my side monitors (cursor was not at target 60Hz refresh rate, cursor looked choppy)

Firstly, amend `/etc/modprobe.d`:

```
sudo su -
touch /etc/modprobe.d/nvidia.conf

echo "options nvidia_drm modeset=1" >> /etc/modprobe.d/nvidia.conf
echo "options nvidia_drm fbdev=1" >> /etc/modprobe.d/nvidia.conf
echo "options nvidia NVreg_EnableGpuFirmware=0" >> /etc/modprobe.d/nvidia.conf
echo "options nvidia Nvreg_PreserveVideoMemoryAllocations=1" >> /etc/modprobe.d/nvidia.conf
```

Then, `vim /etc/default/grub` and ensure the following are set:
```
GRUB_CMDLINE_LINUX="rhgb quiet rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia.drm-modeset=1"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia.NVreg_EnableGpuFirmware=0"
```

Finally, *begin very careful as the below will overwrite the previously existing GRUB*, regenerate the GRUB via:
```
grub2-mkconfig -o /boot/grub2/grub.cfg
```

See: https://www.reddit.com/r/archlinux/comments/1ds6lbd/nvidianvreg_enablegpufirmware0_improves/ for more

### Audio Codecs (for AMD CPU, NVIDIA GPU)

```
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf update @sound-and-video
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
sudo dnf swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
sudo dnf swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
sudo dnf install libva-nvidia-driver
sudo dnf install libva-nvidia-driver.{i686,x86_64}
```

See: https://rpmfusion.org/Howto/Multimedia for more

### Blue Yeti Mic

Had to set the Blue Yeti microphone to `Digital Stereo Duplex (IEC958)` to get this to behave properly.

See: https://www.reddit.com/r/linuxaudio/comments/14i9du1/issue_with_blue_yeti_audio_in_fedora/ for more

Had to set the microphone up like this in `Sound`:

![image](https://github.com/user-attachments/assets/36859800-1911-419d-8d20-cae25c28a860)

Used `PulseAudio` to adjust microphone settings further (volume)

### `krunner` crashing

Occasionally, `krunner` will crash...

This workaround will restart `krunner` when it crashes: https://github.com/jake-does-dev/krunner-restarter-fedora
Forked from: https://github.com/kpostekk/krunner-restarter 


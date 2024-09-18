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

### Blue Yeti Mic

Had to set the Blue Yeti microphone to `Digital Stereo Duplex (IEC958)` to get this to behave properly.


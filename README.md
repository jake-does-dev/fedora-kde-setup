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

### Configure Focusrite Scarlett Solo

Followed the pre-requisites here: https://github.com/geoffreybennett/alsa-scarlett-gui/blob/master/docs/INSTALL.md

```
sudo dnf -y install alsa-lib-devel gtk4-devel openssl-devel
```

Then, installed (via the RPM packages available at the below links):
- the GUI: https://github.com/geoffreybennett/alsa-scarlett-gui/releases
- the latest firmware: https://github.com/geoffreybennett/scarlett2-firmware/releases

For my condenser microphone (AT2020), 48V power is required for the microphone to work - ensure this is enabled (press the button).

### EasyEffects

Available from the Software Centre

Includes a variety of helpful tools that integrate with PulseAudio for microphone control - like de-esser, de-popper, noise gate, etc.

Implemented a simple rule that includes a Noise Reduction gate, and have put this into its own preset.

### `krunner` crashing

Occasionally, `krunner` will crash...

This workaround will restart `krunner` when it crashes: https://github.com/jake-does-dev/krunner-restarter-fedora
Forked from: https://github.com/kpostekk/krunner-restarter 

### Amend SDDM (log on behaviours)

`System Settings -> Colors & Themes -> Login Screen (SDDM) -> Behavior...`

### Firefox

Can appear a little small on Linux

Fix this by going to `about:config` in the address bar, and amending the setting called `layout.css.devPixelsPerPx`:
![image](https://github.com/user-attachments/assets/1ce4d77c-0ea2-46fc-ab9a-1863f5d3b868)

### Visual Studio Code was blurry

```
alias code="code --enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform-hint=auto"
```

### HeroicGamesLauncher

Very good launcher that collates most non-Steam launchers into one app.

Can also enable MangoHud via: https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/issues/2218#issuecomment-2424283741
Can copy the MangoHud config from ~/.config/MangoHud/MangoHud.conf to ~/.var/app/com.heroicgameslauncher.hgl/config/MangoHud

### `xone`

Xbox Controller setup, follow: https://github.com/medusalix/xone

### Guitar Hero Controller

Follow: https://github.com/medusalix/xpad-noone

### Address slightly poppy audio

```
sudo grubby --args="preempt=full" --update-kernel=ALL
```

See: https://wiki.linuxfoundation.org/realtime/documentation/technical_basics/preemption_models

### SteamVR

I wasn't able to get SteamVR going for a while... got an error 496, saying that SteamVR was unable to get the DRM lease.

It seemed to have 'fixed itself' when I tried to launch SteamVR, it wouldn't work, but then I went into the software menu to 'Reset Headset'.
When I did this, my PC froze and I had to hard restart... but afterwards, everything started working again!

TODO:
- need to actually see if I can get the lighthouses to be recognised - they should be, but might need to force turn them on for their initial run (by unplugging and re-plugging).
- KDE regression causes lag in DE, see bug and fix here: https://bugs.kde.org/show_bug.cgi?id=495400, https://invent.kde.org/plasma/kwin/-/merge_requests/6756 - need to wait for release, probably KWin 6.2.4.


## 💤 Previous steps that are no longer required 💤

### Blue Yeti Mic (moved to Focusrite Scarlett Solo 4th Gen)

Do the following in the BIOS:
- enabling ErP
- disabling power management for USB devices ("wake on sleep")

Then, after re-starting the machine, the Blue Yeti should be picked up as expected.
Note: the red light never goes away, but this seems fine.


![image](https://github.com/user-attachments/assets/36859800-1911-419d-8d20-cae25c28a860)
Had to set the Blue Yeti microphone to `Digital Stereo Duplex (IEC958)` to get this to behave properly.

See: https://www.reddit.com/r/linuxaudio/comments/14i9du1/issue_with_blue_yeti_audio_in_fedora/ for more

Used `PulseAudio` to adjust microphone settings further (volume)

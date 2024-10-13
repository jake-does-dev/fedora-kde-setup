systemctl --user restart pipewire
pkill -f easyeffects
/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=easyeffects com.github.wwmm.easyeffects

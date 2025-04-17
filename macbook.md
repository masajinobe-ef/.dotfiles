#### Installing packages

> Assuming your **AUR Helper** is [Yay](https://github.com/Jguer/yay), run:

```sh
$ yay -S --needed --noconfirm \

# X11
xorg-server \
xorg-xinit xorg-xrandr xorg-xsetroot  xorg-xset \

# System
i3-wm i3status \
rofi \
alacritty zsh \
dunst libnotify \
feh picom \
chromium \

# Drivers and etc. (Intel)
mesa lib32-mesa mesa-utils xf86-video-intel xf86-input-libinput broadcom-wl \
libva libva-intel-driver libva-utils libvdpau libvdpau-va-gl \
acpid cronie auto-cpufreq brightnessctl \
networkmanager nm-connection-editor \

# File manager
xdg-user-dirs yazi imagemagick lxappearance-gtk3 \
ffmpegthumbnailer perl-image-exiftool ueberzugpp \
polkit-gnome \

# Editor
neovim \

# Media
mpv \

# CLI
tmux \
git stow \
yt-dlp ffmpeg \
fastfetch btop eza \
fzf fd ripgrep \
curl wget \
maim xdotool xclip \
xsel reflector jq poppler \

# Archiver
p7zip unrar zip unzip \

# Fonts & Icons
ttf-jetbrains-mono-nerd noto-fonts \
noto-fonts-emoji noto-fonts-cjk ttf-cascadia-code-nerd papirus-icon-theme
```

#### Blacklist, keyboard, mkinitcpio (only for macbook)

```sh
$ sudo nvim /etc/modprobe.d/blacklist.conf

blacklist ssb
blacklist mmc_core
blacklist b43
blacklist brcmsmac
blacklist brcmutil
blacklist cordic
blacklist mac80211
blacklist bcma
blacklist iTCO_wdt
blacklist iTCO_vendor_support

$ sudo modprobe wl
$ sudo nvim /etc/modprobe.d/hid_apple.conf

options hid_apple fnmode=2 iso_layout=1

$ sudo nvim /etc/mkinitcpio.conf

# add vfat to other modules for fix "Failed to mount /boot ... unknown filesystem vfat"
MODULES=(vfat)

$ sudo mkinitcpio -P
```

#### Daemons

Enable and start necessary services:

```sh
$ sudo systemctl enable sshd.service --now
$ sudo systemctl enable acpid.service --now
$ sudo systemctl enable NetworkManager.service --now
$ sudo systemctl enable cronie.service --now
$ sudo systemctl enable auto-cpufreq.service --now

$ sudo systemctl enable fstrim.timer
```

---

#### Setting-up

Adding languages to your system:

```sh
$ sudo nvim /etc/locale.gen

ru_RU.UTF-8 UTF-8

$ sudo locale-gen
```

Set the keyboard layout in X11:

```sh
$ sudo localectl --no-convert set-x11-keymap us,ru pc105+inet qwerty grp:caps_toggle
```

Configure the touchpad settings:

```sh
$ sudo nvim /etc/X11/xorg.conf.d/30-touchpad.conf

Section "InputClass"
    Identifier "touchpad"
    Driver "libinput"
    MatchIsTouchpad "on"
    Option "NaturalScrolling" "true"
    Option "Tapping" "on"
    Option "ClickMethod" "buttonareas"
    Option "AccelProfile" "adaptive"
    Option "ScrollMethod" "twofinger"
    Option "DisableWhileTyping" "true"
    Option "PalmDetection" "true"
    Option "ButtonAreas" "50% 0 100% 50% 0 0 50% 0"
    Option "TransformationMatrix" "1 0 0 0 1 0 0 0 1"
EndSection
```

Configure the mouse settings:

```sh
$ sudo nvim /etc/X11/xorg.conf.d/30-pointer.conf

Section "InputClass"
    Identifier "pointer"
    Driver "libinput"
    MatchIsPointer "on"
    Option "NaturalScrolling" "false"
    Option "AccelProfile" "flat"
    Option "TransformationMatrix" "1 0 0 0 1 0 0 0 2.0"
EndSection
```

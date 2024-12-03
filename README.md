# .dotfiles

|       OS       |               [Arch Linux](https://archlinux.org/)               |
| :------------: | :--------------------------------------------------------------: |
|   AUR Helper   |               [yay](https://github.com/Jguer/yay)                |
|     Shell      |                     [zsh](https://ohmyz.sh)                      |
| Window Manager |                  [i3](https://github.com/i3/i3)                  |
|   Compositor   |             [picom](https://github.com/yshui/picom)              |
|      Menu      |            [rofi](https://github.com/davatorium/rofi)            |
|    Terminal    |       [alacritty](https://github.com/alacritty/alacritty)        |
|  File Manager  |             [yazi/thunar](https://yazi-rs.github.io)             |
|    Browser     | [chromium](https://archlinux.org/packages/extra/x86_64/chromium) |
|  Text Editor   |                   [neovim](https://neovim.io)                    |

### Installation

#### AUR Helper

The initial installation of [yay](https://github.com/Jguer/yay).

```sh
$ sudo pacman -Syu --needed neovim reflector git base-devel
$ git clone https://aur.archlinux.org/yay.git
$ cd yay && makepkg -si
$ cd ~ && rm -rf yay
```

#### Makepkg

To speed up the compilation of packages, edit the `makepkg.conf` file (use _nproc_ for see amount of CPU cores):

```sh
$ sudo nvim /etc/makepkg.conf

MAKEFLAGS="-j16"
```

#### Pacman

Enable parallel downloading of packages by editing the `pacman.conf` file:

```sh
$ sudo nvim /etc/pacman.conf

ParallelDownloads = 8
Color
```

#### Clone repository

Clone the repository and update submodules:

```sh
$ git clone --depth=1 --recurse-submodules https://github.com/masajinobe-ef/.dotfiles
$ cd .dotfiles && git submodule update --remote --merge
```

---

#### Installing packages

> Assuming your **AUR Helper** is [yay](https://github.com/Jguer/yay), run:

```sh
yay -S --needed --noconfirm \
    xorg-server xorg-xinit xorg-xrandr xorg-xsetroot xorg-xset \
    i3-wm i3status rofi chromium alacritty zsh dunst libnotify picom feh \
    vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader \
    lib32-vulkan-icd-loader mesa mesa-utils mesa-vdpau \
    libva-mesa-driver lib32-mesa networkmanager nm-connection-editor \
    sof-firmware bluez bluez-utils acpid cronie udisks2 \
    xdg-user-dirs yazi perl-image-exiftool ueberzugpp imagemagick \
    thunar tumbler ffmpegthumbnailer polkit-gnome \
    lxappearance-gtk3 neovim mpv mpd mpdris2 ncmpcpp mpc \
    tmux ghq rainfrog syncthing git lazygit stow yt-dlp \
    ffmpeg fastfetch btop eza fzf fd ripgrep bat bat-extras \
    rsync curl wget maim xdotool xclip zoxide aria2 hyperfine \
    xsel reflector jq man-db poppler ccache go rustup nodejs \
    npm yarn p7zip unrar zip unzip ttf-jetbrains-mono-nerd \
    noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-cascadia-code-nerd \
    papirus-icon-theme
```

#### Copy configuration files

Copy the configuration files to the appropriate directories:

```sh
$ sudo chmod +x sym
$ ./sym
```

#### Daemons

Enable and start necessary services:

```sh
$ sudo systemctl disable acpid.service --now
$ sudo systemctl enable NetworkManager.service --now
$ sudo systemctl enable bluetooth.service --now
$ sudo systemctl enable sshd.service --now
$ sudo systemctl enable cronie.service --now

$ systemctl --user enable syncthing.service --now
$ systemctl --user enable mpd.service --now

$ sudo systemctl enable reflector.timer
$ sudo systemctl enable fstrim.timer
```

---

#### Setting-up

Add languages to your system:

```sh
$ sudo nvim /etc/locale.gen

ru_RU.UTF-8 UTF-8

$ sudo locale-gen
```

Set the keyboard layout in X11:

```sh
$ sudo localectl --no-convert set-x11-keymap us,ru pc105+inet qwerty grp:caps_toggle
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
    Option "TransformationMatrix" "1 0 0 0 1 0 0 0 2"
EndSection
```

Configure reflector (pacman mirrors):

```sh
$ sudo nvim /etc/xdg/reflector/reflector.conf

--save /etc/pacman.d/mirrorlist
--protocol https
--country France,Germany,Finland,Russia,Netherlands
--latest 10
--sort rate
--age 12
```

Install Oh My Zsh:

```sh
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Consider installing the following plugins for Zsh:

- [powerlevel10k](https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#oh-my-zsh)
- [zsh-autopair](https://github.com/hlissner/zsh-autopair?tab=readme-ov-file#oh-my-zsh)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#oh-my-zsh)
- [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search?tab=readme-ov-file#install)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md#oh-my-zsh)

Install **tmux-sessionizer**:

```sh
$ cargo install tmux-sessionizer
```

Install **commitizen**:

```sh
$ npm install -g commitizen cz-conventional-changelog
```

Install **nvm**:

```sh
$ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```

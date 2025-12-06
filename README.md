<!--toc:start-->

- [Install](#install)
  - [Packages](#packages)
  - [Font](#font)
  - [Sddm](#sddm)
  - [Themes and icons](#themes-and-icons)
  - [Set dconf params](#set-dconf-params)
  - [Optional](#optional)
- [Set configs via stow](#set-configs-via-stow)
- [Install mise and all dev tools](#install-mise-and-all-dev-tools)
- [Optional](#optional-1)
- [Docker](#docker)
- [Remmina](#remmina)
- [Keepassxc](#keepassxc)
<!--toc:end-->

### Install

#### Packages

```bash
/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2025.03.09_all.deb keyring.deb SHA256:2c2601e6053d5c68c2c60bcd088fa9797acec5f285151d46de9c830aaba6173c
sudo apt install ./keyring.deb
echo "deb [signed-by=/usr/share/keyrings/sur5r-keyring.gpg] http://debian.sur5r.net/i3/ $(grep '^VERSION_CODENAME=' /etc/os-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
sudo apt update
sudo apt install i3-wm picom gnome-screensaver qt5-style-kvantum qt5ct flameshot gnome-settings-daemon gnome-tweaks gnome-flashback gnome-color-manager rofi diodon xfce4-notifyd dconf-editor
sudo apt install stow
```

> - optional
>
> ```
> pavucontrol
> blueman
> nitrogen
> alacritty
> freerdp2-x11
> volumeicon-alsa
> xfce4-power-manager
> dmenu
> dunst
> network-manager-openconnect-gnome openconnect
> lxappearance
> ```

```bash
gsettings set org.gnome.gnome-flashback desktop false
gsettings set org.gnome.gnome-flashback root-background true
gsettings set org.gnome.gnome-flashback status-notifier-watcher false
gsettings set org.gnome.Terminal.Legacy.Settings confirm-close false
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power idle-brightness 0
```

```bash
sudo cp ./dist/i3.desktop /usr/share/xsessions
```

#### Font

```bash
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip
sudo mkdir -p /usr/share/fonts/CascadiaCode
sudo unzip CascadiaCode.zip -d /usr/share/fonts/CascadiaCode
sudo fc-cache -fv
```

#### Sddm

```bash
cd dist/sddm
./init.sh
```

#### Themes and icons

```bash
cd theme/dracula
sudo unzip gtk.zip -d /usr/share/themes
sudo unzip qt.zip -d /usr/share/themes
sudo unzip icons.zip -d /usr/share/icons
```

#### Set dconf params

```bash
cd dist/dconf
dconf load / < dracula_thinkpad_dconf.rc
```

#### Optional

> use this for config what you want

```bash
qt5ct
kvantummanager
gnome-tweaks
```

### Set configs via stow

```bash
stow --verbose=1 .
```

### Install mise and all dev tools

```bash
curl https://mise.run | sh
mise install
cd ~/.config/mise
pip3 install --no-cache-dir -r requirements.txt
npm install -g . --cache /dev/null --loglevel=error
pip3 cache purge
npm cache clean --force
```

### Optional

### Docker

```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update --yes
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin --yes
sudo systemctl enable docker --now
```

### Remmina

```bash
sudo apt-add-repository ppa:remmina-ppa-team/remmina-next
sudo apt update
sudo apt install remmina remmina-plugin-rdp remmina-plugin-secret
```

### Keepassxc

```bash
sudo add-apt-repository ppa:phoerious/keepassxc
sudo apt update
sudo apt install keepassxc
```

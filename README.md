# prettybox-catppuccin
This project provides a provisioned VM to show off various [Catppuccin](https://github.com/catppuccin) ports.

[Packer](https://www.packer.io/) is used to create the images and [Ansible](https://docs.ansible.com/ansible/latest/index.html) does most of the provisioning. [Vagrant](https://www.vagrantup.com/docs) boxes are produced at the end to make using the VMs easy. To use the VMs, you'll need a hypervisor. This projects aims to support [VirtualBox](https://www.oracle.com/virtualization/virtualbox/) and [QEMU with Libvirt](https://unix.stackexchange.com/questions/486301/whats-the-difference-between-kvm-qemu-and-libvirt).

Basically, each port/tool/app is installed and the Catppuccin theme is applied to it per the theme's instructions. If I use the port in my daily life, the configuration might be opinionated.

The following apps/ports are installed:
- [Alacritty](https://github.com/catppuccin/alacritty)
  - Default Flavor: `Macchiato`
  - Change in `alacritty.yml`
- [Cursors](https://github.com/catppuccin/cursors)
  - Default Flavor: `Macchiato-Mauve`
  - Change in Settings
- [Firefox](https://github.com/catppuccin/firefox)
   - Default Flavor: `Mocha`
   - Use Firefox extension marketplace to change
- Fonts
  - Default: System font
  - Change `ansible/roles/fonts/defaults/main.yml` to pick different fonts
  - Supported fonts: `inter`
- GNOME
  - Install and enable the GNOME desktop
- [Gnome-terminal](https://github.com/catppuccin/gnome-terminal)
  - No choice in flavor
- [GTK](https://github.com/catppuccin/gtk)
  - Default flavor: Purple
  - Change by installing [RPM](https://github.com/braheezy/catppuccin-gtk-rpm) and update in Settings
- [Kitty](https://github.com/catppuccin/kitty)
  - Default flavor: `Macchiato`
  - Change in `kitty.conf`
- [Nvim](https://github.com/catppuccin/nvim)
  - Default flavor: `Macchiato`
  - Managed by `vim-plug` and set in `init.vm`
- [Spotify (handled by Spicetify)](https://github.com/catppuccin/spicetify)
  - No choice in flavor
- [VS Code](https://github.com/catppuccin/vscode)
  - No choice in flavor
- [Wallpapers](https://github.com/catppuccin/wallpapers)
  - Default: `evening-sky.png`
  - Change in Settings

# Build
Until the Vagrant boxes are publicly available for download, they'll need to be built locally first. That means installing build tools and a hypervisor.

For your distro, install the following:
- Packer
- VirtualBox or QEMU/Libvirt support
- Vagrant
  - If using QEMU/Libvirt, you'll need the [vagrant-libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt) plugin too.

Once everything is installed and you can run VMs, the Packer build command will create the Vagrant boxes. Use the `-only` flag to pick the target you want to build:

    packer build -only=*.qemu template.pkr.hcl
    packer build -only=*.vbox template.pkr.hcl

Or build them all:

    packer build -parallel-builds=1 template.pkr.hcl

# Usage
After a successful build, Vagrant can be used to launch the VM.

    vagrant up


# Known Issues
- **VirtualBox**
  - I think it's a bug with Fedora but the session in VirtualBox will often freeze and "reset", especially when moving windows around quickly. The behavior seems a bit better if X11 is used instead of Wayland, which can be set at the greeter when logging in.

# Why?
I like automating things and I like Catppuccin. I was already using several ports and had automated the setup of them so I figured I should start throwing them all in single machine.

Port/theme maintainers might like this project as a test platform.

Port/theme users might like this project to test drive ports before installing.

# Future Work
In order to run more ports, there needs to be support for different types of machines:
- More OSes:
  - Debian
  - Windows
  - ???
- More desktops:
  - KDE
  - XFCE
  - ???

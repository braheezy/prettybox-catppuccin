source "vagrant" "qemu" {
  source_path = "generic/fedora35"
  provider = "libvirt"
  output_dir = "qemu"
}

source "vagrant" "vbox" {
  source_path = "generic/fedora35"
  provider = "virtualbox"
  output_dir = "vbox"
}

build {
  sources = ["source.vagrant.qemu", "source.vagrant.vbox"]

  # Do bulk of provisioning
  provisioner "ansible" {
    playbook_file = "base.yml"
    extra_arguments = [
      "--extra-vars", "desktop=${var.desktop}"
    ]
  }
}

variable "desktop" {
  type = string
  default = "gnome"
}

variable "iso_url" {
  type = string
  default = "https://dl.fedoraproject.org/pub/fedora/linux/releases/35/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-35-1.2.iso"
}

variable "iso_checksum" {
  type = string
  default = "85d9d0c233d560e401e2ad824aa8e6d5614e8b977dfe685396bfb2eb3ba5b253"
}

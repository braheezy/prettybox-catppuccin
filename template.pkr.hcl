source "vagrant" "qemu" {
  communicator = "ssh"
  source_path = "generic/fedora35"
  provider = "libvirt"
}

source "vagrant" "vbox" {
  communicator = "ssh"
  source_path = "generic/fedora35"
  provider = "virtualbox"
  vagrantfile_template = "Vagranfile_build_template"
}

build {
  sources = ["source.vagrant.qemu", "source.vagrant.vbox"]

  # Required for ansible-local provisioners
  provisioner "shell" {
    inline = ["sudo yum install -y ansible python3-psutil cowsay",
              "ansible-galaxy collection install community.general"]
  }

  # Do bulk of provisioning
  provisioner "ansible-local" {
    playbook_files = ["ansible/base.yml", "ansible/catppuccin.yml"]
    playbook_dir = "ansible"
    command = var.ansible_command
    extra_arguments = [
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3",
      "--extra-vars", "desktop=${var.desktop}"
    ]
  }

  provisioner "shell" {
    inline = ["sudo reboot"]
    expect_disconnect = true
    pause_before = "10s"
    pause_after = "20s"
    start_retry_timeout = "10m"
  }

  # These need an active GUI session running to work, which
  # is true after the reboot above.
  provisioner "ansible-local" {
    playbook_file = "ansible/gui_cats.yml"
    command = var.ansible_command
    playbook_dir = "ansible"
    extra_arguments = [
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3"
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

# Changing the called command seems to be the only way to inject Ansible ENV vars
variable "ansible_command" {
  type = string
  default = "ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ANSIBLE_COW_SELECTION=hellokitty ansible-playbook"
}

# -*- mode: ruby -*-
# vi: set ft=ruby :

CPUS = 2
MEMORY = 4096
NAME = "catppuccin-f35"

Vagrant.configure("2") do |config|
  config.vm.box = "generic/fedora35"

  config.vm.define NAME
  config.vm.hostname = NAME

  config.vm.provider :virtualbox do |vb, override|
    vb.name = NAME
    vb.cpus = CPUS
    vb.memory = MEMORY
    vb.gui = true
    vb.linked_clone = true

    override.vm.synced_folder ".", "/vagrant", disabled: false, automount: true

    vb.customize ["modifyvm", :id, "--clipboard-mode", "bidirectional"]

    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
  end

  config.vm.provider :libvirt do |l, override|
    l.driver = "kvm"
    l.cpus = CPUS
    l.memory = MEMORY
    l.disk_bus = "virtio"

    l.video_type = 'qxl'
    l.graphics_type = "spice"
    l.channel :type => 'spicevmc', :target_name => 'com.redhat.spice.0', :target_type => 'virtio'

    # l.memorybacking :access, :mode => "shared"
    override.vm.synced_folder "./", "/vagrant", disabled: false#, type: "virtiofs"

    # Enable Hyper-V enlightments: https://blog.wikichoon.com/2014/07/enabling-hyper-v-enlightenments-with-kvm.html
    l.hyperv_feature :name => 'relaxed', :state => 'on'
    l.hyperv_feature :name => 'synic',   :state => 'on'
    l.hyperv_feature :name => 'vapic',   :state => 'on'
    l.hyperv_feature :name => 'vpindex', :state => 'on'
  end

  config.vm.provision "gnome", type: "shell" do |shell|
    shell.inline = <<-SCRIPT
      yum -y update
      yum makecache
      yum -y groupinstall gnome
      systemctl set-default graphical.target
    SCRIPT
    # shell.reboot = true
  end

  config.vm.provision "prerequisites", type: "shell" do |shell|
    shell.inline = <<-SCRIPT
      yum install -y ansible python3-psutil
    SCRIPT
  end

  config.vm.provision "catppuccin", type: "ansible_local" do |ansible|
    ansible.playbook = "provision.yml"
    # ansible.verbose = true
  end

  config.vm.provision "reboot", type: "shell" do |shell|
    shell.inline = "echo 'rebooting'"
    shell.reboot = true
  end

  config.vm.provision "test", type: "shell", run: "never" do |shell|
    shell.inline = "flatpak run com.spotify.Client"
    shell.privileged = false
  end

  config.vm.provision "spicetify", type: "ansible_local", run: "never" do |ansible|
    ansible.playbook = "spicetify.yml"
  end
end

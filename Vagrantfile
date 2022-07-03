# -*- mode: ruby -*-
# vi: set ft=ruby :

CPUS = 2
MEMORY = 4096
NAME = "catppuccin-f35"

Vagrant.configure("2") do |config|
  config.vm.box = "f35"

  config.vm.define NAME
  config.vm.hostname = NAME

  config.vm.provider :virtualbox do |vb, override|
    override.vm.box_url = "#{__dir__}/output-vb/package.box"

    vb.name = NAME
    vb.cpus = CPUS
    vb.memory = MEMORY
    vb.gui = true
    vb.linked_clone = true

    override.vm.synced_folder ".", "/vagrant", disabled: false, automount: true

    vb.customize ["modifyvm", :id, "--clipboard-mode", "bidirectional"]

    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vboxsvga"]
  end

  config.vm.provider :libvirt do |l, override|
    override.vm.box_url = "#{__dir__}/output-lv/package.box"

    l.driver = "kvm"
    l.cpus = CPUS
    l.memory = MEMORY
    l.disk_bus = "virtio"

    l.default_prefix = ""

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

  config.vm.provision "dots", type: "ansible_local", run: "never" do |ansible|
    ansible.playbook = "dotfiles.yml"
  end

end

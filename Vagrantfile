# -*- mode: ruby -*-
# vi: set ft=ruby :

# The resources to give the VM.
CPUS = 2
MEMORY = 4096
# The name of the VM.
NAME = "catppuccin-f35"

# If local boxes were built using Packer, toggle this to TRUE.
USE_LOCAL_BOXES = TRUE

Vagrant.configure("2") do |config|
  config.vm.box = NAME

  config.vm.define NAME
  config.vm.hostname = NAME

  config.vm.provider :virtualbox do |vb, override|
    override.vm.box_url = USE_LOCAL_BOXES ? "#{__dir__}/output-vbox/package.box" : nil

    vb.name = NAME
    vb.cpus = CPUS
    vb.memory = MEMORY
    vb.gui = true
    vb.linked_clone = true

    override.vm.synced_folder ".", "/vagrant", automount: true, disabled: true

    # Turn on clipboard between VM and host
    vb.customize ["modifyvm", :id, "--clipboard-mode", "bidirectional"]
    # Set max Video RAM for guest
    vb.customize ["modifyvm", :id, "--vram", "128"]
    # Set the preferred paravirtualization provider for the guest.
    vb.customize ["modifyvm", :id, "--paravirtprovider", "kvm"]
  end

  config.vm.provider :libvirt do |l, override|
    override.vm.box_url = USE_LOCAL_BOXES ? "#{__dir__}/output-qemu/package.box" : nil

    l.driver = "kvm"
    l.cpus = CPUS
    l.memory = MEMORY
    l.disk_bus = "virtio"

    l.default_prefix = ""

    # Use the preferred video driver
    l.video_type = 'qxl'
    # Enable sound!
    l.sound_type = 'ich9'
    # SPICE looks great and provides copy/paste too.
    l.graphics_type = "spice"
    l.channel :type => 'spicevmc', :target_name => 'com.redhat.spice.0', :target_type => 'virtio'

    # Libvirt shared folders. This requires fairly modern versions of Linux.
    l.memorybacking :source, :type => "memfd"
    l.memorybacking :access, :mode => "shared"
    override.vm.synced_folder ".", "/vagrant", type: "virtiofs", disabled: true

    # Enable Hyper-V enlightments: https://blog.wikichoon.com/2014/07/enabling-hyper-v-enlightenments-with-kvm.html
    l.hyperv_feature :name => 'relaxed', :state => 'on'
    l.hyperv_feature :name => 'synic',   :state => 'on'
    l.hyperv_feature :name => 'vapic',   :state => 'on'
    l.hyperv_feature :name => 'vpindex', :state => 'on'
  end

end

# -*- mode: ruby -*-
# vi: set ft=ruby :

# VBoxManage dhcpserver remove --ifname vboxnet0

DEFAULT_BOX="openwrt-19.07.3-x86-64.box"

Vagrant.configure(2) do |config|
  config.ssh.username = "root"
  config.ssh.password = "root"
  config.ssh.shell = "/bin/ash"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  
  config.vm.define "main" do |main|
    main.vm.box = DEFAULT_BOX
    main.vm.network "forwarded_port", guest: 80, host: 8000, auto_correct: true
    main.vm.network "forwarded_port", id: "ssh", guest: 22, host: 2222, auto_correct: true

    main.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--nic2", "hostonly"]
      v.customize ["modifyvm", :id, "--hostonlyadapter2", "vboxnet0"]
      v.customize ["modifyvm", :id, "--cableconnected2", "on"]
    end
    main.vm.provision "shell", path: "prepare_vm.sh", :args => "node_4 192.168.4.1" # first argument sets hostname, second argument the fixed ip of internal LAN
  end
  
  
  (5..6).each do |i|
    config.vm.define "node_#{i}" do |node|
      node.vm.box = DEFAULT_BOX

      node.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--nic2", "hostonly"]
        v.customize ["modifyvm", :id, "--hostonlyadapter2", "vboxnet0"]
        v.customize ["modifyvm", :id, "--cableconnected2", "on"]
        v.customize ["modifyvm", :id, "--nic3", "intnet"]
        v.customize ["modifyvm", :id, "--intnet3", "node-#{i}"] 
        v.customize ["modifyvm", :id, "--cableconnected3", "on"]
      end
      node.vm.network "forwarded_port", id: "ssh", guest: 22, host: 2200, auto_correct: true
      node.vm.provision "shell", path: "prepare_vm.sh", :args => "node_#{i} dhcp 192.168.#{i}.1" # first argument: hostname, second argument: ip of internal lan, third argument: ip of routers own access point
    end
  end
end

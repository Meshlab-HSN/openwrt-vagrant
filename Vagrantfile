# -*- mode: ruby -*-
# vi: set ft=ruby :

# VBoxManage dhcpserver remove --ifname vboxnet0

OUI_BOX="openwrt-oui"
DEFAULT_BOX="openwrt-19.07.0-x86-64"

Vagrant.configure(2) do |config|
  config.ssh.username = "root"
  config.ssh.password = "root"
  config.ssh.shell = "/bin/ash"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  
  config.vm.define "oui" do |oui|
    oui.vm.box = DEFAULT_BOX #OUI_BOX
    oui.vm.network "forwarded_port", guest: 80, host: 8000, auto_correct: true
    oui.vm.network "forwarded_port", id: "ssh", guest: 22, host: 2222, auto_correct: true

    #oui.vm.network "private_network", ip:"192.168.56.4", auto_config: false
    oui.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--nic2", "hostonly"]
      v.customize ["modifyvm", :id, "--hostonlyadapter2", "vboxnet0"]
      v.customize ["modifyvm", :id, "--cableconnected2", "on"]
      #v.customize ["modifyvm", :id, "--nic2", "nat"]
      #v.customize ["modifyvm", :id, "--nic1", "intnet"]
      #v.customize ["modifyvm", :id, "--nic3", "intnet"]
      #v.customize ["modifyvm", :id, "--intnet3", "node-4"] 
      #v.customize ["modifyvm", :id, "--cableconnected3", "off"] 
    end
    oui.vm.provision :host_shell do |host_shell|
      host_shell.inline = "sshpass -p 'root' vagrant scp ~/Dev/gsoc-vrconfig/discoveryd/src/discoveryd oui:/usr/libexec/rpcd/discoveryd && sshpass -p 'root' vagrant scp ~/Dev/gsoc-vrconfig/simpleconfig/src/libsimpleconfig.sh oui:/usr/share/libsimpleconfig.sh && sshpass -p 'root' vagrant scp ~/Dev/gsoc-vrconfig/simpleconfig/src/simpleconfig oui:/usr/libexec/rpcd/simpleconfig && sshpass -p 'root' vagrant scp ~/Dev/gsoc-vrconfig/simpleconfig/bootstrap_credentials.sh oui:/root/bootstrap_credentials.sh"
    end
    #oui.vm.provision "shell", path: "prepare_vm.sh", :args => "192.168.56.4 node-4 192.168.4.1"
    oui.vm.provision "shell", path: "prepare_vm.sh", :args => "node_4 192.168.4.1"
  end
  
  
  (5..13).each do |i|
    config.vm.define "node_#{i}" do |node|
      node.vm.box = DEFAULT_BOX

      # Create a private network, which allows host-only access to the machine
      # using a specific IP - This is taken over by openwrt as lan.
      #node.vm.network "private_network", ip:"192.168.56.#{i}", auto_config: false
      node.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--nic2", "hostonly"]
        v.customize ["modifyvm", :id, "--hostonlyadapter2", "vboxnet0"]
        v.customize ["modifyvm", :id, "--cableconnected2", "on"]
        #v.customize ["modifyvm", :id, "--nic2", "nat"]
        v.customize ["modifyvm", :id, "--nic3", "intnet"]
        v.customize ["modifyvm", :id, "--intnet3", "node-#{i}"] 
        v.customize ["modifyvm", :id, "--cableconnected3", "on"]
      end
      node.vm.network "forwarded_port", id: "ssh", guest: 22, host: 2200, auto_correct: true
      #config.vm.network "private_network" , ip: "192.168.#{i}.1", virtualbox__intnet: "node-#{i}"
      node.vm.provision :host_shell do |host_shell|
        host_shell.inline = "sshpass -p 'root' vagrant scp ~/Dev/gsoc-vrconfig/discoveryd/src/discoveryd node_#{i}:/usr/libexec/rpcd/discoveryd && sshpass -p 'root' vagrant scp ~/Dev/gsoc-vrconfig/simpleconfig/src/libsimpleconfig.sh node_#{i}:/usr/share/libsimpleconfig.sh && sshpass -p 'root' vagrant scp ~/Dev/gsoc-vrconfig/simpleconfig/src/simpleconfig node_#{i}:/usr/libexec/rpcd/simpleconfig"
      end
      node.vm.provision "shell", path: "prepare_vm.sh", :args => "node_#{i} dhcp 192.168.#{i}.1"
    end
  end
end

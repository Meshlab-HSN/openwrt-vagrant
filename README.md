# Vagrant openwrt

This project helps you to run Openwrt x86 on VirtualBox with Vagrant. 

# Running instructions

* Use the `utils/create_box.sh` to create your own vagrant box with openwrt x86 releases.
* Add the newly created box to your vagrant environment `vagrant box add utils/openwrt-19.07.0-x86-64.box --name openwrt-19.07.0-x86-64`
* Now you can run `vagrant up`
* Profit!

# Changes to the image

* The default root password has been set to `root`.
* Fake shutdown script and sudo have been installed to enable `vagrant halt` to work.
* For the main router the default WAN has been changed to eth0 and LAN to eth1 to allow vagrant to work.

# Requirements

* virtualbox
* vagrant
* vagrant-host-shell
* vagrant-scp
* sshpass
* curl
* socat
* expect
* bash

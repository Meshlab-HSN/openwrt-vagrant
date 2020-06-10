# Vagrant openwrt

This project helps you to run Openwrt x86 on VirtualBox with Vagrant. 

# Running instructions

* Optional to create your own box:
* Use the `utils/create_box.sh` to create your own vagrant box.
* Add the newly created box to your vagrant environment `vagrant box add utils/openwrt-19.07.3-x86-64.box --name openwrt-19.07.3-x86-64`
---

* If you don't want to create your own box, you can use the pregenerated: `vagrant box add openwrt-19.07.3-x86-64.box --name openwrt-19.07.3-x86-64`
* Now you can run `vagrant up`
* Log in with `vagrant ssh main` or `vagrant ssh node_5` where the number is variable.
* Profit!
---

* If Vagrant isn´t working on your PC, import the `openwrt-vagrant-main.ova` directly to Virtualbox.

# Changes to the image

* The default root password has been set to `root`.
* Fake shutdown script and sudo have been installed to enable `vagrant halt` to work.
* For the main router the default WAN has been changed to eth0 and LAN to eth1 to allow vagrant to work.

# Requirements

* virtualbox
* vagrant

### To create your own box:

* curl
* socat
* expect
* bash

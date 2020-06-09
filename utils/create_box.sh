#!/bin/bash -e
# based on: https://github.com/elventear/openwrt-in-vagrant

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERSION=19.07.3
URL="https://downloads.openwrt.org/releases/${VERSION}/targets/x86/64/openwrt-${VERSION}-x86-64-combined-ext4.img.gz"
VDI="./openwrt.${VERSION}.vdi"
VMNAME="openwrt-${VERSION}-x86-64"
OPENWRT_SRC="$DIR/.openwrt_src"
SERIAL="/tmp/openwrt-$VERSION-serial"

setup_vbox() {
    mkdir -p $OPENWRT_SRC
    
    if [ ! -f $OPENWRT_SRC/openwrt.img.gz ]
    then
        curl $URL -o $OPENWRT_SRC/openwrt.img.gz
    fi
    
    # calculate SIZE of image dynamically
    local size="`cat $OPENWRT_SRC/openwrt.img.gz | gunzip | wc -c`"
    
    # Inspired from http://hoverbear.org/2014/11/23/openwrt-in-virtualbox/
    cat $OPENWRT_SRC/openwrt.img.gz | gunzip | VBoxManage convertfromraw --format VDI stdin $VDI $size
    
    VBoxManage createvm --name $VMNAME --register
    
    VBoxManage modifyvm $VMNAME \
        --description "A VM to build an OpenWRT Vagrant box." \
        --ostype "Linux26" \
        --memory "512" \
        --cpus "1" \
        --nic1 "nat" \
        --cableconnected1 "on" \
        --nic2 "intnet" \
        --cableconnected2 "on" \
        --uart1 "0x3F8" "4" \
        --uartmode1 server "$SERIAL"
    
    VBoxManage storagectl $VMNAME \
        --name "SATA Controller" \
        --add "sata" \
        --portcount "4" \
        --hostiocache "on" \
        --bootable "on"
    
    VBoxManage storageattach $VMNAME \
        --storagectl "SATA Controller" \
        --port "1" \
        --type "hdd" \
        --nonrotational "on" \
        --medium $VDI
    
    # Start the VM
    VBoxManage startvm $VMNAME --type "headless"
}

wait_for_shutdown() {
    until $(VBoxManage showvminfo --machinereadable $VMNAME | grep -q ^VMState=.poweroff.)
    do
        sleep 1
    done

    VBoxManage modifyvm $VMNAME --uartmode1 disconnected
    vagrant package --base $VMNAME --output $VMNAME.box && VBoxManage unregistervm $VMNAME --delete
}

main() {
    setup_vbox
    "$DIR/provision.sh" "$SERIAL"
    wait_for_shutdown
}

main

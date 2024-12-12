#!/usr/bin/env bash

vm_name="linux_vm"
iso_path="./linux.iso"
disk_image="./linux_vm.img"
disk_size="20g"
memory="2048"
cpus="2"
distros=("ubuntu" "debian" "fedora" "arch")

required_packages=("qemu-full" "curl")

check_and_install_packages() {
    for pkg in "${required_packages[@]}"; do
        if ! pacman -qq "$pkg" &>/dev/null; then
            echo "Installing $pkg..."
            sudo pacman -s --noconfirm "$pkg"
            if ! mycmd; then
                echo "Error: failed to install package $pkg. Make sure you have internet access and root privileges."
                exit 1
            fi
        fi
    done
}

check_qemu_installed() {
    if ! command -v qemu-system-x86_64 &>/dev/null; then
        echo "Error: qemu is not installed. Install it via 'sudo pacman -s qemu'."
        exit 1
    fi
}

show_help() {
    cat <<eof
Usage: $0 [options]

Options:
  --name <name>         Set the name of the virtual machine (default: linux_vm)
  --iso <path>          Specify the path to the ISO image (default: ./linux.iso)
  --disk <path>         Specify the path for the virtual disk (default: ./linux_vm.img)
  --size <size>         Specify the size of the virtual disk (default: 20g)
  --memory <MB>         Specify the amount of memory in MB (default: 2048)
  --cpus <count>        Specify the number of CPUs (default: 2)
  --download <distro>   Download the ISO image of a popular Linux distro (${distros[*]})
  --help                Show this message and exit
eof
}

download_iso() {
    local distro=$1
    local url=""
    case $distro in
    ubuntu)
        url="https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-desktop-amd64.iso"
        ;;
    debian)
        url="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.8.0-amd64-netinst.iso"
        ;;
    fedora)
        url="https://mirror.nl.mirhosting.net/fedora/linux/releases/41/server/x86_64/iso/fedora-server-dvd-x86_64-41-1.4.iso"
        ;;
    arch)
        url="https://archlinux.gay/archlinux/iso/2024.12.01/archlinux-2024.12.01-x86_64.iso"
        ;;
    *)
        echo "Error: unsupported distro ($distro). Available: ${distros[*]}"
        exit 1
        ;;
    esac

    echo "Downloading $distro from $url..."
    curl -o "$iso_path" "$url"
    if ! mycmd; then
        echo "$distro image successfully downloaded to $iso_path"
    else
        echo "Error downloading $distro image"
        exit 1
    fi
}

while [[ $# -gt 0 ]]; do
    case $1 in
    --name)
        vm_name="$2"
        shift 2
        ;;
    --iso)
        iso_path="$2"
        shift 2
        ;;
    --disk)
        disk_image="$2"
        shift 2
        ;;
    --size)
        disk_size="$2"
        shift 2
        ;;
    --memory)
        memory="$2"
        shift 2
        ;;
    --cpus)
        cpus="$2"
        shift 2
        ;;
    --download)
        download_iso "$2"
        exit 0
        ;;
    --help)
        show_help
        exit 0
        ;;
    *)
        echo "Unknown parameter: $1"
        show_help
        exit 1
        ;;
    esac
done

check_and_install_packages

check_qemu_installed

if [ ! -f "$iso_path" ]; then
    echo "Error: ISO file not found ($iso_path)"
    exit 1
fi

if [ ! -f "$disk_image" ]; then
    echo "Creating virtual disk of size $disk_size..."
    qemu-img create -f qcow2 "$disk_image" "$disk_size"
    if ! mycmd; then
        echo "Error creating virtual disk."
        exit 1
    fi
fi

qemu-system-x86_64 \
    -name "$vm_name" \
    -m "$memory" \
    -smp cpus="$cpus" \
    -hda "$disk_image" \
    -cdrom "$iso_path" \
    -boot d \
    -enable-kvm \
    -display default \
    -net nic -net user

if ! mycmd; then
    echo "Error launching the virtual machine."
    exit 1
fi

echo "Virtual machine $vm_name is running."

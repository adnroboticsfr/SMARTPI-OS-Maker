#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

# shellcheck enable=requires-variable-braces
# shellcheck disable=SC2034

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

Main() {
    case "${BOARD}" in
        smartpad)
            #rotateConsole
            #rotateScreen
            #rotateTouch
            #disableDPMS
            if [[ "${BUILD_DESKTOP}" = "yes" ]]; then
                #patchLightdm
                #copyOnboardConf
                #patchOnboardAutostart
                #installScreensaverSetup
            fi
            ;;
    esac

    # Ajout des commandes apt update et installation des dépendances
    #sudo apt update
    #sudo apt upgrade -y
    sudo apt install -y \
        build-essential wget git cmake \
        python3-pip \
        python-rosinstall-generator \
        python3-colcon-common-extensions \
        python3-flake8* \
        python3-pytest python3-pytest-cov python3-pytest-repeat python3-pytest-rerunfailures \
        python3-rosdep python3-setuptools python3-vcstool \
        libcunit1-d libcunit1-dev

    # Installation de ROS 2 Humble
    #mkdir -p ~/ros2_humble/src
    #cd ~/ros2_humble

    #rosinstall_generator ros_base --deps --rosdistro humble > ros2.repos

    #vcs import src < ros2.repos

    #sudo rosdep init
    #rosdep update

    #rosdep install --from-paths src --ignore-src -y \
        --skip-keys "fastcdr #rti-connext-dds-6.0.1 urdfdom_headers" --rosdistro humble

    #cd ~/ros2_humble/
    #colcon build --symlink-install --cmake-args -DBUILD_TESTING=OFF

    #source ~/ros2_humble/install/local_setup.bash

    # Clonage et compilation de ROS 2 demo
    #mkdir -p ~/ros2_ws/src
    #cd ~/ros2_ws/src

    #git clone https://github.com/ros2/example_interfaces.git
    #git clone https://github.com/ros2/demos

    #cd ~/ros2_ws
    #colcon build --packages-up-to demo_nodes_cpp

    #source ~/ros2_ws/install/setup.bash
    #ros2 run demo_nodes_cpp talker
}

rotateConsole() {
    local bootcfg
    bootcfg="/boot/armbianEnv.txt"
    echo "Rotate tty console by default ..."
    echo "extraargs=fbcon=rotate:2" >> "${bootcfg}"
    echo "Current configuration (${bootcfg}):"
    cat "${bootcfg}"
    echo "Rotate tty console by default ... done!"
}

rotateScreen() {
    src="/tmp/overlay/02-smartpad-rotate-screen.conf"
    dest="/etc/X11/xorg.conf.d/"
    echo "Install rotated screen configuration ..."
    cp -v "${src}" "${dest}"
    echo "DEBUG:"
    ls -l "${dest}"
    echo "Install rotated screen configuration ... [DONE]"
}

rotateTouch() {
    src="/tmp/overlay/03-smartpad-rotate-touch.conf"
    dest="/etc/X11/xorg.conf.d/"
    echo "Install rotated touch configuration ..."
    cp -v "${src}" "${dest}"
    echo "DEBUG:"
    ls -l "${dest}"
    echo "Install rotated touch configuration ... [DONE]"
}

disableDPMS() {
    src="/tmp/overlay/04-smartpad-disable-dpms.conf"
    dest="/etc/X11/xorg.conf.d/"
    echo "Install rotated touch configuration ..."
    cp -v "${src}" "${dest}"
    echo "DEBUG:"
    ls -l "${dest}"
    echo "Install rotated touch configuration ... [DONE]"
}

patchLightdm() {
    local conf
    conf="/etc/lightdm/lightdm.conf.d/12-onboard.conf"
    echo "Enable OnScreen Keyboard in Lightdm ..."
    echo "onscreen-keyboard = true" | tee "${conf}"
    echo "Enable OnScreen Keyboard in Lightdm ... [DONE]"
}

copyOnboardConf() {
    echo "Copy onboard default configuration ..."
    mkdir -p /etc/onboard
    cp -v /tmp/overlay/onboard-defaults.conf /etc/onboard/
    echo "Copy onboard default configuration ... [DONE]"
}

patchOnboardAutostart() {
    local conf
    conf="/etc/xdg/autostart/onboard-autostart.desktop"
    echo "Patch Onboard Autostart file ..."
    sed -i '/OnlyShowIn/s/^/# /' "${conf}"
    echo "Patch Onboard Autostart file ... [DONE]"
}

installScreensaverSetup() {
    src="/tmp/overlay/skel-xscreensaver"
    dest="/etc/skel/.xscreensaver"
    echo "Install rotated touch configuration ..."
    \cp -fv "${src}" "${dest}"
    echo "DEBUG:"
    ls -al "$(dirname ${dest})"
    echo "Install rotated touch configuration ... [DONE]"
}

Main "$@"

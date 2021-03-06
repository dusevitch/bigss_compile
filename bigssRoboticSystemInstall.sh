#!/bin/bash

#########################################################################
# DESCRIPTION:
#   Code for installation of the BIGGS system operation of the UR robot with the attached snake.
#   Below are the repos, packages and other info included in this build script.  Builds with Ninja.
#
# INSTALLATION PREREQUISITES:
#   FTDI Drivers: https://ftdichip.com/drivers/d2xx-drivers/
#   (for slicer integration) Qt 15.5.2: https://www.qt.io/download-qt-installer
#   (for slicer integration) CMAKE 3.19.8: https://github.com/Kitware/CMake/releases/tag/v3.19.8
#
# GIT REPOS INSTALLED:
#   cisst_repos.rosinstall
#   bigss_repos.rosinstall
#   ignore_repos.rosinstall (additional but ignored repos from cisst and previous repos included for convenience)
#
# PACKAGE DEPENDENCIES INSTALLED:
#   see dependencies.txt
#
# REFERENCES/RESOURCES:
#   ros vcstool: http://wiki.ros.org/vcstool
#   vcstool description: https://github.com/dirk-thomas/vcstool
#
# OTHER INFO
#   Authors: David Usevitch (usevitch@jhu.edu), Henry Phalen(hphalen@jhu.edu)
#   File Created: 2021-10-12 15:09:34
#   Last Updated: 2021-10-21 14:09:40
# 
# INPUTS:
#   -v (optional): Version of ROS running: e.g. 'melodic' (default is melodic)
#   -b (optional): Base folder location: (default is ~/bigss)
#   -d (optional): defaults to true, set to false if you don't want to rebuild dependent packages
#
# EXAMPLE USE:
#   ./bigssRoboticSystemInstall.sh [-v melodic] [-b ~/bigss] [-d true]
#   sudo ./../bigssRoboticSystemInstall.sh -b ~/bigss -d false
#########################################################################

sudo git config --global credential.helper 'cache --timeout=1200' # TODO make time shorter here

# Read input flags
while getopts v:b:d: flag
do
    case "${flag}" in
        v) VERSION=${OPTARG};; # get version
        b) BASE_DIR=${OPTARG=~/bigss};; # get base folder name
        d) INSTALL_DEPENDENCIES=${OPTARG}
    esac
done

# Check if version or base folder name is set, if not then create default
if [ "$VERSION" = "" ]; then
    VERSION=melodic
fi

if [ "$BASE_DIR" = "" ]; then
    BASE_DIR=~/bigss
fi

if [ "$INSTALL_DEPENDENCIES" = "" ]; then
    INSTALL_DEPENDENCIES=true
fi

# Current Directory where install files are located
CURRENT_DIR=$(pwd)

#-------------------------------------- DOWNLOAD --------------------------------------
if [ "$INSTALL_DEPENDENCIES" = true ]; then

    echo "------------------INSTALLING DEPENDENCIES-------------------"
    # Install Dependencies
    apt-get update
    #for REQUIRED_PKG in {libxml2-dev libraw1394-dev libncurses5-dev qtcreator swig sox espeak cmake-curses-gui cmake-qt-gui git subversion gfortran libcppunit-dev libqt5xmlpatterns5-dev python-catkin-tools ninja-build}
    for REQUIRED_PKG in {$(cat dependencies.txt)}
    do
        PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
        echo Checking for $REQUIRED_PKG: $PKG_OK
        if [ "" = "$PKG_OK" ]; then
            echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
            apt-get install $i -y
        else
            echo "$REQUIRED_PKG Exists. Moving on."
        fi
    done
    source /opt/ros/$VERSION/setup.bash 

    # Install vcstool
    REQUIRED_PKG="python3-vcstool"
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
    echo Checking for $REQUIRED_PKG: $PKG_OK
    if [ "" = "$PKG_OK" ]; then
    echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
    curl -s https://packagecloud.io/install/repositories/dirk-thomas/vcstool/script.deb.sh | sudo bash
    apt-get install $REQUIRED_PKG
    else
        echo "$REQUIRED_PKG Exists. Moving on"
    fi
fi

# # # TODO: Test Driver Installation
# # # # MAXON Drivers Installation
# # # # TODO: check if the file is already installed
# # # echo "Installing EPOS2 Drivers to Communicate with Maxon Motors"
# # # curl -o filename https://git.lcsr.jhu.edu/bigss/drivers/-/blob/main/EPOS-Linux-Library-En.zip
# # # tar xcgf -x EPOS-Linux_Library-En.zip
# # # chmod +x install.sh
# # # sudo ./install.sh

# # TODO: Make option for installation fo slicer with the robotic system
# # TODO: Check that CMAKE version is at least 3.19.8
# # TODO: Check that qmake is at least QT 5.15.2 installed

# Create a workspace
mkdir -p $BASE_DIR/catkin_ws/src
cd $BASE_DIR/catkin_ws
source /opt/ros/$VERSION/setup.bash
catkin init
catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release


# # -------------------------------------- BUILD --------------------------------------
echo "------------------BUILDING CISST -------------------"
# run .rosinstall file
# TODO: determine which of these git files we absolutely need to run our code and remove others
cd $BASE_DIR/catkin_ws #TODO: make this navigate to correct place for rosinstall files
vcs import < $CURRENT_DIR/rosinstall_files/cisst_repos.rosinstall # TODO: change the reliant piece of this
vcs pull src

# Build cisst-saw
echo "Building CISST-SAW..........."
cd $BASE_DIR/catkin_ws/src/cisst-saw/sawConstraintController
git checkout -b bigss_dev_commit 0e604050d9fb04dce64554a471bed915e7288e87 
cd $BASE_DIR/catkin_ws
catkin build --summary
source devel/setup.bash

echo "------------------BUILDING OTHER REPOS -------------------"

# IMPORT OTHER REPOS AND BUILD
cd $BASE_DIR
vcs import < $CURRENT_DIR/rosinstall_files/bigss_repos.rosinstall --workers 1
vcs pull src # Update to install the latest versions

# Build BIGSS Util 
echo "Building BIGSS Util..........."
cd $BASE_DIR/util
mkdir build
cd build
cmake .. -GNinja -Dcisst_DIR=$BASE_DIR/catkin_ws/devel/cmake -DBIGSS_BUILD_audio=ON -DBIGSS_BUILD_bigssMath=ON  -DBIGSS_BUILD_exe=ON  -DBIGSS_BUILD_fbgInterrogator=ON -DBIGSS_BUILD_filter=ON -DBIGSS_BUILD_maxonControl=ON -DBIGSS_BUILD_maxonUI=ON -DBIGSS_BUILD_polaris=ON  -DBIGSS_BUILD_qled=ON -DBIGSS_BUILD_sharedMemory=ON -DBIGSS_BUILD_universalRobot=ON 
ninja && ninja install

# # TODO: ADD THIS FOR THE FUTURE?
# # Install BIGSS snake  
# echo "Building BIGSS snake..........."
# cd $BASE_DIR/snake
# mkdir build
# cd build
# cmake .. -GNinja -DBIGSSUtil_DIR=$BASE_DIR/util/build 
# ninja

# TODO: update with latest NLOPT version
# Install NLOPT 
echo "Installing NLOPT..........."
cd $BASE_DIR/nlopt
cmake . -GNinja -DNLopt_DIR=$BASE_DIR/nlopt/build && ninja && ninja install

# Build Universal_Robots_ROS_Driver 
# Build fmauch_universal_robot 

rm -r $BASE_DIR/catkin_ws/src/bigssRoboticSystem/bigssRoboticSystem/examples/ex_bigssRobSys_urpolclc/example_external/ur_description

cd $BASE_DIR/catkin_ws
rosdep update
sudo apt-get update
rosdep install --from-paths src --ignore-src -y

# Build bigssRoboticSystem
echo "Building bigssRoboticSystem..........."
# TODO ADD bigssRoboticSystem build functions here
cd $BASE_DIR/catkin_ws/
catkin build
sleep 1s
catkin build
sleep 1s
catkin build
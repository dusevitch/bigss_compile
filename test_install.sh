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
#   cisst-saw: https://github.com/jhu-cisst/cisst-saw
#   crtk_msgs: https://github.com/collaborative-robotics/crtk_msgs.git
#   biggs util: https://git.lcsr.jhu.edu/bigss/util.git
#   bigss snake: https://git.lcsr.jhu.edu/bigss/snake.git 
#   biggs_spine: https://git.lcsr.jhu.edu/bigss/bigss_spine.git
#   Universal Robots ROS Driver: https://github.com/UniversalRobots/Universal_Robots_ROS_Driver.git
#   fmauch_universal_robot: https://github.com/fmauch/universal_robot.git
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
#   Last Updated: 2021-10-18 12:10:44
# 
# INPUTS:
#   -v (optional): Version of ROS running: e.g. 'melodic' (default is melodic)
#   -b (optional): Base folder location: (default is ~/bigss)
#
# EXAMPLE USE:
#   sudo ./bigss_spine_install.sh [-v melodic] [-b ~/bigss_spine]
#########################################################################

# Read input flags
while getopts v:b: flag
do
    case "${flag}" in
        v) VERSION=${OPTARG};; # get version
        b) BASE_FOLDER=${OPTARG=~/bigss};; # get base folder name
    esac
done

# Check if version or base folder name is set, if not then create default
if [ "$VERSION" = "" ]; then
    VERSION=melodic
fi

if [ "$BASE_FOLDER" = "" ]; then
    BASE_FOLDER=~/bigss
fi

#-------------------------------------- DOWNLOAD --------------------------------------
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

# TODO: Make option for installation fo slicer with the robotic system
# TODO: Check that CMAKE version is at least 3.19.8
# TODO: Check that qmake is at least QT 5.15.2 installed


# Create a workspace
mkdir -p $BASE_FOLDER/catkin_ws/src
cd $BASE_FOLDER/catkin_ws
source /opt/ros/$VERSION/setup.bash 
catkin init
catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release

echo ""
echo ""
# run .rosinstall file

git config --global credential.helper 'cache --timeout=12000'
vcs import < ../../cisst_repos.rosinstall --workers 1 # TODO: change the reliant piece of this

# Update to install the latest versions
vcs pull src

# # -------------------------------------- BUILD --------------------------------------
# echo "------------------BUILDING STARTED-------------------"

# Build cisst-saw
echo "Building CISST-SAW..........."
cd $BASE_FOLDER/catkin_ws/
source /opt/ros/$VERSION/setup.bash
mkdir -p ignore_src
cd $BASE_FOLDER/catkin_ws/src
sudo mv -t ../../ignore_src sawATIForceSensor/ sawClaronMicronTracker/ sawConstraintController/ sawForceDimensionSDK/ sawOptoforceSensor/  sawUniversalRobot
cisst_DIR=$BASE_FOLDER/catkin_ws/src/cisst-saw # set cisst dir variable
#    TODO: Eventually remove crtk_msgs.git install (or at least check for it) from the .rosinstall file
catkin build --summary
source devel/setup.bash

# # TODO: Test Driver Installation
# # # MAXON Drivers Installation
# # # TODO: check if the file is already installed
# # echo "Installing EPOS2 Drivers to Communicate with Maxon Motors"
# # curl -o filename https://git.lcsr.jhu.edu/bigss/drivers/-/blob/main/EPOS-Linux-Library-En.zip
# # tar xcgf -x EPOS-Linux_Library-En.zip
# # chmod +x install.sh
# # sudo ./install.sh


# # IMPORT OTHER REPOS AND BUILD
# cd $BASE_FOLDER
# vcs import < ../bigss_repos.rosinstall --workers 1 # TODO: change the reliant piece of this
# # Update to install the latest versions
# vcs pull src

# # Build BIGSS Util 
# echo "Building BIGSS Util..........."
# cd $BASE_FOLDER/util
# mkdir build
# cd build
# cmake .. -GNinja -Dcisst_DIR=$BASE_FOLDER/catkin_ws/src/cisst-saw/cisst -DBIGSS_BUILD_audio=ON -DBIGSS_BUILD_bigssMath=ON  -DBIGSS_BUILD_exe=ON  -DBIGSS_BUILD_fbgInterrogator=ON -DBIGSS_BUILD_filter=ON -DBIGSS_BUILD_maxonControl=ON -DBIGSS_BUILD_maxonUI=ON -DBIGSS_BUILD_polaris=ON  -DBIGSS_BUILD_qled=ON -DBIGSS_BUILD_sharedMemory=ON -DBIGSS_BUILD_universalRobot=ON 
# ninja
# ninja install

# # Install BIGSS snake
# echo "Building BIGSS snake..........."
# cd $BASE_FOLDER/snake
# mkdir build
# cd build
# cmake .. -GNinja -DBIGSSUtil_DIR=$BASE_FOLDER/util/build 

# # Build bigss_spine
# echo "Building bigss_spine..........."
# cd $BASE_FOLDER/catking_ws/src/bigss_spine
# git fetch
# git checkout master
# cd $BASE_FOLDER/catkin_ws/src
# rosdep update
# rosdep install --from-paths src --ignore-src -y
# catkin build # Build the folder

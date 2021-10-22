

# Installation of the BIGSS Robotic System

This script installs the full BIGSS Robotic system and needed dependencies. 



### CURRENT DEPENDENCIES

These are not yet automatically loaded, so be sure they are installed properly on your system. ( SEE document end for install help)

* FTDI Driver

* Maxxon Control Drivers

* (not required here, but will be for future versions):

  *  Slicer 4.13
  * Qt 15.5.2
  * CMAKE 3.19.8

  

### INSTALLATION

To install clone this folder and create a new directory:

```bash
mkdir ~/bigss
```

Then include this directory as your path for the BIGSS system (will update this later to any path desired)

```bash
cd [install folder]
sudo ./bigssRoboticSystemInstall.sh -v melodic -b [path to desired folder location] [-d true]
```

An example:

```bash
cd ~/Downloads/bigssRoboticSystem/install
sudo ./bigssRoboticSystemInstall.sh -b /home/david/bigss
```

This will take some time to compile depending on your computer (~4-5 min on avg).  You will be asked for your appropriate GitLab credentials.



### DEFINITIONS

`-v` : version of ROS (melodic by default)

`-b` : base folder path (include the full path on your system just to be safe)

`-d` : set dependencies to install (true by default)



### ADDITIONS

`dependencies.txt` : add any additional dependencies here

`rosinstall_files/*.rosinstall` : add changes to repos included, such as branch or version here

- `cisst_repos.rosinstall` : cisst repos to build  (pulled first to install cisst)
- `bigss_repos.rosinstall` : biggs repos to build (pulled after cisst builds to install all other repos needed)
- `ignore_repose.rosinstall` : old repos that used in other two .rosinstall files, included for convenience



### ERRORS

Please include errors you run into in the "Issues" section so I can update this file



### TODOS

* Change Installation of bigssRoboticSystem so `catkin build` doesn't have to be run multiple times
* Working Integration with Slicer
* Checking and automatic installation of FTDI and Maxxon Controllers
* update `cisst_repos.rosinstall` to only include necessary repos (i've eliminated most, but I'm sure there are more)



-----------------------------------------------------------------------------------------------------



## INSTALLATION GUIDE FOR ADDITIONAL DEPENDENCIES

Eventually we'll remove a few of these guides as we integrate them into the script.



### FTDI DRIVER

For the  FTDI library:

* Downloads available here: https://ftdichip.com/drivers/d2xx-drivers/
* Follow the readme here to install: https://www.ftdichip.com/Drivers/D2XX/Linux/ReadMe.txt



### MAXON MOTOR DRIVER

Navigate to the BIGSS repo called drivers (https://git.lcsr.jhu.edu/bigss/drivers)

EPOS-Linux-Library-En.zip contains the drivers for EPOS2 communication with Maxon motors (used as of 2021 in BIGGS util). Unzip and run install.sh

```bash
# cd into folder of choice
unzip EPOS-Linux_Library-En.zip
chmod +775 install.sh
sudo ./install.sh
```



### SLICER 4.13



### Qt 15.5.2



### CMAKE 3.19.8


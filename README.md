# Installation of the BIGSS Robotic System

This script installs the full BIGSS Robotic system and needed dependencies. 



### CURRENT DEPENDENCIES

These are not yet automatically loaded

* FTDI Driver

* Maxxon Control Drivers

* (not required here, but will be for future versions):

  *  Slicer 4.11 ??
  * Qt 15.5.2
  * CMAKE 3.19.8

  

### INSTALLATION

To install clone this folder and create a new directory:

```bash
mkdir bigss
cd bigss
```

Then include this directory as your path for the BIGSS system (will update this later to any path desired)

```bash
sudo ./../bigssRoboticSystemInstall.sh -v melodic -b [path_to_cloned_folder]/bigss_compile/bigss [-d true]
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

  

# Installation of the BIGSS Robotic System

This script installs the full BIGSS Robotic system and needed dependencies. 



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

* Working Installation of bigssRoboticSystem

* Working Integration with Slicer

* Checking and automatic installation of FLTK and Maxxon Controllers

* update `cisst_repos.rosinstall` to only include necessary repos (i've eliminated most, but I'm sure there are more)

  

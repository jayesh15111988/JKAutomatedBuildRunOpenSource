# JKAutomatedBuildRunOpenSource
A shell script to automate cloning, pods install and running project directly into iOS simulator

I started work on this project when one day I realized that I spend too much time going through GitHub open source repos,
cloning them and running `pod install` and then opening `xcodeproj/xcworkspace`, pressing run button.

That's too much action and time, right? Yes. So I wondered what if I spent few hours building a script and then use it to do
all manual labor I am doing right now? Result is this shell script.

##Usage :

####Running from command line: 

`./automated_build.sh [Github or Gitlab URL to clone] [Device type + iOS Version] [Configuration] [Error file name]`

####Description

1. As expected, the Github or Gitlab URL of remote repository is mandatory. It is recommended you copy the `ssh` URL. 
This is required parameter. If not provided, script will show help and exit

2. Device type + iOS Version - This parameter specifies the simulator version which will be used to launch the sample project.
Script automatically installs `ios-sim` package ([Github Link](https://github.com/phonegap/ios-sim)). If you want to view
all available devices and iOS versions this package provides, you can simply type `ios-sim showdevicetypes` on the command line.
Defaults to `iPhone-6, 9.2`

3. Configuration - Refers to Debug, Staging, Release or any custom environment configuration. Unless you are debugging project
most of time time it will be `Debug`. Defaults to `Debug`

4. Error file name - Specifies the name of file where all error and debug log messages will be stored. If not specified 
defaults to `stderr.log`

Known issues and debugging tips :

1. First off, make sure the scheme under which project will run is checked as `shared`. This can be done by opening project 
manually and then going to manage schemes option. If scheme is not shared and any runnable project is not shared at all, script
will fail with error.

2. This script recursively checks for either `xcodeproj/xcworkspace` extension files in the project base folder (Excluding
Pods.xcodeproj/Pods.xcworkspace files). Hence if your project has two `xcodeproj/xcworkspace` files in different directories
and one of them is framework, this script will not be able to find `[Project_Name].app` file and hence fail.

**Hope it will help you too. Let me know if you run into any issue or unable to execute it. (Make sure you set executable
permission with command `chmod 0755 automated_build.sh` to run the script.).**

*If there are any bugs, feel free to add an issue or send a pull request.*

###Demo
![alt text][AutomatedBuildMakerDemo]

[AutomatedBuildMakerDemo]: https://github.com/jayesh15111988/JKAutomatedBuildRunOpenSource/blob/master/Demo/Automated_Script_Demo_Small.gif "Automated clone, pod install, build and run application"

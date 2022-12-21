# CANTER Processing Toolbox
This is the *CANTER Processing Toolbox* created using MATLAB's AppDesigner

The *CANTER Processing Toolbox* is a collection of different applications for the analysis, filtering and visualization of IT-AFM experimental data.

The *CANTER Processing Toolbox* currently (version 5.2.1) includes the following applications:
* Force Curve Analysis
* R² Filtering Tool
* Result Filtering Tool
* Histogram Plotting Tool
* Lateral Deflection Processing
* Sader-Method Calibration

---

## Installation Guide

1. First, download the latest release of the master branch. You can do this by either clicking on *Code* (green button in the top right corner)<br>
and select *Download ZIP* or by clicking on the latest release in the right side bar and select *download code (zip)* under *Assets*.

2. Put the downloaded zip file in a folder dedicated to the *CANTER Processing Toolbox* and unzip it.

3. To enable MATLAB to find and use the scripts, functions and apps of the *CANTER Processing Toolbox* you must add its folder and subfolders 
to the MATLAB search path.<br>Therefore, go to the *HOME* tab of the MATLAB user interface and click on *Set Path*.
In the *Set Path* window, click on *Add with Subfolders...* and select the folder where<br>all files of the *CANTER Processing Toolbox* are located.<br>
**If you cloned the repository to a local folder (instead of downloading the code as a .zip file), make sure to remove all paths including the .git folder to avoid conflicts**

4. (Optional) You can install the *CANTER Processing Toolbox* to your MATLAB Apps for easier access.<br>
Therefore, you have to:
* Start the MATLAB Editor
* Go to your *CANTER Processing Toolbox* folder and double-click on *App_Installation_File* -> *CANTER_Processing_Tool.mlappinstall*
* After the installation, you can find the *CANTER Processing Toolbox* in the App tab of your MATLAB application.

---

## Starting the CANTER Processing Toolbox

You can start the *CANTER Processing Toolbox* by either:
1. double-clicking on the *CANTER_Processing_Tool.mlapp* file located in the program folder.
2. clicking on the *CANTER_Processing_Tool* application listed under the *Apps* tab -> *My Apps*.<br>
(Only after installing the application to MATLAB - see *Installation Guide* - Step 4.)

---

## Updating the CANTER Processing Toolbox

* When a newer version is available, you can simply download all files from the repository's master branch again and replace them in the local program folder.<br>
  **You can check which version you have currently installed by clicking on _About_ in the menu bar of the application selection window!**

* To always ensure full functionality, also repeat step 3. of the *Installation Guide*.

* When you have added the application to your MATLAB applications (see step 4. of the *Installation Guide*), you also have to repeat this step.<br>
Instead of a full installation, an update prompt should be shown by MATLAB after double-clicking on the *CANTER_Processing_Tool.mlappinstall* file,<br>indicating the installed version number and the new version number.
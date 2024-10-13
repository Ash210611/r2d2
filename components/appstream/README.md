# Appstream 

## About
These are all the components that go onto the AppStream R2D2 fleet instance. Also included is the DeployAppStreamPrograms.ps1, which will automatically install all software. 

## How To Use
Run the DeploymentPackageGenerator to create the Deployment.zip (Or create manually). Move this into the ImageBuilder, and unzip it to C:\Deployment. Then run the DeployAppStreamPrograms.ps1


## How it works
Automatically installs all of the software and programs necessary to run R2D2 instance. 

## TO DO

To Do List:

- Write a DeploymentPackageGenerator. Right now Deployment.zip must be created manually
- Add Proper permissions for the RegionAndProfileSwither
- Add Deployment folder to this directory, include proper resources
- Figure out whether to include the splunk and chrome installers into source control

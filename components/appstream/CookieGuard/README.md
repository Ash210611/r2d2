# CookieGuard

## About
This program allows makes sure that all cookies are cleared and no profile and region are selected at the beginning of the session, and that the old profile is uploaded at the end of the session. 

## How To Use
Place the config.json and CookieGuard.ps1 into the C:\AppStream\SessionScripts folder. Appstream should then run it automatically 


## How it works
Works the same as the RegionAndProfileSwitcher, but with None as the Region, UTC as the timezone, and en-us as the language. New Profile is blank, and Old Profile is whatever the currently selected profile is, so it gets uploaded. 


## TO DO

To Do List:

- Test new changes to validate profiles are uploaded and cookies are cleared. 
- Make sure it supports both Profiles and No Profiles

# RegionAndProfileSwitcher

## About
This program allows the user to switch between region and profiles at runtime. Profiles allow a user to maintain a set of history and cookies. It can also be used to just switch regions and turning off the profile switch feature. 

## How To Use
Run the StartRegionAndProfileSwitcher.bat file, a GUI will pop up with a list of regions and a list of profiles (if enabled). Each list of profiles is tied to a specific region, so if Jane Doe is available in Virginia, she will not be available in Oregon, for example. 

Select the Region you would like to switch to, and select the profile you would like to use. If someone else is using the profile, it will be locked, and you will be unable to switch to it. 


## How it works
Once a new region and profile is selected, the following happens (skip profile steps if not using profiles):

- Old Profile is zipped up, uploaded to S3
- Old Profile is unlocked by removing the profile.lock file
- Cookies and Cache for Firefox and Chrome are cleared. 
- Timezone is changed to the new Region's timezone
- Language for both Browsers are changed to the new Region's main language
- New Profile is downloaded, profile.lock file is uploaded


## TO DO

To Do List:

- Test CookieGuard changes to use new proxy switcher library 
- Change the AutoDeploy to add permissions needed for the Switcher
- Change Homepage to support new history file
- More testing required

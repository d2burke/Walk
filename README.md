# Walk

This is a very simple demonstration of tracking a user's location and plotting their path on a map in iOS.  This project does not use any .nib files or Storyboards and is written in all-native Objective-C code.

![Start A Walk](http://d2burke.com/github_images/walk-1.png "Start A Walk")  ![Walking](http://d2burke.com/github_images/walk-2.png "Walking")  ![View Walk](http://d2burke.com/github_images/walk-3.png "View Walk")

**Features**

1. Finds current location
2. Start/Reset A Walk (changes title graphic from 'Walk' to 'Walking')
3. Tracks and updates location on a map view
4. Stores Lat/Long values
5. Tracks time on the walk
6. Calculates total distance
7. Displays route, distance and time when finished

**Known Issues**

- Map view on View Walk Route page does not zoom in/out properly to fit the user's path.  Need to calculate min/max lat/longs for determine best zoom level
- Back button is not custom
- No title on View Walk Route page

Written by Daniel Burke, [D2 Development](http://www.d2burke.com)
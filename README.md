# Commenter
Xcode source editor extension to convert headerdocs from "///" to "/** ... */" format and vice-versa. 


## Installation 
1. Open the project.

2. Enable target signing for both the Application and the Source Code Extension using your own developer ID.

3. Make sure the `CommenterHost` scheme is selected.

4. Product > Archive

5. Right click archive > Show in Finder

6. Right click archive > Show Package Contents

7. Drag `Product/Applications/CommenterHost.app` to your Applications folder

8. `Product/Applications/CommenterHost.app` and exit again.

9. Go to System Preferences -> Extensions -> Xcode Source Editor and enable the extension

The `Commenter` menu-item should now be available from Xcode's Editor menu.

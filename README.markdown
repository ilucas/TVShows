## About
TVShows 2 is the next version of [TVShows][tvshows], the easiest way to download your favorite shows automatically. It includes a completely rewritten codebase as well as a major overhaul of the UI and a move to System Preferences.

No actual videos are downloaded by TVShows, only torrents which require other programs to use. It is up to the user to decide the legality of using any files downloaded by this application, in accordance with applicable copyright laws of their country.

## Download

The latest build is always available in the official site:

[http://tvshowsapp.com/][tvshows]

The preference pane works in Leopard, Snow Leopard and Lion, both Intel and PPC.

## Screenshots
<a href="http://tvshowsapp.com/img/tvshows2-addshow.png">![Show List][preview-1]</a>&nbsp;&nbsp;<a href="http://tvshowsapp.com/img/tvshows2-subscriptions.png">![Subscriptions][preview-2]</a>&nbsp;&nbsp;<a href="http://tvshowsapp.com/img/tvshows2-preferences.png">![Preferences][preview-3]</a>&nbsp;&nbsp;<a href="http://tvshowsapp.com/img/tvshows2-custom.png">![Custom RSS][preview-4]</a>

## Translations
Help localize TVShows 2 into your native language! [Click here][translate] to be added to the translation team.

## Collaboration Instructions
1. Checkout the repository and all submodules:

    `$ git clone --recursive http://github.com/victorpimentel/TVShows.git`

2. The `master` branch contains the public beta codebase. Change to the `develop` branch to get the edge codebase:

    `$ git checkout develop`

3. Open the Xcode project or compile it from the terminal:

    `$ xcodebuild`

## Collaboration Notes
* You can use GitHub's forking feature to make changes and then send me a pull request. Patches or anything else also works.
* By default, the Debug configuration automatically installs TVShows into `~/Library/PreferencePanes/` each time it's built.
* Xcode 4 is preferred over Xcode 3, but it should work on both.
* Xcode 4 users will need to install first Xcode 3, then install Xcode 4 in other location. After the install, some things needs to be changed to add PPC support, [follow all these instructions][xcode4-instructions]. If you don't want/need to add that, change the target OS version and SDK in the project settings (some warnings may appear).

## Roadmap
### 2.0 Final
* Just test it, polish it and fix bugs, no new features.

### 3.0
* Convert the preference pane in a standalone app.
  * This is a final decision, it is needed for technical reasons.
  * PPC support will be removed. Leopard and therefore Intel 32 bits support will be probably removed.
* Option to download subtitles automatically.
* Option to unrar episodes when the download is finished.
* Option to update the XBMC/Plex database when the download is finished.
* Download episode names.
* Add a list view to the Subscriptions tab.
* Add a store-like view to discover new shows more easily.

## License
TVShows is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

For a copy of the GNU General Public License see &lt;[http://www.gnu.org/licenses/][license]&gt;.

[tvshows]:http://tvshowsapp.com/ "TVShows Website"
[translate]:https://webtranslateit.com/en/projects/874-TVShows/invitation_request "Help Translate TVShows 2"

[preview-1]:http://tvshowsapp.com/img/tvshows2-addshow-thumb.png "TVShows 2: Show List"
[preview-2]:http://tvshowsapp.com/img/tvshows2-subscriptions-thumb.png "TVShows 2: Subscriptions"
[preview-3]:http://tvshowsapp.com/img/tvshows2-preferences-thumb.png "TVShows 2: Preferences"
[preview-4]:http://tvshowsapp.com/img/tvshows2-custom-thumb.png "TVShows 2: Custom RSS"

[xcode4-instructions]:http://stackoverflow.com/questions/5333490/how-can-we-restore-ppc-ppc64-as-well-as-full-10-4-10-5-sdk-support-to-xcode-4/5333500#5333500 "Instructions to add PPC support for Xcode 4"

[license]:http://www.gnu.org/licenses/ "GNU General Public License"

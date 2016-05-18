## About
TVShows 3 is the easiest way to download your favorite shows automatically. It includes a completely rewritten codebase as well as a major overhaul of the UI.

No actual videos are downloaded by TVShows, only torrents which require other programs to use. It is up to the user to decide the legality of using any files downloaded by this application, in accordance with applicable copyright laws of their country.

## Download

https://github.com/ilucas/TVShows/releases/latest

## Minimum Requirements

OS X Yosemite (10.10)

## Screenshots
![TVShows 3](screenshots/TVShows3.0.0A1.png)

## Building Instructions
1. Clone the repository:

    `$ git clone https://github.com/ilucas/TVShows.git`

2. Open the Xcode workspace:

    `$ open TVShows.xcworkspace`

3. Building from the terminal:
    ```
    make build              # Build release version of application
    make install            # Build release version and install in /Application
    make clean              # Clean
    make dependences        # Prepare all prerequisites for building the app
    make archive            # Create a clean release build for distribution
    make release            # Create a clean release build for distribution and update appcast.xml
    ```

## License
TVShows is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

For a copy of the GNU General Public License see &lt;[http://www.gnu.org/licenses/][license]&gt;.

[license]:http://www.gnu.org/licenses/ "GNU General Public License"

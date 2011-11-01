# Android App Installer / Launcher Script

Installs a given Android .apk app file to any number of USB-connected Android devices.

## Usage:

	$ ./android_app_installer.rb -h

	usage: android_app_installer.rb --apk-file [APP-APK-FILE] --app-package [APP-PACKAGE]

	        --apk-file <APP-APK-FILE>    Android app .apk file
	        --app-package <APP-PACKAGE>  Android app package
	        --sdk-path <SDK-PATH>        Android SDK path
	        --launch-activity <ACTIVITY-NAME>
	                                     Android app launch activity name
	        --help                       Display this screen

## Example:

	./android_app_installer.rb --sdk-path ~/Downloads/android-sdk-mac/
	                           --apk-file CiscoStadiumVisionDemo-debug.apk
	                           --app-package "com.cisco.sv"
	                           --launch-activity "app.demo.MySplashActivity"

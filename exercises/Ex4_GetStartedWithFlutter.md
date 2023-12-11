# Exercise 4: Getting started with Flutter development

## Installing Flutter

Installing Flutter for app development is a lengthy process. You will need to install the following:

### Flutter SDK
- Follow the Flutter Dev instructions to install flutter for your preferred platform at [Flutter Dev Getting Started](https://docs.flutter.dev/get-started/install)
- Flutter can be installed on Windows, MacOS, Linux, and ChromeOS
- With Flutter SDK installation Dart SDK will also get automatically installed
- After installing FLutter SDK you will also need to add the `<path to Flutter bin>` to your environment variables


### VS Code 
- Go to the [VS Code Download](https://code.visualstudio.com/Download) section and download and install VS Code to your respective platform 
- VS Code is the recommended IDE for flutter development
- After installing, run VS Code and go to extensions. Search for `Flutter` and install the first extension in the search results
- Installing this extension will also automatically install Dart extension for VS Code

### Android Studio
- Go to [Android studio web page](https://developer.android.com/studio) and download the installation file
- Install and run Android studio
- Complete the initial setup which will also install a few other required items
- After setup, in the first welcome screen you will see `More Actions` link. Click on it and select `SDK Manager`
- In the opened Settings window select the `SDK Tools tab`
- In the long list of tools select the one that says `Android SDK Command-line Tools (latest)` and click Apply. This will install the command line tools for Android
- Before you can use Flutter, you must agree to the licenses of the Android SDK platform. FOr that do the following
- Open a command line and enter the following line and press enter
  ```flutter doctor --android-licenses``` 

### Visual Studio
- You will also need to install Visual Studio if you are developing Windows apps
- Install [Visual Studio 2022](https://visualstudio.microsoft.com/downloads/) or [Visual Studio Build Tools 2022](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
- When installing Visual Studio or only the Build Tools, you need the `Desktop development with C++` workload installed for building windows, including all of its default components.


After the above setup, you should now have all the required software and tools installed for Flutter development.

Open a command line and enter the following command to check your setup.

```
flutter doctor
```
This will then perform checks on all the installed components and will give you an output like the following.

```
[√] Flutter (Channel stable, 3.16.2, on Microsoft Windows [Version 10.0.22621.2715], locale en-US)
[√] Windows Version (Installed version of Windows is version 10 or higher)
[√] Android toolchain - develop for Android devices (Android SDK version 31.0.0)
[√] Chrome - develop for the web
[√] Visual Studio - develop Windows apps (Visual Studio Community 2022 17.2.3)
[√] Android Studio (version 4.2)
[√] VS Code (version 1.84.2)
[√] Connected device (3 available)
[√] Network resources
```
If you have any errors in any of the above components, follow the given instructions to fix those issues.

You can also run `flutter --version` to check the installed version of the Flutter and `flutter devices` to list the configured devices for running apps. 
# Exercise 4: Install Flutter and get started with PODs app development with Flutter

**Table of Contents**


- [Exercise 4: Install Flutter and get started with PODs app development with Flutter](#exercise-4-install-flutter-and-get-started-with-pods-app-development-with-flutter)
  - [Install Flutter](#install-flutter)
    - [Flutter SDK](#flutter-sdk)
    - [IDE](#ide)
    - [Android Studio (Optional)](#android-studio)
    - [Visual Studio (Optional)](#visual-studio)
    - [MacOS (Optional)](#macos)
    - [iOS (Optional)](#ios)
    - [Flutter doctor](#doctor)
  - [Test run Flutter](#test-run-flutter)
  - [Get Podnotes code](#get-podnotes-code)
  - [Make changes to the Podnotes app](#make-changes-to-the-podnotes-app)
    - [Tackle a Podnotes issue](#tackle-a-podnotes-issue)
  - [More resources](#more-resources)


This exercise provides resources to install Flutter and get started developing PODs based apps with Flutter.

You will have the opportunity to build and run the Podnotes app on your local machine, and add small features to the Podnotes app.

You do not need to run a Solid server, as the Podnotes app uses the Community Solid Server open source software running on the Solid Community AU server https://pods.solidcommunity.au


## Install Flutter<a name="install_flutter"></a>

To get setup, you will first need to install Flutter. Installing Flutter for app development is a lengthy process. You will need to install the following:

### Flutter SDK<a name="flutter-sdk"></a>
- Follow the Flutter Dev instructions to install flutter for your preferred platform at [Flutter Dev Getting Started](https://docs.flutter.dev/get-started/install)
- Flutter can be installed on Windows, MacOS, Linux, and ChromeOS
- With Flutter SDK installation Dart SDK will also get automatically installed
- After installing FLutter SDK you will also need to add the `<path to Flutter bin>` to your environment variables


### IDE<a name="ide"></a>
- VS Code is the recommended IDE for flutter development
- Go to the [VS Code Download](https://code.visualstudio.com/Download) section and download and install VS Code to your respective platform
- After installing, run VS Code and go to extensions. Search for `Flutter` and install the first extension in the search results
- Installing this extension will also automatically install Dart extension for VS Code

### Android Studio (Optional)<a name="android-studio"></a>
*Android app development only*

- Go to [Android studio web page](https://developer.android.com/studio) and download the installation file
- Install and run Android studio
- Complete the initial setup which will also install a few other required items
- After setup, in the first welcome screen you will see `More Actions` link. Click on it and select `SDK Manager`
- In the opened Settings window select the `SDK Tools tab`
- In the long list of tools select the one that says `Android SDK Command-line Tools (latest)` and click Apply. This will install the command line tools for Android
- Before you can use Flutter, you must agree to the licenses of the Android SDK platform. FOr that do the following
- Open a command line and enter the following line and press enter
  ```flutter doctor --android-licenses```

### Visual Studio (Optional)<a name="visual-studio"></a>
*Windows app development only*

- You will also need to install Visual Studio if you are developing Windows apps
- Install [Visual Studio 2022](https://visualstudio.microsoft.com/downloads/) or [Visual Studio Build Tools 2022](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
- When installing Visual Studio or only the Build Tools, you need the `Desktop development with C++` workload installed for building windows, including all of its default components.

### MacOS development (Optional)<a name="macos"></a>
*MacOS app development only*

- After installing the flutter SDK for MacOS, you will need to follow the additional [Extra Setup for MacOS](../README.md#extra_for_macos) to configure Xcode for PODs based app development.
- If you experiment errors building for macos with `flutter run -d macos`, it is likely a mismatch between your macOS version, Xcode version, and flutter version. MacOS Sonoma and more recent versions of MacOS Venturer require Xcode version >= v15.0.1, and flutter version >= 3.18. To develop flutter apps with macOS, we recommend updating to MacOS Sonoma, Xcode >= 15.0.1, and using `flutter channel beta` (flutter channel stable is awaiting updates for Xcode 15.0.1).


### iOS development (Optional)<a name="ios"></a>

- After installing the flutter SDK for MacOS including the iOS steps, you will need to follow the additional [Extra Setup for iOS](../README.md#extra_for_ios) to configure Xcode for PODs based app development.


### Flutter doctor <a name="doctor"></a>

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

*You are now ready to develop apps with Flutter.*

## Test run Flutter<a name="test_flutter"></a>

You can also check your flutter install by running the flutter demo app on your preferred device - see [Test drive flutter](https://docs.flutter.dev/get-started/test-drive?tab=terminal)


## Get Podnotes code<a name="get_podnotes"></a>

Now lets get the Podnotes project setup in your flutter development environment.

Go to [Podnotes repo](https://github.com/anusii/podnotes). You can either Clone the repo by
```
git clone https://github.com/anusii/podnotes.git
```
or you can fork it to your own GitHub account.

Now open your VS Code IDE. Go to `File -> Open Folder` and select the local podnotes directory.

*You are now ready to make changes to the Podnotes app with Flutter.*

## Make changes to the Podnotes app<a name="edit_podnotes"></a>

There are a couple of options you can use to run the Podnotes app.

**Option 1**
Open the Terminal in the VS Code (if not open by default at the bottom of the window) by going to `Terminal -> New Terminal` in the top menu bar.

Go to the `podnotes` directory and run the following command.

```
flutter run -d [your_device]
```
Add the name of the device you want the app to run on. For instance, if you want to run the app as a Windows app use the command
```
flutter run -d Windows
```
When running for the first time it will ask to setup Windows device for the app. Simply follow the steps to set that up.

**Option 2**

In the VS Code Explorer bar open the file `podnotes -> lib -> main.dart`. A play button will apear on the top right had coner of your window. Click that button and select either one of the options and the app will then run.

For the first time it will again ask for you to setup the preferred device for the app to run on.

**Editing Podnotes app**

Open the Podnotes repo in your favourite editor. You can use any editor you like.

Edit some text in the app, by searching and changing that text in your editor. Press `R` to hot restart the app to see your changes.

### Tackle a Podnotes issue<a name="podnotes_issue"></a>

Now you can have a go at contributing to an [issue in the Podnotes repo](https://github.com/anusii/podnotes/issues).

Pick an issue, create a branch, make your changes, and submit a pull request - we're excited to see your contributions!

Feel free to also log an issue, providing details of your platform and how to replicate the problem.

*Congratulations, you are now part of the Solid Community!!*


## More resources<a name="more"></a>

There are a wealth of resources online.

Solid:

- [Solid server (Togaware)](https://survivor.togaware.com/gnulinux/solid.html)
  + [Links to Solid Resources (Togaware)](https://survivor.togaware.com/gnulinux/solid-resources.html)
- [Getting started as a Solid developer (Solidproject.org)](https://solidproject.org/developers/tutorials/getting-started)
- [Solid forum (Solidproject.org)](https://forum.solidproject.org/)

Flutter:

- [Setup your editor for Flutter (flutter.dev)](https://docs.flutter.dev/get-started/editor)
- [Codelabs (flutter.dev)](https://docs.flutter.dev/codelabs)

Working with Git:

  + [Git Developer Pre-coding Workflow (Togaware)](https://survivor.togaware.com/gnulinux/git-developer-workflow.html)
  + [Git Developer Post-coding Workflow (Togaware)](https://survivor.togaware.com/gnulinux/git-developer-workflow-post-coding.html)

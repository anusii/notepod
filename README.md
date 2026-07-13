# Private and Shareable Notes

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

[![Github Docs](https://img.shields.io/badge/GitHub-Pages-green?logo=gitbook)](https://anusii.github.io/notepod)
[![GitHub Repo](https://img.shields.io/badge/GitHub-Repo-blue?logo=github)](https://github.com/anusii/notepod)
[![GitHub License](https://img.shields.io/github/license/anusii/notepod)](https://raw.githubusercontent.com/anusii/notepod/dev/LICENSE)
[![Github Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/anusii/notepod/master/pubspec.yaml&query=$.version&label=version)](https://github.com/anusii/notepod/blob/dev/CHANGELOG.md)
[![Github Last Updated](https://img.shields.io/github/last-commit/anusii/notepod?label=last%20updated)](https://github.com/anusii/notepod/commits/dev/)
[![GitHub Commit Activity (dev)](https://img.shields.io/github/commit-activity/w/anusii/notepod/dev)](https://github.com/anusii/notepod/commits/dev/)
[![GitHub Issues](https://img.shields.io/github/issues/anusii/notepod)](https://github.com/anusii/notepod/issues)

[![Get it from the Snap Store](https://snapcraft.io/en/light/install.svg)](https://snapcraft.io/notepod)

NotePod is a [solidui](https://github.com/anusii/solidui) based app to
support the secure and private storage and sharing of personal notes
on your own encrypted personal online datastore (Pod) hosted on any
[Solid Server](https://solidproject.org/about). The app was developed
by the [ANU Software Innovation Institute](https://sii.anu.edu.au) and
written by [Anushka Vidanage](https://github.com/anushkavidanage),
[Graham Williams](https://github.com/anusii), and [Jessica
Moore](https://github.com/jesscmoore).

Solid Pods are a new approach to handling your personal data on the
World Wide Web and is the latest innovation from the inventor of the
WWW, Sir Tim Berners-Lee. Obtain a Pod for yourself on any Solid
server and link it to your app.

We make this project available for free so if you appreciate the app
then please show some ❤️ and tap on the star at
[GitHub](https://github.com/anusii/notepod) to support our work. See
the [AU Solid Community](https://solidcommunity.au) **showcase** for
many more apps using the Solid ecosystem.

The latest version of the app can be run online at
[notepod.solidcommunity.au](https://notepod.solidcommunity.au) with no
installation required though requiring a Solid login, or downloaded
and installed for your platform from the [Solid Community
AU](https://solidcommunity.au) repository:

<!-- markdownlint-disable MD036 -->
+ **Web**
  [solidcommunity](https://notepod.solidcommunity.au/);
+ **Android**
  [apk](https://solidcommunity.au/installers/notepod.apk) or
  [aab](https://solidcommunity.au/installers/notepod.aab);

+ **GNU/Linux**
  [deb](https://solidcommunity.au/installers/notepod_amd64.deb) or
  [snap](https://solidcommunity.au/installers/notepod_amd64.snap) or
  [zip](https://solidcommunity.au/installers/notepod-linux.zip);
+ **macOS**
  [dmg](https://solidcommunity.au/installers/notepod-macos.dmg) or
  [zip](https://solidcommunity.au/installers/notepod-macos.zip);
+ **Windows**
  [exe](https://solidcommunity.au/installers/notepod-windows-inno.exe) or
  [zip](https://solidcommunity.au/installers/notepod-windows.zip).

[Installation
details](https://github.com/anusii/notepod/blob/dev/installers/README.md)
are available for all platforms.

Contributions are welcome. Visit
[github](https://github.com/anusii/notepod) to submit an issue or,
even better, fork the repository yourself, update the code, and submit
a Pull Request. The app is implemented in
[Flutter](https://flutter.dev) using
[solidui](https://pub.dev/packages/solidui). Thanks.

## Introduction

NotePod utilises [Solid Pods](https://solidproject.org/about) to read,
write, and share encrypted notes stored on your personal online
datastore (Pod) hosted on a [Solid
Server](https://solidproject.org/get_a_pod).  You control which server
your notes (in standard Markdown) are stored and the app ensures they
are encrypted on that server so the server host can not access your
actual notes. Because the data storage conforms to the Solid protocol
other apps can also interact with your notes, under your control. You
maintain full control over **your** data, not the app developer
collecting and hoarding **your** data, nor the host where you store
**your** data.

Solid Pods are a new approach to handling your personal data on the
World Wide Web and is the latest innovation from the inventor of the
WWW, Sir Tim Berners-Lee. Obtain a Pod for yourself on any Solid
server and link it to your app.

Use cases for NotePod include writing quick notes while on the move to
come back to later on, capturing shopping lists that can be shared
with your family and called up the next time anyone of the family is
at the shops, collecting together notes on a related topic, and much
more.

The same app runs on all platforms, including desktops and mobile devices.

A simple example of a shopping list, available anywhere, anytime.

Desktop version:

<!-- markdownlint-disable MD033 MD045 MD013 -->
<img
src="https://raw.githubusercontent.com/anusii/notepod/dev/assets/screenshots/shopping.png" width=600>

Mobile Phone version:

<img
src="https://raw.githubusercontent.com/anusii/notepod/dev/assets/screenshots/shopping_android.png" width=300>
<!-- markdownlint-enable MD033 MD045 MD013 -->

## Obtaining a Pod

To use the app you will need your own Pod hosted on a Solid server. To
try it out you can get yourself a Pod at our **experimental** server,
the [Australian Solid Community Pod
Server](https://pods.solidcommunity.au) or any one of the available
[Pod Providers](https://solidproject.org/get-a-pod) world wide.

## Online Demo

Once you have your own Pod visit
[https://notepod.solidcommunity.au](https://notepod.solidcommunity.au)
and login to your Pod. Be sure to update the default Solid Server
listed on the login page. Write and save a few notes, edit saved
notes, and maybe share some notes with other users. Access your notes
from your desktop or mobile device. That's it! Simple but useful.

## Install the App Locally

You can install the app onto your own device from your device's
software repository or directly by using one of our installers. The
app will then run locally on your own device rather than hosted on the
web server. The installers are available for all platforms from
[github](https://github.com/anusii/notepod/blob/dev/README.md).

## App Startup

On starting up the app you will see the login screen where a user's
WebID is to be entered. The app itself does not know your login
details. That is handled by a remote Identify Provider of your choice.

![login](https://raw.githubusercontent.com/anusii/notepod/dev/assets/screenshots/login.png)

## Contribute to the NotePod Flutter App

As a developer you can run the app directly from its software source
code yourself with a little setup. You can then modify the app to suit
your own needs, or to add functionality that you may like to
contribute back to the community.

To begin you will install Flutter following the instructions for your
preferred platform at [Flutter Dev Getting
Started](https://docs.flutter.dev/get-started/install)

After setting up Flutter run `flutter doctor` to check your setup, and
then run `flutter devices` to see which devices you have configured:

<!-- markdownlint-disable MD013 -->
```console
flutter devices
Found 4 connected devices:
  iPhone 15 Pro Max (mobile)      • 8978937B-AC64-44B8-8B26-CA6142091678 • ios            • com.apple.CoreSimulator.SimRuntime.iOS-17-0 (simulator)
  iPad (10th generation) (mobile) • 6B849753-743F-4F66-8F46-0396CA4BCFBE • ios            • com.apple.CoreSimulator.SimRuntime.iOS-17-0 (simulator)
  macOS (desktop)                 • macos                                • darwin-arm64   • macOS 14.1.2 23B92 darwin-arm64
  Chrome (web)                    • chrome                               • web-javascript • Google Chrome 120.0.6099.62
```
<!-- markdownlint-enable MD013 -->

You can then `git clone https://github.com/anusii/notepod` to clone a
local copy of the software source code. You can run the notepod app in
debug mode on your chosen device by specifying enough of the device
name to be uniquely identifiable. E.g. for chrome use:

```shell
flutter run -d chrome
```

When you have completed the setup of your platform you are ready for
the [NotePod Getting
Started](https://github.com/anusii/solidui/blob/dev/exercises)
exercises where you can create a Pod to then make and share notes.

### Extra setup for MacOS/iOS

This project uses a human readable `project.yml` in macos and ios folders, where
 Xcode build configuration files are generated automatically with
 `xcodegen generate`. To alter the build configuration for macos or ios, edit
 `project.yml` in macos/ios folder, re-run xcodegen to generate updated build
 configuration and update native pods with `pod install`, before building or
 running the flutter app. The script `update_project.sh` performs these steps
 and aligns Podfile with Xcode build config, so after a build config change, do:

```bash
bash update_project.sh [macos/ios]
flutter run [--debug -d macos]
```

For iOS, the deployment target in iOS project.yml will need to support the iOS
verison of your physical or simulated iOS device.

## Useful resources

Packages:

These dart packages are under construction to support the development
of Pods-based apps with flutter

+ [solidpod](https://pub.dev/packages/solidpod) package: Provides
  high level functionality to manage a Solid personal online data
  stores (Pods) via a Flutter application.

+ [solid-auth](https://pub.dev/packages/solid_auth) package:
  Implementation of the Solid-OIDC flow which can be used to
  authenticate a client application to a Solid Pod. Solid OIDC is
  built on top of OpenID Connect 1.0. Also provides a suite of tools
  and widgets to support typical app workflows.

+ [solid-encrypt](https://pub.dev/packages/solid_encrypt) package: The
  Software Innovation Institute has a focus on the security of our
  stored data. This package implements data encryption which can be
  used to encrypt, on device, the content of turtle files to be stored
  in a Solid Pod. Data is also only decrypted on device.

+ [rdflib](https://pub.dev/packages/rdflib) package: A dart package
  for working with RDF. Features include find and create triple
  instances, create a graph to store triples, export graph to ttl,
  etc.

## Related Apps

[https://notepod.vincenttunru.com/](https://notepod.vincenttunru.com/)

<!-- markdownlint-disable MD036 -->
*Time-stamp: <Thursday 2026-07-09 08:47:54 +1000 Graham Williams>*
<!-- markdownlint-enable MD036 -->

<!-- markdownlint-disable MD053 -->
[comment]: # (Local Variables:)
[comment]: # (time-stamp-line-limit: -8)
[comment]: # (End:)
<!-- markdownlint-enable MD053 -->

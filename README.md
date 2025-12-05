# Private and Shareable Notes

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

[![GitHub](https://img.shields.io/badge/GitHub-Repository-blue?logo=github)](https://github.com/anusii/notepod)
[![GitHub License](https://img.shields.io/github/license/anusii/notepod)](https://github.com/anusii/notepod?tab=GPL-3.0-1-ov-file)
[![Flutter Version](https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/anusii/notepod/master/pubspec.yaml&query=$.version&label=version)](https://github.com/anusii/notepod/blob/dev/CHANGELOG.md)
[![Last Updated](https://img.shields.io/github/last-commit/anusii/notepod?label=last%20updated)](https://github.com/anusii/notepod/commits/dev/)
[![GitHub commit activity (dev)](https://img.shields.io/github/commit-activity/w/anusii/notepod/dev)](https://github.com/anusii/notepod/commits/dev/)
[![GitHub Issues](https://img.shields.io/github/issues/anusii/notepod)](https://github.com/anusii/notepod/issues)
[![Build Installers](https://github.com/anusii/notepod/actions/workflows/installers.yaml/badge.svg)](https://github.com/anusii/notepod/actions/workflows/installers.yaml)

[![Get it from the Snap Store](https://snapcraft.io/en/light/install.svg)](https://snapcraft.io/notepod)

NotePod is a [solidui](https://github.com/anusii/solidui) based app to
support the secure and private storage and sharing of personal notes
on your own encrypted personal online datastore (Pod) hosted in your
Data Vault on a [Solid Server](https://solidproject.org/about). The
app was developed by the [ANU Software Innovation
Institute](https://sii.anu.edu.au) and written by [Anushka
Vidanage](https://github.com/anushkavidanage), [Graham
Williams](https://github.com/gjwgit), and [Jessica
Moore](https://github.com/jesscmoore).

If you appreciate the app then please show some ❤️ and star the [GitHub
Repository](https://github.com/anusii/notepod) to support the
project.  You can install the app from different repositories
including [SnapCraft](https://snapcraft.io/notepod) for Linux.

The latest version of the app can be run online at
[notepod.solidcommunity.au](https://notepod.solidcommunity.au) with no
installation required, or downloaded and installed for your platform
from the [Solid Community AU](https://solidcommunity.au) repository:

<!-- markdownlint-disable MD013 -->
+ **Web**
  [solidcommunity](https://notepod.solidcommunity.au/);
+ **Android**
  [apk](https://solidcommunity.au/installers/notepod.apk);
+ **GNU/Linux**
  [snap](https://solidcommunity.au/installers/notepod_amd64.snap) or
  [deb](https://solidcommunity.au/installers/notepod_amd64.deb) or
  [zip](https://solidcommunity.au/installers/notepod-dev-linux.zip);
+ **macOS**
  [dmg dev](https://solidcommunity.au/installers/notepod-dev-macos-staging.dmg) or
  [dmg staging](https://solidcommunity.au/installers/notepod-dev-macos-staging.dmg) or
  [dmg unsigned](https://solidcommunity.au/installers/notepod-dev-macos-unsigned.dmg) or
  [zip unsigned](https://solidcommunity.au/installers/notepod-dev-macos-unsigned.zip);
+ **Windows**
  [zip](https://solidcommunity.au/installers/notepod-dev-windows.zip) or
  [inno](https://solidcommunity.au/installers/notepod-dev-windows-inno.exe).
<!-- markdownlint-enable MD013 -->

Contributions are welcome. Visit
[github](https://github.com/anusii/notepod) to submit an issue or,
even better, fork the repository yourself, update the code, and submit
a Pull Request. The app is implemented in
[Flutter](https://flutter.dev) using
[solidpod](https://pub.dev/packages/solidpod) for Flutter to manage
the Solid Pod interactions. Thank you.

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

This first beta release (version 0.1.0) is functional and usable. Use
cases include writing quick notes while on the move to come back to
later on, capturing shopping lists that can be shared with your family
and called up the next time anyone of the family is at the shops, and
much more.

The current notepod code base includes a lot of low level code that
is being migrated to the
[solidpod](https://github.com/anusii/solidpod) package for
[Flutter](https://pub.dev/packages/solidpod). Once migrated it will be
even easier to build your first Pods-based Flutter app.

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

When you have completed the setup of your platform, you are ready for
the [NotePod Getting Started](exercises/README.md) exercises where
you can create a Pod, make and share notes.

### Extra setup for MacOS

Building and signing the app on MacOS requires, additional
configuration in Xcode. Open the project macos folder in Xcode with

```shell
cd notepod/macos
xed .
```

Select `Signing & Capabilities`. In `Team`, choose `Add an Account`
and sign in with your Apple ID account. In `Network`, select `Incoming
Connections (Server)` and `Outgoing Connections (Client)`. The latter
is needed to login to your Pod. Keychain access capability is also
required to save authorisation and encryption key credentials to
secure storage. Macos app builds must use be signed with a valid developer
certificate in order to add the keychain access capability required for
local secure key storage.

Edit `macos/Runner/DebugRunner.entitlements` to add:

```xml
 <key>keychain-access-groups</key>
    <array/>
```

Edit `macos/Runner/DebugProfile.entitlements` and
`macos/Runner/Release.entitlements` to add:

```xml
 <array>
        <string>$(AppIdentifierPrefix)PRODUCT_BUNDLE_IDENTIFIER</string>
    </array>
```

where `PRODUCT_BUNDLE_IDENTIFIER` found in
`macos/Runner/Configs/AppInfo.xcconfig`, e.g. `$(AppIdentifierPrefix)com.mycompany.myapp`.

### Extra setup for iOS

For iOS, you will also need to set the deployment platform to match
the iOS version on your simulator.

Open the Simulator app, select your simulated device with `File` ->
`Open Simulator` -> pick a device.

```shell
open -a Simulator
```

Then in the simulated device check the iOS version number by clicking
on the `Settings`app and going to `General` -> `About` to look up the
iOS.

Open the project iOS folder in Xcode and add the iOS version used by
your simulator.

```shell
cd notepod/ios
xed .
```

Select `General`. In `iOS`, change it to match the Simulator iOS
version, e.g. `v17.0`.

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
*Time-stamp: <Saturday 2025-12-06 09:46:53 +1100 Graham Williams>*
<!-- markdownlint-enable MD036 -->

<!-- markdownlint-disable MD053 -->
[comment]: # (Local Variables:)
[comment]: # (time-stamp-line-limit: -8)
[comment]: # (End:)
<!-- markdownlint-enable MD053 -->

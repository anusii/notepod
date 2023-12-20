# PodNotes Markdown Note Taking App with Private PODs

**An ANU Software Innovation Institute demo project for Solid PODs**.

*Authors: Anushka Vidanage, Graham Williams, Jessica Moore*

*[ANU Software Innovation Institute](https://sii.anu.edu.au)*

*License: GNU GPL V3*

## Introduction

The podnotes app aims to be a template for apps that interact (read
and write) with encrypted data stored on personal online data stores
(PODs) hosted on a Solid Server. The intention is that you can use
this code as the starting point for your own app development project.

The first beta release (version 0.1.0) included much low level
code. Over the 7000 lines of code there is much that is being migrated
into the suite of solid packages for dart and flutter with the aim to
reduce the programmer's burden to less than 1000 lines of code for a
useful app.

## Online Demo

To use the app you will need a POD hosted on a solid server. You can
get yourself a POD at https://pods.solidcommunity.au or any other Solid
server.

Then visit https://podnotes.solidcommunity.au and login to your
POD. Write and save a few notes, edit saved notes, and maybe share
some notes with other users. That's it! It is intended as a simple but
useful demonstrator app and template.

## Install

Installers to install the app to run locally on your own device are
available for all platforms from <a
href="https://github.com/anusii/podnotes/tree/main/installers">github</a>. Generally,
these are ready to run executable files, or operating system specific
installation packages.

## App Startup

On starting up the app you will see the login screen where a user's
WebID is to be entered. It will be remembered for future app
activity.

To obtain a WebID for yourself, visit our experimental
[Australian Solid Community Pod
Server](https://pods.solidcommunity.au/.account/login/password/register/)
or any one of the available [Pod
Providers](https://solidproject.org/users/get-a-pod) world wide.

On clicking the Login button your browser will popup to authenticate you
on the Solid server of choice, not on the device. The device does not
get to know your login details.

<div align="center">
	<img
	src="images/login.png"
	alt="Login Screen" width="400">
</div>

## Install Flutter and Podnotes<a name="install"></a>

Follow the Flutter Dev instructions to install flutter for your
preferred platform at [Flutter Dev Getting
Started](https://docs.flutter.dev/get-started/install)

After setup, run `flutter doctor` to check your setup, and `flutter
devices` to see which devices you have configured, with the device
name in the 2nd column

```
flutter devices
Found 4 connected devices:
  iPhone 15 Pro Max (mobile)      • 8978937B-AC64-44B8-8B26-CA6142091678 • ios            • com.apple.CoreSimulator.SimRuntime.iOS-17-0 (simulator)
  iPad (10th generation) (mobile) • 6B849753-743F-4F66-8F46-0396CA4BCFBE • ios            • com.apple.CoreSimulator.SimRuntime.iOS-17-0 (simulator)
  macOS (desktop)                 • macos                                • darwin-arm64   • macOS 14.1.2 23B92 darwin-arm64
  Chrome (web)                    • chrome                               • web-javascript • Google Chrome 120.0.6099.62
```

Git clone the Podnotes app.

Run the podnotes app in debug mode on your chosen device by specifying
enough of the device name to be uniquely identifiable. E.g. for chrome
use:

```
flutter run -d chrome
```

When you have completed the setup of your platform, you are ready for
the [PodNotes Getting Started](exercises/README.md) exercises where
you can create a POD, make and share notes.

### Extra setup for MacOS<a name="extra_for_macos"></a>

Running the app on MacOS requires, additional configuration in
Xcode. Open the project macos folder in Xcode with

```
cd podnotes/macos
xed .
```

Select `Signing & Capabilities`. In `Team`, choose `Add an Account`
and sign in with your Apple ID account. In `Network`, select `Incoming
Connections (Server)` and `Outgoing Connections (Client)`. The latter
is needed to login to your POD.

### Extra setup for iOS<a name="extra_for_ios"></a>

For iOS, you will also need to set the deployment platform to match
the iOS version on your simulator.

Open the Simulator app, select your simulated device with `File` ->
`Open Simulator` -> pick a device.

```
open -a Simulator
```

Then in the simulated device check the iOS version number by clicking
on the `Settings`app and going to `General` -> `About` to look up the
iOS.

Open the project iOS folder in Xcode and add the iOS version used by
your simulator.

```
cd podnotes/ios
xed .
```

Select `General`. In `iOS`, change it to match the Simulator iOS
version, e.g. `v17.0`.


## Useful resources

Packages:

These dart packages support development PODs-based apps with flutter

- [solid-core](https://pub.dev/packages/solid_core) package:
  Implementation of the core support functionality.
  
- [solid-auth](https://pub.dev/packages/solid_auth) package:
  Implementation of the Solid-OIDC flow which can be used to
  authenticate a client application to a Solid POD. Solid OIDC is
  built on top of OpenID Connect 1.0. Also provides a suite of tools
  and widgets to support typical app workflows.

- [solid-encrypt](https://pub.dev/packages/solid_encrypt) package: The
  Software Innovation Institute has a focus on the security of the
  stored data. This package implements data encryption which can be
  used to encrypt, on device, the content of turtle files to be stored
  in a Solid POD. Data is then only decrypted on device.

- [rdflib](https://pub.dev/packages/rdflib) package: A dart package
  for working with RDF. Features include find and create triple
  instances, create a graph to store triples, export graph to ttl,
  etc.

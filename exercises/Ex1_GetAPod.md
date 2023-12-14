# Exercise 1: Get a POD and login to Podnotes app

**Table of Contents**

- [Setup](#setup)
- [Get a POD](#get_pod)
- [Login and set master encryption key](#set_encrypt)

This exercise will show you how to create a POD on the solid server host https://solidcommunity.au/ and how to use the Podnotes app to create and save notes to your POD.

## Setup<a name="setup"></a>

**Option 1:** Open the Podnotes app using the web app or download links for the binary for your OS:

- [Podnotes web app](https://Podnotes.solidcommunity.au/)

Using Flutter framework, we can build apps for multiple platforms with a single codebase.

Go to [Downloads](https://github.com/anusii/podnotes/tree/main/installers) to get the Podnotes app binaries for your platform:

- Podnotes.dmg (Mac)
- Podnotes.exe (Windows)
- Podnotes.apk (Android)
- Podnotes.deb (Linux) *(Coming soon)*


**Option 2:** If you already have `flutter` installed and setup to build to `chrome` or desired platform (Linux, MacOS, Windows, Android, iOS), you may build and run the Podnotes app locally on your machine.

```
flutter devices
flutter run -d [your device]
```

**Option 3:** Follow the instructions in [Exercise 4 Getting Started - PODs app development with Flutter](Ex4_PODsAppDevGettingStarted.md) to install `flutter` and then run the app locally on your machine as in Option 2.


## Get a POD<a name="get_pod"></a>

The Podnotes app requires you to have a POD hosted on any solid server, which is identified on the internet with a webID comprising the unique resource identifier (URI) of your POD. We have setup a solid server for the Solid AU Community for experimenting with Solid. You can use this solid server to get a POD if you don't have one on any Solid server.


Open [Podnotes app](https://Podnotes.solidcommunity.au/) and click `Get a POD`.

![Get a POD](../assets/images/podnotes_get_a_pod.png)

This will take you to https://pods.solidcommunity.au, click `Sign up for an account`

Enter an email address, and the password you want to use to access your POD and click `Register`.

![Enter POD email and password](../assets/images/server_create_account.png)

This will take you to an POD account view window, click `Create pod`.

![POD account view](../assets/images/server_get_a_pod.png)

In the `Name` field, enter a name for your POD, eg the username of your email address.

If you already have a Solid webID, you can link your webID to your new POD on Solid Community AU, by selecting `Use an external webID`.

Click `Create POD` to start creating a POD on the host https://solidcommunity.au.

If you don't yet have a Solid webID, select `Use the webID in POD and register it to your account`.

Confirm by clicking `Create POD`.

![Choose POD name and webID](../assets/images/server_choose_pod_name.png)

You should see a window, with the URL of your POD and your webID.

Note: to look up your webID at anytime, login to https://pods.solidcommunity.au/



## Login and set master encryption key<a name="set_encrypt"></a>

The Podnotes app stores your files in encrypted form. To do this you must create a password to use as the master key for encrypting your POD files.
The first time you login in to the Podnotes app, you need to set the master encryption key. Your files are only decrypted in the app. Each time you subsequently login, you will need to provide the master encryption key after app login to see your files.

Open [Podnotes app](https://Podnotes.solidcommunity.au/) and click `Login`.

This may show you a Community Solid Server login pop up if you are not already logged in to your POD on https://pods.solidcommunity.au.

![POD login](../assets/images/server_login_popup.png)

If you have recently logged in to your POD on this Solid servier, you will see a  Community Solid Server authorization pop up with the last credentials which you've used on the Solid Community AU host.

Click `Authorize` to login to your POD in the Podnotes app.

![POD authorization](../assets/images/server_pod_auth_popup.png)

This will take you to the Podnotes Setup Wizard to finish setting up your POD. This shows the resources (files) being created in your POD on the Solid Community AU solid server, and ask you to set an master encryption key which will be used to encrypt the notes on your POD.

![PODnotes setup wizard](../assets/images/pod_wizard.png)

Enter your name and gender.

Enter a new password to use as your master encryption key for this POD.

Click the confirm checkbox and click `Submit`.

You are now setup and logged in the Podnotes app.

Repeat login to the Podnotes app will typically remember your pod webID in the Authorize window.

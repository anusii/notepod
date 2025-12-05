<!-- markdownlint-disable MD013 -->

# NotePod Installers

Flutter supports multiple platform targets. Flutter based apps can run
native on Android, iOS, Linux, MacOS, and Windows, as well as directly
in a browser from the web. Flutter functionality is essentially
identical across all platforms so the experience across different
platforms will be very similar.

Visit the
[CHANGELOG](https://github.com/anusii/notepod/blob/dev/CHANGELOG.md)
for the latest updates.

Run the app online: [**web**](https://notepod.solidcommunity.au).

Download the latest version:
**GNU/Linux**
[deb](https://solidcommunity.au/installers/notepod_amd64.deb) or
[zip](https://solidcommunity.au/installers/notepod-dev-linux.zip);
**Android**
[apk](https://solidcommunity.au/installers/notepod.apk);
**macOS**
[dmg](https://solidcommunity.au/installers/notepod-dev-macos-unsigned.dmg);
**Windows**
[zip](https://solidcommunity.au/installers/notepod-dev-windows.zip) or
[inno](https://solidcommunity.au/installers/notepod-dev-windows-inno.exe).

## Prerequisite

There are no specific prerequisites for installing and running
Notepod.

## Android

You can side load the latest version of the app by downloading the
[installer](https://solidcommunity.au/installers/notepod.apk) through
your Android device's browser. This will download the app to your
Android device. Then visit the Downloads folder where you can click on
the `notepod.apk` file. Your browser will ask if you are okay with
installing the app locally.

## Linux

### Deb Install for Debian/Ubuntu

Download and install the deb package:

```bash
wget https://solidcommunity.au/installers/notepod_amd64.dev -O notepod_amd64.deb
sudo dpkg --install notepod_amd64.deb
```

### Zip Install

Download [notepod-dev-linux.zip](https://solidcommunity.au/installers/notepod-dev-linux.zip)

To try it out:

```bash
wget https://solidcommunity.au/installers/notepod-dev-linux.zip -O notepod-dev-linux.zip
unzip notepod-dev-linux.zip -d notepod
./notepod/notepod
```

To install for the local user and to make it known to GNOME and KDE,
with a desktop icon for their desktop, begin by downloading the **zip** and
installing that into a local folder:

```bash
unzip notepod-dev-linux.zip -d ${HOME}/.local/share/notepod
```

Then set up your local installation (only required once):

```bash
ln -s ${HOME}/.local/share/notepod/notepod ${HOME}/.local/bin/
wget https://raw.githubusercontent.com/anusii/notepod/dev/installers/app.desktop -O ${HOME}/.local/share/applications/notepod.desktop
sed -i "s/USER/$(whoami)/g" ${HOME}/.local/share/applications/notepod.desktop
mkdir -p ${HOME}/.local/share/icons/hicolor/256x256/apps/
wget https://github.com/anusii/notepod/raw/dev/installers/app.png -O ${HOME}/.local/share/icons/hicolor/256x256/apps/notepod.png
```

To install for any user on the computer:

```bash
sudo unzip notepod-dev-linux.zip -d /opt/notepod
sudo ln -s /opt/notepod/notepod /usr/local/bin/
wget https://raw.githubusercontent.com/anusii/notepod/dev/installers/app.desktop -O ${HOME}/usr/local/share/applications/notepod.desktop
wget https://github.com/anusii/notepod/raw/dev/installers/app.png -O ${HOME}/use/local/share/icons/notepod.png
```

Once installed you can run the app from the GNOME desktop through
Alt-F2 and type `notepod` then Enter.

## MacOS

The zip file
[notepod-dev-macos-unsigned.zip](https://solidcommunity.au/installers/notepod-dev-macos-unsigned.zip)
can be installed on MacOS. Download the file and open it on your
Mac. Then, holding the Control key click on the app icon to display a
menu. Choose `Open`. Then accept the warning to then run the app. The
app should then run without the warning next time.

## Web -- No Installation Required

No installer is required for a browser based experience of
Notepod. Simply visit
[https://notepod.solidcommunity.au](https://notepod.solidcommunity.au).

Also, your Web browser will provide an option in its menus to install
the app locally, which can add an icon to your home screen to start
the web-based app directly.

## Windows Installer

Download and run the self extracting archive
[notepod-dev-windows-inno.exe](https://solidcommunity.au/installers/notepod-dev-windows-inno.exe)
to self install the app on Windows.

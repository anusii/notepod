# PodNotes Installers

Flutter supports multiple platform targets and the app will run native
on Android, iOS, Linux, MacOS, and Windows, as well as directly in a
browser from the web. The functionality is identical across all
platforms.

## Android Side Load

On your Android device simply browse to this folder and click on the
`podnotes.apk` file. Your browser will ask if you are comfortable to
install the app locally. Choose to do so and you will have an Android
native install of the app.

## Linux tar Archive

+ Download
  [mlflutter.tar.gz](https://access.togaware.com/mlflutter.tar.gz)

```bash
wget https://access.togaware.com/mlflutter.tar.gz
```

Then

```bash
tar zxvf podnotes.tar.gz
(cd podnotes; ./podnotes)
```

To install for the current user:

```bash
tar zxvf podnotes.tar.gz -C ${HOME}/.local/share/
cat <<EOF > ~/.local/bin/mlflutter
#!/bin/bash

(cd ${HOME}/.local/share/mlflutter; ./mlflutter)
EOF
chmod a+rx ${HOME}/.local/bin/mlflutter
```

## MacOS

The package file `podnotes.dmg` can be installed on MacOS. Download
the file and open it on your Mac. Then, holding the Control key click
on the app icon to display a menu. Choose `Open`. Then accept the
warning to then run the app. The app should then run without the
warning next time.

## Web -- No Installation Required

No installer is required for a browser based experience of
PodNotes. Simply visit https://podnotes.solidcommunity.au. 

Also, your Web browser will provide an option in its menus to install
the app locally, which can add an icon to your home screen to start
the web-based app directly.

## Windows Installer

Download and run the `podnotes.exe` to self install the app on
Windows.

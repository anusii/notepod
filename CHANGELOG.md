# NotePod Change Log

Noted here are the high level changes for the NotePod app.

Guide: Each version update is noted here with a short user-oriented
description of the update. Updates in the 0.3.n series are heading
toward a 0.4 release. The `[version timestamp user]` string is
utilised by the flutter version_widget package.

Run the app online: [**web**](https://notepod.solidcommunity.au).

The latest version of the app can be downloaded and installed from the
[Solid Community AU](https://solidcommunity.au):

+ **Android**
[apk](https://solidcommunity.au/installers/notepod.apk);
+ **GNU/Linux**
[snap](https://solidcommunity.au/installers/notepod_amd64.snap) or
[deb](https://solidcommunity.au/installers/notepod_amd64.deb) or
[zip](https://solidcommunity.au/installers/notepod-linux.zip);
+ **macOS**
[dmg](https://solidcommunity.au/installers/notepod-macos-unsigned.dmg) or
[zip](https://solidcommunity.au/installers/notepod-macos-unsigned.zip);
+ **Windows**
[zip](https://solidcommunity.au/installers/notepod-windows.zip) or
[inno](https://solidcommunity.au/installers/notepod-windows-inno.exe).

Contributions are welcome. Visit
[github](https://github.com/anusii/notepod) to submit an issue or,
even better, fork the repository yourself, update the code, and submit
a Pull Request. Thanks.

## 0.4

+ JSON import now creates the imported notes [0.3.19 20260427 gjw]
+ Fixes to loading empty notepods [0.3.18 20260427 jesscmoore]
+ Upgrade concurrent list loading with exception handling [0.3.17 20260426 jesscmoore]
+ Add import/export of json and export to pdf and md [0.3.16 20260423 gjw]
+ Update solidpod to dev for key loading fix [0.3.15 20260418 jesscmoore]
+ Optimise multi file load from different owners [0.3.14 20260415 jesscmoore]
+ Fix appbar preferences overflow [0.3.13 20260406 tonypioneer]
+ IOS build settings for iOS 26.4 UIScene migration [0.3.12 20260406 jesscmoore]
+ Fix closing of save dialog [0.3.11 20260320 jesscmoore]
+ Make delete inactive if external selected and fix icon [0.3.10 20260319 jesscmoore]
+ Remove redundant shared notes list [0.3.9 20260318 jesscmoore]
+ Use common list widget [0.3.8 20260315 jesscmoore]
+ Restore support for listing unreadable notes [0.3.7 20260315 jesscmoore]
+ Use common edit widget [0.3.7 20260314 jesscmoore]
+ Use common view widget [0.3.7 20260314 jesscmoore]
+ Adopt a generalised note data model [0.3.7 20260314 jesscmoore]
+ Use common share widget [0.3.7 20260314 jesscmoore]
+ Simplify function parameters [0.3.7 20260314 jesscmoore]
+ Updates delete file calls to comply with solidpod change [0.3.7 20260311 tonypioneer]
+ Corrects granterWebId in sharing process [0.3.7 20260205 jesscmoore]
+ Remove redundant logout button [0.3.7 20260123 tonypioneer]
+ Bug fix: CONTINUE when not logged in [0.3.6 20260123 tonypioneer]
+ Dependency cleanup and update [0.3.5 20260119 gjw]
+ Fix writePod calls as required for solidpod 0.9.0 [0.3.4 20260112 jesscmoore]
+ Update to solidpod 0.9.0 and solidui 0.0.22 [0.3.4 20260109 jesscmoore]
+ Added deletion of multiple notes [0.3.3 20260108 jesscmoore]
+ Fix const IconData issue for macOS #152 [0.3.2 20260108 tonypioneer]
+ Fixed delete dialog not closing [0.3.1 20251218 tonypioneer]
+ Match version string to theming [0.3.0 20251218 jesscmoore]
+ Added light/dark themes [0.3.0 20251211 tonypioneer]
+ Fixed render error in edit views [0.3.0 20251211 tonypioneer]
+ Macos: implemented xcodegen build config generation [0.3.0 20251205 jesscmoore]
+ Deploy with solidui's SolidScaffold framework [0.3.0 20251205 jesscmoore]

## 0.3 Migrate to SolidUI. Review and Consolidate

+ Optimise with concurrent note list loading [0.2.54 20251107 jesscmoore]
+ Responsive delete multiple files dialog [0.2.53 20251107 jesscmoore]
+ Dialog added to update permission log [0.2.52 20251103 jesscmoore]
+ Fix text overflows in lists of notes [0.2.51 20251030 jesscmoore]
+ Permissions update [0.2.50 20251030 jesscmoore]
+ Move to using CORS fixed version widget [0.2.49 20251027 gjw]
+ Updated for new solidpod/solidui. Lint fixes. [0.2.48 20251024 gjw]
+ Fixed rendering error on titles of external notes [0.2.47 20251019 jesscmoore]
+ Fixed initialisation error on unreadable note [0.2.46 20251019 jesscmoore]
+ Fixed rendering error on unreadable note [0.2.45 20251016 jesscmoore]
+ Update snap/android config for secure storage [0.2.44 20251010 gjw]
+ Fixed save to secure storage bug on macos [0.2.43 20251010 jesscmoore]
+ Fixed bug causing macos build crash [0.2.42 20251008 jesscmoore]
+ Back button can save unsaved notes [0.2.41 20251008 jesscmoore]
+ Note action buttons made to be responsive [0.2.40 20251008 jesscmoore]
+ Note list views made to be responsive [0.2.39 20251006 jesscmoore]
+ Support light/dark colour themes [0.2.38 20250930 jesscmoore]
+ All ow multiple MY NOTES to be selected [0.2.37 20250930 jesscmoore]
+ Updates to busy animation [0.2.36 20250930 jesscmoore]
+ Update inno build for windows-latest [0.2.35 20250929 gjw]
+ Fix saving note not closing bug [0.2.34 20250926 jesscmoore]
+ Show title if permission in Shared Notes list [0.2.33 20250922 jesscmoore]
+ Quick share button if permission in Shared Notes [0.2.32 20250921 jesscmoore]
+ Remove import of lib/src from solidpod [0.2.31 20250917 gjw]
+ Various lint updates [0.2.30 20250917 jesscmoore]
+ Bug fix handling of no content for new notes [0.2.29 20250917 jesscmoore]
+ Improve TAB between TITLE/CONTENT [0.2.28 20250917 jesscmoore]
+ Ensure scrollbar visibility [0.2.27 20250917 jesscmoore]
+ Lint updates [0.2.26 20250915 jesscmoore]
+ Bug fix on viewing notes [0.2.25 20250915 jesscmoore]
+ Report number of shares [0.2.24 20250807 jesscmoore]
+ Buttons remain visible [0.2.23 20250722 jesscmoore]
+ Ensure scrollbars are visible [0.2.22 20250722 jesscmoore]
+ Version number now in nav drawer [0.2.21 20250722 jesscmoore]
+ Improve NOTE scrolling [0.2.20 20250719 jesscmoore]
+ Begin with NEW NOTE if no notes found [0.2.19 20250719 jesscmoore]
+ Visually separate meta data and note [0.2.18 20250718 jesscmoore]
+ Left align markdown rendering of notes [0.2.17 20250718 jesscmoore]
+ Refactor SAVE buttons [0.2.16 20250717 jesscmoore]
+ Default to note list on app startup [0.2.15 20250716 anushkavidanage]
+ Navigate to note after saving from HOME [0.2.14 20250716 jesscmoore]
+ Refactor back button [0.2.13 20250716 gjw]
+ Support search by note content [0.2.12 20250716 jesscmoore]
+ Sort by note title and sort options [0.2.11 20250716 jesscmoore]
+ Add note title search [0.2.10 20250715 jesscmoore]
+ General cleanup [0.2.9 20250714 jesscmoore]
+ Clarify mine and shared notes in title [0.2.8 20250714 jesscmoore]
+ Unify date formats [0.2.7 20250714 jesscmoore]
+ Update date formatting [0.2.6 20250714 jesscmoore]
+ Installer script updates [0.2.5 20250611 gjw]
+ Cleanup, Android permissions, rename [0.2.4 20250611 gjw]
+ Debug failure to list notes - WIP [0.2.3 20250608 gjw]
+ Recover iss windows installer builder [0.2.2 20250606 gjw]
+ Updated deb installer build [0.2.1 20250606 gjw]

## 0.2 Stable release

+ Use `solidpod` package
+ Use new markdown render widget
+ Use markdown toolbar
+ rename package to `notepod`

## 0.1 Migrate to latest solidpod package

+ Lint updates [0.1.3 gjw 20250506]
+ Add installer builds [0.1.2 gjw 20250506]
+ Resync and package for distribution [0.1.1 gjw 20250505]

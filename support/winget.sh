#!/bin/bash

# 20261030 gjw Generate the winget manifests for the current version
# from the Inno Setup installer that `make ginstall` archived and
# uploaded to the versioned URL. The manifests are written to
# installers/winget/manifests/<x>/<Publisher>/<Name>/<version>/, the
# layout of microsoft/winget-pkgs, ready for a pull request there.
#
# Run from the app's top folder: bash support/winget.sh

set -e

APP=$(basename "$(pwd)")
VER=$(grep '^version:' pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)
ISS=installers/app-windows.iss

NAME=$(sed -n 's/^#define MyAppName "\(.*\)"/\1/p' ${ISS})
PUBLISHER=$(sed -n 's/^#define MyAppPublisher "\(.*\)"/\1/p' ${ISS})
APPID=$(sed -n 's/^AppId={\({.*}\)$/\1/p' ${ISS})
DESC=$(sed -n 's/^description: "\(.*\)"/\1/p' pubspec.yaml)
REPO=$(git remote get-url origin | sed -E 's#.*github.com[/:]([^/]+/[^/.]+)(\.git)?$#\1#')

ID="Togaware.${NAME}"
EXE="${APP}_${VER}_windows_inno.exe"
LOCAL="installers/ARCHIVE/${EXE}"
URL="https://solidcommunity.au/installers/${EXE}"
DIR="installers/winget/manifests/t/Togaware/${NAME}/${VER}"
MV=1.10.0

if [[ ! -f ${LOCAL} ]]; then
    echo "Error: ${LOCAL} not found. Run 'make ginstall' first."
    exit 1
fi

# The manifest pins the hash of what the URL serves, so confirm that
# is the archived file before writing it down.

SHA=$(sha256sum ${LOCAL} | cut -d' ' -f1 | tr a-f A-F)
RSHA=$(curl -fsSL ${URL} | sha256sum | cut -d' ' -f1 | tr a-f A-F)

if [[ "${SHA}" != "${RSHA}" ]]; then
    echo "Error: ${URL} does not match ${LOCAL}."
    exit 1
fi

mkdir -p ${DIR}

cat > ${DIR}/${ID}.yaml <<EOF
# yaml-language-server: \$schema=https://aka.ms/winget-manifest.version.${MV}.schema.json

PackageIdentifier: ${ID}
PackageVersion: ${VER}
DefaultLocale: en-US
ManifestType: version
ManifestVersion: ${MV}
EOF

# The installer offers both scopes (PrivilegesRequiredOverridesAllowed
# is commandline), so winget can install without admin rights when
# asked for --scope user.

cat > ${DIR}/${ID}.installer.yaml <<EOF
# yaml-language-server: \$schema=https://aka.ms/winget-manifest.installer.${MV}.schema.json

PackageIdentifier: ${ID}
PackageVersion: ${VER}
InstallerType: inno
UpgradeBehavior: install
ProductCode: '${APPID}_is1'
ReleaseDate: $(date +%Y-%m-%d)
AppsAndFeaturesEntries:
- DisplayName: ${NAME}
  Publisher: ${PUBLISHER}
  ProductCode: '${APPID}_is1'
Installers:
- Architecture: x64
  Scope: machine
  InstallerUrl: ${URL}
  InstallerSha256: ${SHA}
  InstallerSwitches:
    Custom: /ALLUSERS
- Architecture: x64
  Scope: user
  InstallerUrl: ${URL}
  InstallerSha256: ${SHA}
  InstallerSwitches:
    Custom: /CURRENTUSER
ManifestType: installer
ManifestVersion: ${MV}
EOF

cat > ${DIR}/${ID}.locale.en-US.yaml <<EOF
# yaml-language-server: \$schema=https://aka.ms/winget-manifest.defaultLocale.${MV}.schema.json

PackageIdentifier: ${ID}
PackageVersion: ${VER}
PackageLocale: en-US
Publisher: ${PUBLISHER}
PublisherUrl: https://togaware.com/
PublisherSupportUrl: https://github.com/${REPO}/issues
PackageName: ${NAME}
PackageUrl: https://github.com/${REPO}
License: GPL-3.0-or-later
LicenseUrl: https://github.com/${REPO}/blob/main/LICENSE
ShortDescription: ${DESC}
Moniker: ${APP}
Tags:
- solid
- flutter
ReleaseNotesUrl: https://github.com/${REPO}/blob/dev/CHANGELOG.md
ManifestType: defaultLocale
ManifestVersion: ${MV}
EOF

echo "Manifests for ${ID} ${VER} in ${DIR}"
ls ${DIR}

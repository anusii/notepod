#!/bin/bash

# set -x

# 20241024 gjw After a github action has built the bundles and stored
# them as artefacts on github, we can upload them to the ${HOST} for
# distribution.

APP=$(basename "$(dirname "$(pwd)")")
REP=$(git remote get-url origin | sed -E 's#.*[/:]([^/]+)/[^/]+(\.git)?$#\1#')

HOST=solidcommunity.au
FLDR=/var/www/html/installers/
DEST=${HOST}:${FLDR}

ssh ${HOST} 'if [ ! -d ${FLDR} ]; then mkdir ${FLDR}; chown gjw:gjw ${FLDR}; fi'

# From the recent 'Build Installers' workflows, identify the 'Bump
# version' pushes to the repository and get the latest one as the one
# we want to download the artefacts.

bumpId=$(gh run list --limit 100 --json databaseId,displayTitle,workflowName \
	     | jq -r '.[] | select(.workflowName | startswith("Build Installers")) | select(.displayTitle | startswith("Bump version")) | .databaseId' \
	     | head -n 1)

echo "Found github action id: $bumpId"

if [[ -z "${bumpId}" ]]; then
    echo "No workflow found."
    exit 1
fi

status=$(gh run view ${bumpId} --json status --jq '.status')
conclusion=$(gh run view ${bumpId} --json conclusion --jq '.conclusion')

# Determine the latest version from pubspec.yaml. Assumes the
# latest Bump Version push is the same version.

version=$(grep version ../pubspec.yaml | head -1 | cut -d ':' -f 2 | sed 's/ //g' | sed 's/+.*//')

# Only proceed if the latest action hase been completed successfully

# 20250611 gjw Currently failing:
#
# gh run download ${bumpId} --name ${APP}-linux-zip
# error downloading ${APP}-linux-zip: would result in path traversal
#
# I was then manually downloading through browser, unzip and move
# here, then run this script.
#
# But this should work as an alternative:
#
# gh api -H "Accept: application/vnd.github+json"   repos/${REP}/${APP}/actions/artifacts/3300608315/zip >| artifact.zip
#
# Need to get the correct artifact ID for each artefact.

if [[ "${status}" == "completed" && "${conclusion}" == "success" ]]; then

    echo "Uploading ${APP} version ${version}"
    echo "Uploads are going to ${DEST}."
    echo

    echo '******************** UPLOAD LINUX DEB'

    ## gh run download ${bumpId} --name ${APP}-linux-deb

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-linux-deb")) | .id' | head -n 1)

    if [[ -z "${artifactId}" ]]; then
	echo "No artifact found."
    else
	echo "artifact id: $artifactId"
	gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	unzip artifact.zip
	fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	touch ${fname} # Timestamp with current date/time as the release time.
	rm -f artifact.zip
	echo  "Installing as ${DEST}${APP}_amd64.deb"
	rsync -avzh ${fname} ${DEST}${APP}_amd64.deb
	echo  "Archive as installers/ARCHIVE/${fname}"
	mv -f ${fname} ARCHIVE/
    fi

    echo ""

    echo '******************** UPLOAD LINUX SNAP'

    ## gh run download ${bumpId} --name ${APP}-linux-snap

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-linux-snap")) | .id' | head -n 1)
    if [[ -z "${artifactId}" ]]; then
	echo "No artifact found."
    else
	echo "artifact id: $artifactId"
	gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	unzip artifact.zip
	fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	touch ${fname} # Timestamp with current date/time
	rm -f artifact.zip
	echo  "Installing as ${DEST}${APP}_amd64.snap"
	rsync -avzh ${fname} ${DEST}${APP}_amd64.snap
	ssh ${HOST} "cd ${FLDR}; chmod a+r ${APP}_amd64.snap"
	echo  "Archive as installers/ARCHIVE/${fname}"
	mv -f ${fname} ARCHIVE/
    fi

    echo ""

    echo '******************** UPLOAD LINUX ZIP'

    ## gh run download ${bumpId} --name ${APP}-linux-zip

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-linux-zip")) | .id' | head -n 1)

    if [[ -z "${artifactId}" ]]; then
	echo "No artifact found."
    else
	echo "artifact id: $artifactId"
	gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	unzip artifact.zip
	fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	touch ${fname} # Timestamp with current date/time
	rm -f artifact.zip
	echo  "Installing as ${DEST}${APP}-linux.zip"
	rsync -avzh ${fname} ${DEST}${APP}-linux.zip
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_linux.zip"
	mv -f ${fname} ARCHIVE/${APP}_${version}_linux.zip
    fi

    echo ""

    echo '******************** UPLOAD MACOS DMG ORIGINAL'

    ## gh run download ${bumpId} --name ${APP}-macos-zip

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-macos-dmg")) | .id' | head -n 1)

    if [[ -z "${artifactId}" ]]; then
	echo "No artifact found."
    else
        echo "artifact id: $artifactId"
        gh api -H "Accept: application/vnd.github+json" \
	   repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip \
	   > artifact.zip
        unzip artifact.zip
	fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	touch ${fname} # Timestamp with current date/time
	rm -f artifact.zip
	echo  "Installing as ${DEST}${fname}"
	rsync -avzh ${fname} ${DEST}
	ssh ${HOST} "cd ${FLDR}; chmod a+r ${fname}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_macos.dmg"
	mv ${fname} ARCHIVE/${APP}_${version}_macos.dmg
    fi

    echo ""

    echo '******************** UPLOAD MACOS ZIP ORIGINAL'

    ## gh run download ${bumpId} --name ${APP}-macos-zip

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-macos-zip")) | .id' | head -n 1)

    if [[ -z "${artifactId}" ]]; then
	echo "No artifact found."
    else
	echo "artifact id: $artifactId"
	gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	unzip artifact.zip
	fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	touch ${fname} # Timestamp with current date/time
	rm -f artifact.zip
	echo  "Installing as ${DEST}${APP}-macos.zip"
	rsync -avzh ${APP}-macos.zip ${DEST}
	ssh ${HOST} "cd ${FLDR}; chmod a+r ${APP}-*.zip ${APP}-*.exe"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_macos.zip"
	mv ${APP}-macos.zip ARCHIVE/${APP}_${version}_macos.zip
    fi

    echo ""

    # 20251222 gjw
    #
    #    The macOS and iOS signed/certified builds are under
    #    development with the notepod app. Once it is working there we
    #    can migrate all other apps.

    echo '******************** UPLOAD MACOS DMG UNSIGNED'

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-macos-unsigned-dmg")) | .id' | head -n 1)

    if [[ -z "${artifactId}" ]]; then
	echo "No artifact found."
    else
	echo "artifact id: $artifactId"
	gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	unzip artifact.zip
	fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	touch ${fname} # Timestamp with current date/time
	rm -f artifact.zip
	echo  "Installing as ${DEST}${fname}"
	rsync -avzh ${fname} ${DEST}
	ssh ${HOST} "cd ${FLDR}; chmod a+r ${fname}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_macos_unsigned.dmg"
	mv ${fname} ARCHIVE/${APP}_${version}_macos_unsigned.dmg
    fi

    echo ""

    echo '******************** UPLOAD MACOS ZIP UNSIGNED'

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-macos-unsigned-zip")) | .id' | head -n 1)

    if [[ -z "${artifactId}" ]]; then
	echo "No artifact found."
    else
	echo "artifact id: $artifactId"
	gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	unzip artifact.zip
	fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	touch ${fname} # Timestamp with current date/time
	rm -f artifact.zip
	echo  "Installing as ${DEST}${fname}"
	rsync -avzh ${fname} ${DEST}
	ssh ${HOST} "cd ${FLDR}; chmod a+r ${fname}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_macos_unsigned.dmg"
	mv ${fname} ARCHIVE/${APP}_${version}_macos_unsigned.zip
    fi

    echo ""

    echo '******************** UPLOAD MACOS DMG STAGING'

    ## gh run download ${bumpId} --name ${APP}-macos-zip

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-macos-staging-dmg")) | .id' | head -n 1)

    if [[ -z "${artifactId}" ]]; then
	echo "No artifact found."
    else
	echo "artifact id: $artifactId"
	gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	unzip artifact.zip
	fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	touch ${fname} # Timestamp with current date/time
	rm -f artifact.zip
	echo  "Installing as ${DEST}${fname}"
	rsync -avzh ${fname} ${DEST}
	ssh ${HOST} "cd ${FLDR}; chmod a+r ${APP}-dev-macos-staging.dmg"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_macos_staging.dmg"
	mv ${fname} ARCHIVE/${APP}_${version}_macos_staging.dmg
    fi

    echo ""

    echo '******************** UPLOAD MACOS DMG DEV'

    ## gh run download ${bumpId} --name ${APP}-macos-zip

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-macos-dev-dmg")) | .id' | head -n 1)

    if [[ -z "${artifactId}" ]]; then
	echo "No artifact found."
    else
	echo "artifact id: $artifactId"
	gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	unzip artifact.zip
	fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	touch ${fname} # Timestamp with current date/time
	rm -f artifact.zip
	echo  "Installing as ${DEST}${fname}"
	rsync -avzh ${fname} ${DEST}
	ssh ${HOST} "cd ${FLDR}; chmod a+r ${fname}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_macos_dev.dmg"
	mv ${fname} ARCHIVE/${APP}_${version}_macos_dev.dmg
    fi

    echo ""

    echo '******************** UPLOAD WINDOWS INNO'

    ## gh run download ${bumpId} --name ${APP}-windows-inno

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-windows-inno")) | .id' | head -n 1)

    if [[ -z "${artifactId}" ]]; then
	echo "No artifact found."
    else
	echo "artifact id: $artifactId"
	gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	unzip artifact.zip
	fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	touch ${fname} # Timestamp with current date/time
	rm -f artifact.zip
	echo  "Installing as ${DEST}${fname}"
	rsync -avzh ${fname} ${DEST}
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_windows_inno.exe"
	mv ${fname} ARCHIVE/${APP}_${version}_windows_inno.exe
    fi

    echo ""

    echo '******************** UPLOAD WINDOWS ZIP'

    ## gh run download ${bumpId} --name ${APP}-windows-zip

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-windows-zip")) | .id' | head -n 1)

    if [[ -z "${artifactId}" ]]; then
	echo "No artifact found."
    else
	echo "artifact id: $artifactId"
	gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	unzip artifact.zip
	fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	touch ${fname} # Timestamp with current date/time
	rm -f artifact.zip
	echo  "Installing as ${DEST}${fname}"
	rsync -avzh ${fname} ${DEST}
	ssh ${HOST} "cd ${FLDR}; chmod a+r ${APP}-*.zip ${APP}-*.exe"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_windows.zip"
	mv -f ${APP}-windows.zip ARCHIVE/${APP}_${version}_windows.zip
    fi

else

    gh run view ${bumpId} | cat
    gh run view ${bumpId} --json status,conclusion
    echo ''
    echo "******************** Latest github actions has not successfully completed. Exiting."
    echo ''
    exit 1
fi

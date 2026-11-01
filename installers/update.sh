#!/bin/bash

# set -x

# 20260216 gjw Compare files.
#
# After a github action has built the bundles and stored
# them as artefacts on github, we can upload them to the ${HOST} for
# distribution.

APP=$(basename "$(dirname "$(pwd)")")
REP=$(git remote get-url origin | sed -E 's#.*[/:]([^/]+)/[^/]+(\.git)?$#\1#')

# 20261030 gjw The installer host and folder are the app's install.host
# and install.folder in .copier-answers.yml, rendered here by the
# gjwgit/fluttertmpl Copier template.

HOST=solidcommunity.au
FLDR=/var/www/html/web/installers/
DEST=${HOST}:${FLDR}

ssh ${HOST} 'if [ ! -d ${FLDR} ]; then mkdir ${FLDR}; chown gjw:gjw ${FLDR}; fi'

# From the recent 'Build Installers' workflows, identify the 'Bump
# version' pushes to the repository and get the latest one as the one
# we want to download the artefacts.

bumpId=$(gh run list --limit 100 --json databaseId,displayTitle,workflowName \
	     | jq -r '.[] | select(.workflowName | startswith("Build Installers")) | select(.displayTitle | startswith("Bump version") or startswith("Build installers")) | .databaseId' \
	     | head -n 1)

echo "Github action id: $bumpId"

if [[ -z "${bumpId}" ]]; then
    echo "No workflow found."
    exit 1
fi

commitMsg=$(gh run list --limit 100 --json databaseId,displayTitle,workflowName \
	     | jq -r '.[] | select(.workflowName | startswith("Build Installers")) | select(.displayTitle | startswith("Bump version") or startswith("Build installers")) | .displayTitle' \
	     | head -n 1)

echo "Commit: \"$commitMsg\""

status=$(gh run view ${bumpId} --json status --jq '.status')
conclusion=$(gh run view ${bumpId} --json conclusion --jq '.conclusion')

# Determine the latest version from pubspec.yaml. Assumes the
# latest Bump Version push is the same version.

version=$(grep version ../pubspec.yaml | head -1 | cut -d ':' -f 2 | sed 's/ //g' | sed 's/+.*//')

# Only proceed if the latest action hase been completed
# successfully. Each artifact which is downloaded as a zip file
# conatins a single file/installer.
#
# 20250611 gjw I used `gh` to download the artifact but that started
# failing:
#
#     gh run download ${bumpId} --name ${APP}-linux-zip
#     error downloading ${APP}-linux-zip: would result in path traversal
#
# I could manually download through the browser, unzip, and then move
# it here to then run this script. But this is now working as an
# alternative:
#
#     gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/3300608315/zip >| artifact.zip
#
# We need to get the correct artifact ID for each artefact.
#
# 20251230 gjw The timestamp from the artifact is UTC which I cahnge
# to current date/time in my timezone for consistency as the release
# time, using `touch`.

if [[ "${status}" == "completed" ]]; then

    # 20260122 gjw Even if we failed there may be some installer
    # builds that succeeded, so let's continue once the builds have
    # completed. This requires handling missing artefacts below.
    #
    # && "${conclusion}" == "success" ]]; then

    echo "App name: ${APP}"
    echo "App version: ${version}"
    echo "Repository: ${DEST}."
    echo

    echo '******************** UPLOAD LINUX DEB'

    TARGET="${APP}_amd64.deb"

    # 20260123 gjw Note that this obtains the latest available
    # linxu-deb artifact, which is not necessarily the one from the
    # latest bumpId if it failed to be build for the latest bumpId.

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
	echo  "Installing as ${DEST}${TARGET}"
	rsync -avzh ${fname} ${DEST}${TARGET}
	ssh ${HOST} "cd ${FLDR}; chmod 0644 ${TARGET}"
	echo  "Archive as installers/ARCHIVE/${fname}"
	mv -f ${fname} ARCHIVE/
	echo  "Install locally from installers/ARCHIVE/${fname}"
	wajig install ARCHIVE/${fname}
    fi

    echo ""

    echo '******************** UPLOAD LINUX SNAP'

    TARGET="${APP}_amd64.snap"

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
	echo  "Installing as ${DEST}${TARGET}"
	rsync -avzh ${fname} ${DEST}${TARGET}
	ssh ${HOST} "cd ${FLDR}; chmod 0644 ${TARGET}"
	echo  "Archive as installers/ARCHIVE/${fname}"
	mv -f ${fname} ARCHIVE/
    fi

    echo ""

    # 20261028 gjw The Flatpak is now built by the workflow too.
    # Archived as <app>_<version>_amd64.flatpak beside the deb.

    echo '******************** UPLOAD LINUX FLATPAK'

    TARGET="${APP}_amd64.flatpak"

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-linux-flatpak")) | .id' | head -n 1)
    if [[ -z "${artifactId}" ]]; then
	echo "No artifact found."
    else
	echo "artifact id: $artifactId"
	gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	unzip -o artifact.zip
	fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	touch ${fname} # Timestamp with current date/time
	rm -f artifact.zip
	echo  "Installing as ${DEST}${TARGET}"
	rsync -avzh ${fname} ${DEST}${TARGET}
	ssh ${HOST} "cd ${FLDR}; chmod 0644 ${TARGET}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_amd64.flatpak"
	mv -f ${fname} ARCHIVE/${APP}_${version}_amd64.flatpak
    fi

    echo ""

    # 20261028 gjw The apk and aab are now built and signed by the
    # workflow. Archived as <app>-<version>.apk/.aab, the names `make
    # upload_android` looks for.

    for ext in apk aab; do

	echo "******************** UPLOAD ANDROID ${ext^^}"

	TARGET="${APP}.${ext}"

	artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
			--jq ".artifacts[] | select(.name | endswith(\"-android-${ext}\")) | .id" | head -n 1)

	if [[ -z "${artifactId}" ]]; then
	    echo "No artifact found."
	else
	    echo "artifact id: $artifactId"
	    gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	    unzip -o artifact.zip
	    fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	    touch ${fname} # Timestamp with current date/time
	    rm -f artifact.zip

	    # 20261031 gjw The aab is for the Play Store (make
	    # upload_android) and is only archived, not offered for
	    # download.

	    if [[ "${ext}" == "apk" ]]; then
		echo  "Installing as ${DEST}${TARGET}"
		rsync -avzh ${fname} ${DEST}${TARGET}
		ssh ${HOST} "cd ${FLDR}; chmod 0644 ${TARGET}"
	    fi
	    echo  "Archive as installers/ARCHIVE/${APP}-${version}.${ext}"
	    mv -f ${fname} ARCHIVE/${APP}-${version}.${ext}
	fi

	echo ""

    done

    echo '******************** UPLOAD LINUX ZIP'

    TARGET="${APP}-linux.zip"

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
	echo  "Installing as ${DEST}${TARGET}"
	rsync -avzh ${fname} ${DEST}${TARGET}
	ssh ${HOST} "cd ${FLDR}; chmod 0644 ${TARGET}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_linux.zip"
	mv -f ${fname} ARCHIVE/${APP}_${version}_linux.zip
    fi

    echo ""

    # 20261008 gjw <app>-macos.dmg and <app>-macos.zip are the default
    # macOS installers. They are the notarized builds when there are any,
    # and otherwise the ad-hoc builds, so an app without the Developer ID
    # secrets still has a macOS download under the default name.
    #
    # Both are taken from the same, most recent, run. Artefacts outlive
    # their run, so preferring any notarized artefact over any ad-hoc one
    # would let an old notarized build shadow every newer ad-hoc build.

    for ext in dmg zip; do

	echo "******************** UPLOAD MACOS ${ext^^}"

	TARGET="${APP}-macos.${ext}"

	artifacts=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
			--jq ".artifacts[] | select(.name | endswith(\"-notarized-macos-${ext}\") or endswith(\"-adhoc-macos-${ext}\")) | \"\\(.workflow_run.id) \\(.name) \\(.id)\"")
	run=$(echo "${artifacts}" | head -n 1 | cut -d ' ' -f 1)
	artifactId=$(echo "${artifacts}" | awk -v run="${run}" '$1 == run' \
			 | sort -k 2 | tail -n 1 | cut -d ' ' -f 3)

	if [[ -z "${artifactId}" ]]; then
	    echo "No artifact found."
	else
	    echo "artifact id: $artifactId"
	    gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	    unzip artifact.zip
	    fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	    touch ${fname} # Timestamp with current date/time
	    rm -f artifact.zip
	    echo  "Installing ${fname} as ${DEST}${TARGET}"
	    rsync -avzh ${fname} ${DEST}${TARGET}
	    ssh ${HOST} "cd ${FLDR}; chmod 0644 ${TARGET}"

	    # The ad-hoc build is archived by its own section below.

	    if [[ "${fname}" == *-notarized-* ]]; then
		echo  "Archive as installers/ARCHIVE/${APP}_${version}_notarized_macos.${ext}"
		mv ${fname} ARCHIVE/${APP}_${version}_notarized_macos.${ext}
	    else
		rm -f ${fname}
	    fi
	fi

	echo ""

    done

    echo '******************** UPLOAD MACOS DMG AD HOC'

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-adhoc-macos-dmg")) | .id' | head -n 1)

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
	ssh ${HOST} "cd ${FLDR}; chmod 0644 ${fname}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_macos.dmg"
	mv ${fname} ARCHIVE/${APP}_${version}_macos.dmg
    fi

    echo ""

    echo '******************** UPLOAD MACOS ZIP AD HOC'

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-adhoc-macos-zip")) | .id' | head -n 1)

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
	ssh ${HOST} "cd ${FLDR}; chmod 0644 ${fname}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_macos.zip"
	mv ${fname} ARCHIVE/${APP}_${version}_macos.zip
    fi

    echo ""

    # 20251222 gjw The macOS and iOS signed/certified builds are under
    # development with the notepod app. Once it is working there we
    # can migrate all other apps.
    #
    # 20260921 gjw The above targets are the most recent work with
    # todopod to get a working macOS installer. The final solution
    # will be some combination of the below and the above.

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
	ssh ${HOST} "cd ${FLDR}; chmod 0644 ${fname}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_macos_unsigned.dmg"
	mv ${fname} ARCHIVE/${APP}_${version}_macos_unsigned.zip
    fi

    echo ""

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
	ssh ${HOST} "cd ${FLDR}; chmod 0644 ${fname}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_macos_unsigned.dmg"
	mv ${fname} ARCHIVE/${APP}_${version}_macos_unsigned.dmg
    fi

    echo ""

    echo '******************** UPLOAD MACOS DMG STAGING'

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
	ssh ${HOST} "cd ${FLDR}; chmod 0644 ${fname}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_macos_staging.dmg"
	mv ${fname} ARCHIVE/${APP}_${version}_macos_staging.dmg
    fi

    echo ""

    echo '******************** UPLOAD MACOS DMG DEV'

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
	ssh ${HOST} "cd ${FLDR}; chmod 0644 ${fname}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_macos_dev.dmg"
	mv ${fname} ARCHIVE/${APP}_${version}_macos_dev.dmg
    fi

    echo ""

    # 20261031 gjw The ipa is only archived, not offered for download.

    echo '******************** ARCHIVE iOS IPA'

    artifactId=$(gh api -H "Accept: application/vnd.github+json" /repos/${REP}/${APP}/actions/artifacts \
		    --jq '.artifacts[] | select(.name | endswith("-ipa")) | .id' | head -n 1)

    if [[ -z "${artifactId}" ]]; then
	echo "No artifact found."
    else
	echo "artifact id: $artifactId"
	gh api -H "Accept: application/vnd.github+json" repos/${REP}/${APP}/actions/artifacts/${artifactId}/zip > artifact.zip
	unzip artifact.zip
	fname=$(unzip -l artifact.zip | awk 'NR==4 {print $4}')
	touch ${fname} # Timestamp with current date/time
	rm -f artifact.zip
	echo  "Archive as installers/ARCHIVE/${APP}_${version}.ipa"
	mv ${fname} ARCHIVE/${APP}_${version}.ipa
    fi

    echo ""

    echo '******************** UPLOAD WINDOWS INNO'

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
	ssh ${HOST} "cd ${FLDR}; chmod 0644 ${fname}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_windows_inno.exe"
	mv ${fname} ARCHIVE/${APP}_${version}_windows_inno.exe

	# 20261030 gjw A winget manifest pins the installer's SHA256, so
	# it needs a URL whose file never changes. Keep each version on
	# the server under its archive name, beside the latest above.

	VTARGET="${APP}_${version}_windows_inno.exe"
	echo  "Installing as ${DEST}${VTARGET}"
	rsync -avzh ARCHIVE/${VTARGET} ${DEST}${VTARGET}
	ssh ${HOST} "cd ${FLDR}; chmod 0644 ${VTARGET}"
    fi

    echo ""

    echo '******************** UPLOAD WINDOWS ZIP'

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
	ssh ${HOST} "cd ${FLDR}; chmod 0644 ${fname}"
	echo  "Archive as installers/ARCHIVE/${APP}_${version}_windows.zip"
	mv -f ${APP}-windows.zip ARCHIVE/${APP}_${version}_windows.zip
    fi

    echo ""

    echo '******************** FINISHED.'


else

    gh run view ${bumpId} | cat
    gh run view ${bumpId} --json status,conclusion
    echo ''
    echo "******************** Latest github actions has not successfully completed. Exiting."
    echo ''
    exit 1
fi

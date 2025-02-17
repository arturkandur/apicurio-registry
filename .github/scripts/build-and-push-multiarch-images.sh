#!/bin/bash
set -euxo pipefail

defvalue="foo"

# Initializing the variable with the Passed Parameter

BRANCH_NAME="$1"       # Git Branch
IMAGE_REPOSITORY="$2"  # Image Repository, e.g. docker.io, quay.io
RELEASE_TYPE="$3"      # Either 'snapshot' or 'release' or 'pre-release'
RELEASE_VERSION=${4:-$defvalue}   # Release version (Pass the release version if you also want images tagged with the release version)



# Check if release type is valid
if [[ ($RELEASE_TYPE != "release") &&  ($RELEASE_TYPE != "snapshot") &&  ($RELEASE_TYPE != "pre-release") ]]
then
    echo "ERROR: Illegal value '${RELEASE_TYPE}' for variable 'RELEASE_TYPE'. Values can only be [release, snapshot, pre-release]"
    exit 1
fi

# Check if image repository is either 'docker.io' or 'quay.io'
if [[ ($IMAGE_REPOSITORY != "docker.io") && ($IMAGE_REPOSITORY != "quay.io") ]]
then
	echo "ERROR: Illegal value '${IMAGE_REPOSITORY}' for variable 'IMAGE_REPOSITORY'. Values can only be [docker.io, quay.io]"
    exit 1
fi



# If release version is passed as a parameter, build images tagged with the 'RELEASE_VERSION'
if [[ $RELEASE_VERSION != "foo" ]]
then
    echo "Building Images With '${RELEASE_VERSION}' Tag."
    make IMAGE_REPO=${IMAGE_REPOSITORY} IMAGE_TAG=${RELEASE_VERSION} multiarch-registry-images
fi



# If it is a pre-release, skip images with other tags
if [[ $RELEASE_TYPE == "pre-release" ]]
then
    echo "This is a '${RELEASE_TYPE}'. Skipping other image tags."
    exit 0
fi



case $BRANCH_NAME in

  "main")
       # if main branch, build images with tag "latest-${RELEASE_TYPE}"
       make IMAGE_REPO=${IMAGE_REPOSITORY} IMAGE_TAG=latest-${RELEASE_TYPE} multiarch-registry-images
       ;;

   *)
       # if other than main, build images with tag "${BRANCH_NAME}-${RELEASE_TYPE}"
       make IMAGE_REPO=${IMAGE_REPOSITORY} IMAGE_TAG=${BRANCH_NAME}-${RELEASE_TYPE} multiarch-registry-images
       ;;
esac

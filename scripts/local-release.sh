#!/usr/bin/env bash

set -e
set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


GH_ORG=acuity-sr
GH_REPO=bkstg-one
RELEASE=${RELEASE:?}


rm -rf ${SCRIPT_DIR}/release
mkdir ${SCRIPT_DIR}/release
cd ${SCRIPT_DIR}/release

CWD=`pwd`
echo "downloading release '${RELEASE}' to '${CWD}'"

gh release download ${RELEASE} --repo ${GH_ORG}/${GH_REPO}
tar -xf bkstg-one.tgz && rm bkstg-one.tgz

mv packages/backend/dist/* .
rm -rf packages
tar -xf skeleton.tar.gz && rm skeleton.tar.gz
tar -xf bundle.tar.gz && rm bundle.tar.gz
yarn install --production --freeze-lockfile

node packages/backend --config app-config.yaml

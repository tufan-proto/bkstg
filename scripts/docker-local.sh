#!/usr/bin/env bash

set -e
set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


GH_ORG=acuity-sr
GH_REPO=bkstg-one
RELEASE=${RELEASE:?}


rm -rf ${SCRIPT_DIR}/docker
mkdir ${SCRIPT_DIR}/docker
cd ${SCRIPT_DIR}/docker

CWD=`pwd`
echo "downloading release '${RELEASE}' to '${CWD}'"

gh release download ${RELEASE} --repo ${GH_ORG}/${GH_REPO}
tar -xf bkstg-one.tgz && rm bkstg-one.tgz

docker build -t bkstg-one:local .

docker run -p 8000:7000 bkstg-one:local
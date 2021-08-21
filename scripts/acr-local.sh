#!/usr/bin/env bash

set -e
set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

GH_ORG=acuity-sr
GH_REPO=bkstg-one
RELEASE=${RELEASE:?}

# ACR_NAME must be (all & only) lower case to work with `docker`
ACR_NAME=acuitysracrtest
RESOURCE_GROUP=acr-test
REGION_NAME=eastus

# convenience definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
# NO_COLOR
NC="\033[0m"

rm -rf ${SCRIPT_DIR}/acr-local
mkdir ${SCRIPT_DIR}/acr-local
cd ${SCRIPT_DIR}/acr-local

CWD=`pwd`
echo "downloading release '${RELEASE}' to '${CWD}'"

gh release download ${RELEASE} --repo ${GH_ORG}/${GH_REPO}
tar -xf bkstg-one.tgz && rm bkstg-one.tgz


rgExists=$(az group exists -n ${RESOURCE_GROUP})

if [[ ${rgExists} == 'true' ]];
then
  echo "Reusing existing resource group '${RESOURCE_GROUP}'"
else
# elif [[ "${USE_CASE}" == "create" ]]
# then
  echo "Creating resource-group '${RESOURCE_GROUP}' ${REGION_NAME}"
  # echo "az group create --name ${RESOURCE_GROUP} --location ${REGION_NAME}"
  # trap return value of next command & discard. bash seems to treat it as an error.
  JUNK=$(az group create --name ${RESOURCE_GROUP} --location ${REGION_NAME})
  unset JUNK
# else
#   echo "${RED} ERROR: Can only create ResourceGroup with USE_CASE=create, not ${USE_CASE}${NC}"
#   exit -1
fi


RESOURCE_GROUP_ID=$(az group show --query 'id' -n ${RESOURCE_GROUP} -o tsv)

if [[ ${RESOURCE_GROUP_ID} == '' ]]
then
 echo "${RED}ERROR: RESOURCE_GROUP_ID not found${NC}"
 exit /b -1
else
 echo "${YELLOW}RESOURCE_GROUP_ID:${CYAN} ${RESOURCE_GROUP_ID} ${NC}"
fi

acrExists=$(az acr show \
  --output tsv \
  --query "id" \
  --name ${ACR_NAME}  2>/dev/null || echo 'create')
if [[ ${acrExists} == "create" ]]
then
  echo "Creating new ACR Registry ${ACR_NAME}"
  start=$(date +"%D %T")
  echo "Start: ${start}"
  ACR=$(az acr create \
    --resource-group $RESOURCE_GROUP \
      --location $REGION_NAME \
      --name $ACR_NAME \
      --sku Standard )
  end=$(date +"%D %T")
  echo "${PURPLE}End: ${end} (start: ${start})${NC}"
  if [[ $? == 0 ]]
  then
    echo "${GREEN}Created new ACR Registry ${ACR_NAME}${NC}"
  fi
else
  echo "Reusing ACR Registry ${ACR_NAME}" 
fi
# re-initialize CLUSTER_ID, in case we created it.
ACR_ID=$(az acr show \
  --output tsv \
  --resource-group ${RESOURCE_GROUP} \
  --name ${ACR_NAME} 2>/dev/null || echo "not-found");
if [[ ${ACR_ID} == "not-found" ]]
then
  echo "${RED}ACR_NAME not found${NC}"
else
  echo "${YELLOW}ACR_NAME: ${CYAN}${ACR_NAME}${NC}"
fi

ACR_IMAGE=bkstg-one:acr-test
az acr build .\
        --resource-group ${RESOURCE_GROUP} \
        --registry ${ACR_NAME} \
        --image ${ACR_IMAGE}

az acr login -n ${ACR_NAME}
docker pull ${ACR_NAME}.azurecr.io/${ACR_IMAGE}
docker run -p 7000:7000 ${ACR_NAME}.azurecr.io/${ACR_IMAGE}

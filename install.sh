#!/usr/bin/env bash

CHART_REPO="${CHART_REPO:-alfresco}"
DIR_NAME=$(basename ${PWD})
CHART_NAME=${CHART_NAME:-${DIR_NAME%%-deployment}}

helm repo add activiti https://activiti.github.io/activiti-cloud-helm-charts
helm repo add alfresco https://kubernetes-charts.alfresco.com/stable
helm repo add alfresco-incubator https://kubernetes-charts.alfresco.com/incubator

if [[ -z "${RELEASE_NAME}" ]]
then
  helm install ${HELM_OPTS} ${CHART_REPO}/${CHART_NAME}
else
  helm upgrade --install --reuse-values ${HELM_OPTS} ${RELEASE_NAME} ${CHART_REPO}/${CHART_NAME}
fi

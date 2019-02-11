#!/usr/bin/env bash

CHART_REPO="${CHART_REPO:-alfresco-incubator}"
CHART_NAME="${CHART_NAME:-alfresco-process-application}"

helm repo add activiti-cloud-charts https://activiti.github.io/activiti-cloud-charts
helm repo add alfresco https://kubernetes-charts.alfresco.com/stable
helm repo add alfresco-incubator https://kubernetes-charts.alfresco.com/incubator
helm dependency update helm/alfresco-process-application

if [[ -z "${RELEASE_NAME}" ]]
then
  helm install ${HELM_OPTS} ${CHART_NAME}
else
  helm upgrade --install --reuse-values ${HELM_OPTS} ${RELEASE_NAME} ${CHART_REPO}/${CHART_NAME}
fi

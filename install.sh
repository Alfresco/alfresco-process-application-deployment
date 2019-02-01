#!/usr/bin/env bash

helm repo add activiti-cloud-charts https://activiti.github.io/activiti-cloud-charts
helm repo add alfresco https://kubernetes-charts.alfresco.com/stable
helm repo add alfresco-incubator https://kubernetes-charts.alfresco.com/incubator
helm dependency update ${CHART_NAME}

helm upgrade --install --wait \
  --reuse-values \
  ${HELM_OPTS} \
  ${APP_NAME} ${CHART_REPO}/${CHART_NAME-"helm/alfresco-process-application"} \
  --version ${CHART_VERSION:-0.7.0}

if [[ -z "${RELEASE_NAME}" ]]
then
  helm install ${HELM_OPTS} ${CHART_NAME}
else
  helm upgrade --install --reuse-values ${HELM_OPTS} ${RELEASE_NAME} ${CHART_NAME}
fi

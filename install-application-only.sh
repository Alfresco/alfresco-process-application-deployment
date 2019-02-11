#!/usr/bin/env bash

helm repo add activiti-cloud-charts https://activiti.github.io/activiti-cloud-charts
helm repo add alfresco https://kubernetes-charts.alfresco.com/stable
helm repo add alfresco-incubator https://kubernetes-charts.alfresco.com/incubator

CHART_REPO=activiti-cloud-charts
CHART_NAME=application
RELEASE_NAME=${APP_NAME}

helm upgrade --install \
  ${HELM_OPTS} \
  -f values-application.yaml \
  -f values-application-${CLUSTER}.yaml \
  -f values-application-to-aps-images.yaml \
  ${RELEASE_NAME} ${CHART_REPO}/${CHART_NAME}

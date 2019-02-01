#!/usr/bin/env bash

helm repo add activiti-cloud-charts https://activiti.github.io/activiti-cloud-charts
helm repo add alfresco https://kubernetes-charts.alfresco.com/stable
helm repo add alfresco-incubator https://kubernetes-charts.alfresco.com/incubator
helm dependency update ${CHART_NAME}

helm upgrade --install \
  ${HELM_OPTS} \
  --set global.keycloak.url=${SSO_URL} \
  --set global.gateway.host=${GATEWAY_HOST} \
  --set activiti-cloud-query.service.name=${APP_NAME}-query \
  --set activiti-cloud-query.ingress.path=/${APP_NAME}-query \
  --set activiti-cloud-query.ingress.hostName=${GATEWAY_HOST} \
  --set activiti-cloud-audit.service.name=${APP_NAME}-audit \
  --set activiti-cloud-audit.ingress.path=/${APP_NAME}-audit \
  --set activiti-cloud-audit.ingress.hostName=${GATEWAY_HOST} \
  --set activiti-cloud-audit.service.name=${APP_NAME}-audit \
  --set activiti-cloud-audit.ingress.path=/${APP_NAME}-audit \
  --set activiti-cloud-audit.ingress.hostName=${GATEWAY_HOST} \
  --set runtime-bundle.service.name=${APP_NAME}-rb \
  --set runtime-bundle.ingress.path=/${APP_NAME}-rb \
  --set runtime-bundle.ingress.hostName=${GATEWAY_HOST} \
  --set activiti-cloud-connector.service.name=${APP_NAME}-rb \
  --set activiti-cloud-connector.ingress.path=/${APP_NAME}-rb \
  --set activiti-cloud-connector.ingress.hostName=${GATEWAY_HOST} \
  -f values-application.yaml \
  -f values-application-${CLUSTER}.yaml \
  ${APP_NAME} activiti-cloud-charts/application

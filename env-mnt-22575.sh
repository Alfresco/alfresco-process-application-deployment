export AAE_APPLICATION_CHART_HOME="$HOME/Hyland/src/activiti/alfresco-process-application-deployment"
export ACTIVITI_CLOUD_ACCEPTANCE_TESTS_HOME="$HOME/Hyland/src/activiti/activiti-cloud-application/activiti-cloud-acceptance-scenarios"
export APP_NAME="default-app"
export REALM="alfresco"
export CLUSTER="mnt-22575"
export PROTOCOL="https"
export DOMAIN="${CLUSTER}.envalfresco.com"
export GATEWAY_HOST="${GATEWAY_HOST:-${DOMAIN}}"
export SSO_HOST="${SSO_HOST:-${DOMAIN}}"

export HELM_OPTS="
  --debug \
  --set global.gateway.http=$(if [[ "${PROTOCOL}" == "http" ]]; then echo true; else echo false; fi) \
  --set global.gateway.host=${GATEWAY_HOST} \
  --set global.keycloak.host=${SSO_HOST} \
  --set global.keycloak.realm=${REALM}"

# alfresco-process-application-deployment

Helm chart to install an APS 2.0 application.

## Prerequisites

The APS 2.0 infrastructure should be already installed and ingress configured with the external URLs.

### add quay-registry-secret

Configure registry authentication with [create_secret.sh](https://git.alfresco.com/process-services/alfresco-process-scripts/raw/master/create_secret.sh): 

    DOCKER_REGISTRY=quay.io \
    DOCKER_REGISTRY_USER=<quay_user> \
    DOCKER_REGISTRY_PASSWORD=<quay_password> \
    DOCKER_REGISTRY_EMAIL=<quay_email> \
      ./create_secret.sh    

## Install

Helm command to install application chart:

    helm install ./helm/alfresco-process-application \
      --namespace=$DESIRED_NAMESPACE

### install.sh

Helper script to launch installation:

    HELM_OPTS="--debug --dry-run" ./install.sh

Verify the k8s yaml output than launch again without `--dry-run`.

Supported optional vars:

* RELEASE_NAME to handle upgrade or a non auto-generated release name
* HELM_OPTS to pass extra options to helm 


### run in Docker for Desktop

A custom extra values file to add settings for _Docker for Desktop_ as specified in the [DBP README](https://github.com/Alfresco/alfresco-dbp-deployment#docker-for-desktop---mac) is provided:

    HELM_OPTS="-f docker-for-desktop-values.yaml" ./install.sh

## Pen Testing Environment Setup

Set variables:

```bash
export HELM_OPTS="--debug --dry-run"
export APP_NAME="activiti-cloud-full-example"
export CHART_NAME="activiti-cloud-full-example"
export CHART_REPO="activiti-cloud-charts"
export CHART_VERSION="0.7.0"
export DOMAIN=aps2pentest.envalfresco.com
export PROTOCOL=https
export SSO_HOST=activiti-keycloak.${DOMAIN}
export SSO_URL=${PROTOCOL}://${SSO_HOST}/auth
export REALM=activiti
export GATEWAY_HOST=activiti-cloud-gateway.${DOMAIN}
export GATEWAY_URL=${PROTOCOL}://${GATEWAY_HOST}
```

then patch _serviceaccount_ to pull secrets:

```bash
kubectl patch serviceaccount default --patch '{"imagePullSecrets": [{"name": "quay-registry-secret"}]}'
```

then start with the install:

```bash
helm upgrade --install ${HELM_OPTS} \
  --reuse-values \
  -f values-aps2pentest-to-https.yaml \
  -f values-activiti-to-aps-images.yaml \
  -f values-gateway-to-ingress.yaml \
  -f values-activiti-to-aps-infrastructure.yaml \
  $APP_NAME ${CHART_REPO}/${CHART_NAME} --version ${CHART_VERSION}  
```

or apply steps one by one with:
```bash
helm upgrade ${HELM_OPTS} --reuse-values -f <values_yaml_file> $APP_NAME ${CHART_REPO}/${CHART_NAME} --version ${CHART_VERSION}
```

then patch images to pull secrets if there are pull errors:
```bash
for DEPLOYMENT in activiti-cloud-query activiti-cloud-audit runtime-bundle activiti-cloud-connector
do
  kubectl patch deployment ${APP_NAME}-${DEPLOYMENT} --patch '{"spec": {"template": {"spec": {"imagePullSecrets": [{"name": "quay-registry-secret"}]}}}}'
done
```


Run acceptance tests:
```bash
cd activiti-cloud-acceptance-scenarios
mvn -pl '!security-policies-acceptance-tests' clean verify serenity:aggregate
```

Replace activiti infrastructure with APS one:

```bash
helm upgrade --install ${HELM_OPTS} \
  -f values-aps-infrastructure.yaml \
  infrastructure alfresco-incubator/alfresco-process-infrastructure
  
helm upgrade ${HELM_OPTS} --reuse-values \
  -f values-activiti-to-aps-infrastructure.yaml \
  $APP_NAME ${CHART_REPO}/${CHART_NAME} --version ${CHART_VERSION}
```

or just activate alfresco-identity-service:

```bash
# create secret with activiti realm
kubectl create -f realm-secret.yaml

helm upgrade --install ${HELM_OPTS} \
  -f values-alfresco-identity-service.yaml \
  alfresco-identity-service alfresco/alfresco-identity-service

helm upgrade ${HELM_OPTS} --reuse-values \
  -f values-activiti-to-aps-infrastructure.yaml \
  $APP_NAME ${CHART_REPO}/${CHART_NAME} --version ${CHART_VERSION}
```

then to deploy the process-admin app:
```bash
helm upgrade --install --wait \
  ${HELM_OPTS} \
  --set registryPullSecrets=quay-registry-secret \
  --set image.repository=quay.io/alfresco/alfresco-admin-app \
  --set image.tag=latest \
  --set image.pullPolicy=Always \
  --set ingress.hostName="${GATEWAY_HOST}" \
  --set ingress.path="/alfresco-admin-app" \
  --set env.APP_CONFIG_BPM_HOST="${GATEWAY_URL}" \
  --set env.API_URL="${GATEWAY_URL}" \
  --set env.APP_CONFIG_APPS_DEPLOYED="[{\"name\": \"${APP_NAME}\" }]" \
  --set env.APP_CONFIG_AUTH_TYPE="OAUTH" \
  --set env.APP_CONFIG_OAUTH2_HOST="${SSO_URL}/realms/${REALM}" \
  --set env.APP_CONFIG_IDENTITY_HOST="${SSO_URL}/admin/realms/${REALM}" \
  --set env.APP_CONFIG_OAUTH2_CLIENTID="activiti" \
  alfresco-admin-app alfresco-incubator/alfresco-adf-app

``` 

then to deploy the process-workspace app:
```bash
helm upgrade --install --wait \
  ${HELM_OPTS} \
  --set registryPullSecrets=quay-registry-secret \
  --set image.repository=quay.io/alfresco/alfresco-process-workspace-app \
  --set image.tag=latest \
  --set image.pullPolicy=Always \
  --set ingress.hostName="${GATEWAY_HOST}" \
  --set ingress.path="/alfresco-process-workspace-app" \
  --set env.APP_CONFIG_BPM_HOST="${GATEWAY_URL}" \
  --set env.API_URL="${GATEWAY_URL}" \
  --set env.APP_CONFIG_APPS_DEPLOYED="[{\"name\": \"${APP_NAME}\" }]" \
  --set env.APP_CONFIG_AUTH_TYPE="OAUTH" \
  --set env.APP_CONFIG_OAUTH2_HOST="${SSO_URL}/realms/${REALM}" \
  --set env.APP_CONFIG_IDENTITY_HOST="${SSO_URL}/admin/realms/${REALM}" \
  --set env.APP_CONFIG_OAUTH2_CLIENTID="activiti" \
  alfresco-process-workspace-app alfresco-incubator/alfresco-adf-app

``` 

## DevCon Beer Demo Environment Setup

Setup a cluster on AWS (using Kops, EKS doesn't work using eksctl with the current kubectl version):

```bash
export KOPS_CLUSTER_NAME="beerer"
${APS_SCRIPTS_HOME}/create_aws_cluster_with_kops.sh
```

then add helm and nginx-ingress 1.1.2 (tested with ELB):

```bash
helm init --upgrade
helm repo update
NGINX_INGRESS_RELEASE_NAME=nginx-ingress
helm install --name ${NGINX_INGRESS_RELEASE_NAME} stable/nginx-ingress --version 1.1.2
export ELB_ADDRESS=$(kubectl get services ${NGINX_INGRESS_RELEASE_NAME}-controller -o jsonpath={.status.loadBalancer.ingress[0].hostname})
```

and add widlcard *.aps2devcon.envalfresco.com DNS entry with new HTTPS cert and set ELB to send HTTPS traffic to HTTP.

then set vars:

```bash
export HELM_OPTS="--debug --dry-run"

export APP_NAME="beerer"
export DOMAIN=aps2devcon.envalfresco.com
export PROTOCOL=https
export SSO_HOST=activiti-keycloak.${DOMAIN}
export SSO_URL=${PROTOCOL}://${SSO_HOST}/auth
export REALM=activiti
export GATEWAY_HOST=activiti-cloud-gateway.${DOMAIN}
export GATEWAY_URL=${PROTOCOL}://${GATEWAY_HOST}
```

then add alfresco-identity-service:

```bash
helm upgrade --install ${HELM_OPTS} \
  -f values-alfresco-identity-service.yaml \
  --set keycloak.keycloak.ingress.hosts[0]=${SSO_HOST} \
  alfresco-identity-service alfresco/alfresco-identity-service

# hostname is ignored in alfresco-identity-service chart  
# kubectl edit ingress alfresco-identity-service-alfresco-identity-service
# add spec.rules[0].host=${SSO_HOST}  
```
then add activiti-cloud-modeling using the enterprise version as it is broken:

```bash
helm upgrade --install \
  ${HELM_OPTS} \
  -f values-ingress.yaml \
  --set global.keycloak.url=${SSO_URL} \
  --set global.gateway.host=${GATEWAY_HOST} \
  --set backend.url=${GATEWAY_URL} \
  --set ingress.hostName=${GATEWAY_HOST} \
  --set frontend.image.repository=${USER}/activiti-modeling-app \
  --set frontend.image.tag=latest \
  --set frontend.image.pullPolicy=Always \
  --set env.APP_CONFIG_OAUTH2_REDIRECT_SILENT_IFRAME_URI=${GATEWAY_URL}/activiti-cloud-modeling/assets/silent-refresh.html \
  activiti-cloud-modeling activiti-cloud-charts/activiti-cloud-modeling
``` 
    
then add the application:

```bash
helm upgrade --install \
  ${HELM_OPTS} \
  -f values-application-aps2devcon.yaml \
  --set global.keycloak.url=${SSO_URL} \
  --set global.gateway.host=${GATEWAY_HOST} \
  beerer activiti-cloud-charts/application
``` 

then to deploy the process-admin app:
```bash
helm upgrade --install --wait \
  ${HELM_OPTS} \
  --set registryPullSecrets=quay-registry-secret \
  --set image.repository=quay.io/alfresco/alfresco-admin-app \
  --set image.tag=latest \
  --set image.pullPolicy=Always \
  --set ingress.hostName="${GATEWAY_HOST}" \
  --set ingress.path="/alfresco-admin-app" \
  --set env.APP_CONFIG_BPM_HOST="${GATEWAY_URL}" \
  --set env.API_URL="${GATEWAY_URL}" \
  --set env.APP_CONFIG_APPS_DEPLOYED="[{\"name\": \"${APP_NAME}\" }]" \
  --set env.APP_CONFIG_AUTH_TYPE="OAUTH" \
  --set env.APP_CONFIG_OAUTH2_HOST="${SSO_URL}/realms/${REALM}" \
  --set env.APP_CONFIG_IDENTITY_HOST="${SSO_URL}/admin/realms/${REALM}" \
  --set env.APP_CONFIG_OAUTH2_CLIENTID="activiti" \
  --set env.APP_CONFIG_OAUTH2_REDIRECT_SILENT_IFRAME_URI=${GATEWAY_URL}/alfresco-admin-app/assets/silent-refresh.html \
  alfresco-admin-app alfresco-incubator/alfresco-adf-app

``` 

then to deploy the process-workspace app:
```bash
helm upgrade --install --wait \
  ${HELM_OPTS} \
  --set registryPullSecrets=quay-registry-secret \
  --set image.repository=quay.io/alfresco/alfresco-process-workspace-app \
  --set image.tag=latest \
  --set image.pullPolicy=Always \
  --set ingress.hostName="${GATEWAY_HOST}" \
  --set ingress.path="/alfresco-process-workspace-app" \
  --set env.APP_CONFIG_BPM_HOST="${GATEWAY_URL}" \
  --set env.API_URL="${GATEWAY_URL}" \
  --set env.APP_CONFIG_APPS_DEPLOYED="[{\"name\": \"${APP_NAME}\" }]" \
  --set env.APP_CONFIG_AUTH_TYPE="OAUTH" \
  --set env.APP_CONFIG_OAUTH2_HOST="${SSO_URL}/realms/${REALM}" \
  --set env.APP_CONFIG_IDENTITY_HOST="${SSO_URL}/admin/realms/${REALM}" \
  --set env.APP_CONFIG_OAUTH2_CLIENTID="activiti" \
  --set env.APP_CONFIG_OAUTH2_REDIRECT_SILENT_IFRAME_URI=${GATEWAY_URL}/alfresco-process-workspace-app/assets/silent-refresh.html \
  alfresco-process-workspace-app alfresco-incubator/alfresco-adf-app

``` 

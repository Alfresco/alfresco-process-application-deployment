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

```bash
export HELM_OPTS="--debug --dry-run"

export APP_NAME="activiti-cloud-full-example"
export CHART_NAME="activiti-cloud-full-example"
export CHART_REPO="activiti-cloud-charts"
export CHART_VERSION="0.7.0"
export DOMAIN=aps2pentest.envalfresco.com
export SSO_HOST=activiti-keycloak.${DOMAIN}
export SSO_URL=https://${SSO_HOST}.${DOMAIN}/auth
export REALM=activiti
export GATEWAY_HOST=activiti-cloud-gateway.${DOMAIN}
export GATEWAY_URL=https://${GATEWAY_HOST}

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

then patch serviceaccount or images to pull secrets:
```bash

kubectl patch serviceaccount default --patch '{"imagePullSecrets": [{"name": "quay-registry-secret"}]}'

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

## Beer Demo Environment Setup

Setup a cluster on AWS (using Kops, EKS doesn't work using eksctl with the current kubectl version):

```bash
export KOPS_CLUSTER_NAME="devcon-beer-demo"
${APS_SCRIPTS_HOME}/create_aws_cluster_with_kops.sh
```

then add helm and ingress:

```bash
export CLUSTER_NAME="devcon-beer-demo"

helm init --upgrade
helm repo update
helm install stable/nginx-ingress
```

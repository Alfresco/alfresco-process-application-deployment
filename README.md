# alfresco-process-application-deployment

Helm chart to install an APS 2.0 application.

## Prerequisites

The APS 2.0 infrastructure should be already installed and ingress configured with the external URLs.

### add quay-registry-secret

Configure access to pull images from quay.io in the namespace where the app is to be installed: 

```bash
kubectl create secret -n "${KUBE_NAMESPACE}" \
  docker-registry quay-secret-quay \
    --docker-server=quay.io \
    --docker-username="${DOCKER_REGISTRY_USER}" \
    --docker-password="${DOCKER_REGISTRY_PASSWORD}" \
    --docker-email="${DOCKER_REGISTRY_EMAIL}"
```

### add license

Create a secret called licenseaps containing the license file in the namespace where the app is to be installed.

```bash
kubectl create secret -n "${KUBE_NAMESPACE}" \
  default licenseaps --from-file=activiti.lic
```                   

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


## Environment Setup

### setup directories
Adjust as per your environment:

```bash
export ACTIVITI_CLOUD_CHARTS_HOME="$HOME/src/Activiti/activiti-cloud-charts"
export APS_APPLICATION_CHART_HOME="$HOME/src/Alfresco/process-services/alfresco-process-application-deployment"
export ACTIVITI_CLOUD_ACCEPTANCE_TESTS_HOME="$HOME/src/Activiti/activiti-cloud-acceptance-scenarios"
```

### set env variables
```bash
export CLUSTER="<cluster>"
export APP_NAME="default-app"
```

### set variables for Docker for Desktop

In order to deploy _Docker for Desktop_ follow the info in the [DBP README](https://github.com/Alfresco/alfresco-dbp-deployment#docker-for-desktop---mac):

```bash
export SSO_HOST="localhost-k8s"
export GATEWAY_HOST="localhost-k8s"
export PROTOCOL="http"
```

then set derived [url env variables](#set-derived-url-env-variables) and run `./install.sh`.

### set variables for AWS Pen Testing environment
```bash
export CLUSTER="aps2pentest"
export APP_NAME="default-app"
```

then set [derived](#set-derived-env-variables) and test.

### set variables for AWS Beer Demo DevCon environment

```bash
export CLUSTER="aps2devcon"
export APP_NAME="beerer"
```

### set env variables
```bash
export DOMAIN="${CLUSTER}.envalfresco.com"
export PROTOCOL="https"
export REALM="alfresco"
```

### set derived host env variables
```bash
export SSO_HOST="activiti-keycloak.${DOMAIN}"
export GATEWAY_HOST="activiti-cloud-gateway.${DOMAIN}"
```

### set derived url env variables
```bash
export SSO_URL="${PROTOCOL}://${SSO_HOST}/auth"
export GATEWAY_URL="${PROTOCOL}://${GATEWAY_HOST}"
```

### set helm variables
```bash
export HELM_OPTS="--debug --dry-run"
```

### set test variables
```bash
export RUNTIME_BUNDLE_URL=${GATEWAY_URL}/${APP_NAME}-rb
export AUDIT_EVENT_URL=${GATEWAY_URL}/${APP_NAME}-audit
export QUERY_URL=${GATEWAY_URL}/${APP_NAME}-query
```

then start with the install:

```bash
export RELEASE_NAME="${APP_NAME}"
export CHART_NAME="application"
export CHART_REPO="activiti-cloud-charts"

helm upgrade \
  --install \
  ${HELM_OPTS} \
  -f values-activiti-to-aps.yaml \
  ${RELEASE_NAME} ${CHART_REPO}/${CHART_NAME}
```

then run acceptance tests:
```bash
cd ${ACTIVITI_CLOUD_ACCEPTANCE_TESTS_HOME}
mvn -pl '!security-policies-acceptance-tests' clean verify serenity:aggregate
```

### setup infrastructure

Choose one of the two:

#### setup alfresco-process-infrastructure

Setup/replace Activiti infrastructure with APS one:

```bash
# create secret with activiti realm
kubectl create secret generic realm-secret --from-file alfresco-aps-realm.json
```

```bash
CHART_REPO=alfresco
CHART_NAME=alfresco-process-infrastructure
RELEASE_NAME=infrastructure

helm upgrade --install ${HELM_OPTS} \
  -f values-${CHART_NAME}.yaml \
  ${RELEASE_NAME} ${CHART_REPO}/${CHART_NAME}
  
# ingress hostname is ignored in alfresco-identity-service chart  
# kubectl edit ingress ${RELEASE_NAME}-alfresco-identity-service
# add spec.rules[0].host=${SSO_HOST}    
```

#### setup alfresco-infrastructure

```bash
CHART_REPO=alfresco
CHART_NAME=alfresco-infrastructure
RELEASE_NAME=infrastructure

helm upgrade --install ${HELM_OPTS} \
  -f values-${CHART_NAME}.yaml \
  ${RELEASE_NAME} ${CHART_REPO}/${CHART_NAME}
```

## setup cluster on AWS

Setup a cluster on AWS using Kops (EKS doesn't work using eksctl with the current kubectl version):

```bash
export KOPS_CLUSTER_NAME=${CLUSTER}
${APS_SCRIPTS_HOME}/create_aws_cluster_with_kops.sh
```

### install helm
```bash
helm init --upgrade
helm repo update
```
### install nginx-ingress
Use nginx-ingress 1.1.2 (tested with ELB):

```bash
NGINX_INGRESS_RELEASE_NAME=nginx-ingress
helm install --name nginx-ingress stable/nginx-ingress --version 1.1.2
export ELB_ADDRESS=$(kubectl get services ${NGINX_INGRESS_RELEASE_NAME}-controller -o jsonpath={.status.loadBalancer.ingress[0].hostname})
```

and add wildcard *.${DOMAIN} DNS entry with new HTTPS cert and set ELB to send HTTPS traffic to HTTP.

then define app name and set env vars, then set [derived](#set-derived-env-variables) and [helm](#set-helm-variables) vars as above

then [setup infrastructure](#setup-infrastructure].

#### install modeling

Install:
```bash
CHART_REPO=activiti-cloud-charts
CHART_NAME=activiti-cloud-modeling
RELEASE_NAME=${CHART_NAME}

cat ${APS_APPLICATION_CHART_HOME}/values-${CHART_NAME}.yaml | envsubst > values.yaml

helm upgrade --install \
  ${HELM_OPTS} \
  -f values.yaml \
  ${RELEASE_NAME} ${CHART_REPO}/${CHART_NAME}

rm values.yaml
``` 


#### run modeling acceptance tests

```bash
cd ${ACTIVITI_CLOUD_ACCEPTANCE_TESTS_HOME}
mvn -pl 'modeling-acceptance-tests' clean verify serenity:aggregate
```


### install application

```bash
cd ${APS_APPLICATION_CHART_HOME}

CHART_REPO=activiti-cloud-charts
CHART_NAME=application
RELEASE_NAME=${APP_NAME}

sed \
  -e "s@\${GATEWAY_HOST}@${GATEWAY_HOST}@" \
  -e "s@\${GATEWAY_URL}@${GATEWAY_URL}@" \
  -e "s@\${SSO_URL}@${SSO_URL}@" \
  -e "s@\${REALM}@${REALM}@" \
  -e "s@\${APP_NAME}@${APP_NAME}@" \
  ${APS_APPLICATION_CHART_HOME}/values-${CHART_NAME}.yaml > values.yaml

# cat ${APS_APPLICATION_CHART_HOME}/values-${CHART_NAME}.yaml | envsubst > values.yaml   

helm upgrade --install \
  ${HELM_OPTS} \
  -f values.yaml \
  -f values-application-${CLUSTER}.yaml \
  -f values-application-to-aps-images.yaml \
  ${RELEASE_NAME} ${CHART_REPO}/${CHART_NAME}

```

### upgrade to use licensed images

```bash
helm upgrade --install \
  ${HELM_OPTS} \
  --reuse-values \
  -f values-application-to-aps-images.yaml \
  ${RELEASE_NAME} ${CHART_REPO}/${CHART_NAME}
```

#### run application acceptance tests

To test, [set test](#set-test-variables) then run:
```bash
cd ${ACTIVITI_CLOUD_ACCEPTANCE_TESTS_HOME}

mvn -pl 'runtime-acceptance-tests,multiple-runtime-acceptance-tests' clean verify serenity:aggregate
```


### deploy process admin

```bash
export FRONTEND_APP_NAME="alfresco-admin-app"

helm upgrade --install --wait \
  ${HELM_OPTS} \
  --set registryPullSecrets=quay-registry-secret \
  --set image.repository=quay.io/alfresco/${FRONTEND_APP_NAME} \
  --set image.tag=latest \
  --set image.pullPolicy=Always \
  --set ingress.hostName="${GATEWAY_HOST}" \
  --set ingress.path="/${FRONTEND_APP_NAME}" \
  --set env.APP_CONFIG_BPM_HOST="${GATEWAY_URL}" \
  --set env.API_URL="${GATEWAY_URL}" \
  --set env.APP_CONFIG_APPS_DEPLOYED="[{\"name\": \"${APP_NAME}\" }]" \
  --set env.APP_CONFIG_AUTH_TYPE="OAUTH" \
  --set env.APP_CONFIG_OAUTH2_HOST="${SSO_URL}/realms/${REALM}" \
  --set env.APP_CONFIG_IDENTITY_HOST="${SSO_URL}/admin/realms/${REALM}" \
  --set env.APP_CONFIG_OAUTH2_CLIENTID="activiti" \
  --set env.APP_CONFIG_OAUTH2_REDIRECT_SILENT_IFRAME_URI="${GATEWAY_URL}/${FRONTEND_APP_NAME}/assets/silent-refresh.html" \
  --set env.APP_CONFIG_OAUTH2_REDIRECT_LOGIN="/${FRONTEND_APP_NAME}/#" \
  --set env.APP_CONFIG_OAUTH2_REDIRECT_LOGOUT="/${FRONTEND_APP_NAME}/#" \
  ${FRONTEND_APP_NAME} alfresco-incubator/alfresco-adf-app
```

### deploy process-workspace-app

```bash
export FRONTEND_APP_NAME="alfresco-process-workspace-app"
```
then [as above](#deploy-process-admin-app).

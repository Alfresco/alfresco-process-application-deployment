# alfresco-process-application-deployment

Helm chart to install an APS 2.0 application.

## Prerequisites

The APS 2.0 infrastructure should be already installed and ingress configured with the external URLs.

### add quay-registry-secret

Configure access to pull images from quay.io in the namespace where the app is to be installed: 

```bash
kubectl create secret \
  docker-registry quay-registry-secret \
    --docker-server=quay.io \
    --docker-username="${DOCKER_REGISTRY_USER}" \
    --docker-password="${DOCKER_REGISTRY_PASSWORD}" \
    --docker-email="${DOCKER_REGISTRY_EMAIL}"
```

### add license

Create a secret called _licenseaps_ containing the license file in the namespace where the app is to be installed.

```bash
kubectl create secret \
  generic licenseaps --from-file activiti.lic
```

## Install

Helm command to install application chart:

```bash
helm install ./helm/alfresco-process-application
```

### install.sh

Helper script to launch installation, to install application chart:

```bash
HELM_OPTS="--debug --dry-run" ./install.sh
```

Verify the k8s yaml output than launch again without `--dry-run`.

Supported optional vars:

* **RELEASE_NAME** to handle upgrade or a non auto-generated release name
* **HELM_OPTS** to pass extra options to helm 


## Environment Setup

### setup directories

Adjust as per your environment:

```bash
export ACTIVITI_CLOUD_CHARTS_HOME="$HOME/src/Activiti/activiti-cloud-charts"
export APS_APPLICATION_CHART_HOME="$HOME/src/Alfresco/process-services/alfresco-process-application-deployment"
export ACTIVITI_CLOUD_ACCEPTANCE_TESTS_HOME="$HOME/src/Activiti/activiti-cloud-acceptance-scenarios"
```

**NB** ACTIVITI_CLOUD_ACCEPTANCE_TESTS_HOME should be on branch __7.0.0.GA-patched-for-notification-service-tests__ in order for tests to work.

### set main variables

```bash
export APP_NAME="default-app"
export REALM="alfresco"
```

### set environment specific variables

#### for Docker for Desktop

```bash
export PROTOCOL="http"
export DOMAIN="local"
```

#### for AWS Pen Testing environment

```bash
export CLUSTER="aps2pentest"
export APP_NAME="default-app"
export PROTOCOL="https"
export DOMAIN="${CLUSTER}.envalfresco.com"
```

### for AWS Beer Demo DevCon environment

```bash
export CLUSTER="aps2devcon"
export APP_NAME="beerer"
export PROTOCOL="https"
export DOMAIN="${CLUSTER}.envalfresco.com"
```

### set derived env variables

```bash
if [[ "${PROTOCOL}" == "http" ]]; then export HTTP=true; else export HTTP=false; fi  
export SSO_HOST="activiti-keycloak.${DOMAIN}"
export GATEWAY_HOST="activiti-cloud-gateway.${DOMAIN}"
export SSO_URL="${PROTOCOL}://${SSO_HOST}/auth"
export GATEWAY_URL="${PROTOCOL}://${GATEWAY_HOST}"
```

If using _Docker for Desktop_ you need to add an entry in your hosts files to map SSO_HOST and GATEWAY_HOST to the address on the network of your machine as in the [DBP README](https://github.com/Alfresco/alfresco-dbp-deployment#8-add-local-dns):

```bash
sudo sh -c "echo \"$(ipconfig getifaddr en0)     $SSO_HOST $GATEWAY_HOST # entries for APS2\" >> /etc/hosts"; cat /etc/hosts
```


### set helm env variables

```bash
export HELM_OPTS="--debug
  --set global.gateway.http=${HTTP}
  --set global.gateway.domain=${DOMAIN}"
```

### set test variables

```bash
export RUNTIME_BUNDLE_SERVICE_NAME=${APP_NAME}-rb
export RUNTIME_BUNDLE_URL=${GATEWAY_URL}/${APP_NAME}-rb
export AUDIT_EVENT_URL=${GATEWAY_URL}/${APP_NAME}-audit
export QUERY_URL=${GATEWAY_URL}/${APP_NAME}-query
```

## setup cluster on AWS

Setup a cluster on AWS using Kops (EKS doesn't work using eksctl with the current kubectl version):

```bash
export KOPS_CLUSTER_NAME=${CLUSTER}
${APS_SCRIPTS_HOME}/create_aws_cluster_with_kops.sh
```

### install helm

Install helm server on the cluster:

```bash
helm init --upgrade
```

then configure the required helm chart repositories:
```
helm repo add activiti-cloud-charts https://activiti.github.io/activiti-cloud-charts
helm repo add alfresco https://kubernetes-charts.alfresco.com/stable
helm repo add alfresco-incubator https://kubernetes-charts.alfresco.com/incubator
helm repo update
```

### helm tips

For any command on helm, please verify the output with `--dry-run` option, then execute without.

### kubectl tips

Check deployment progress with `kubectl get pods --watch` until all containers are running.
If anything is stuck check events with `kubectl get events --watch`.

### install nginx-ingress

Install ingress as follows.
 
*NB* version must be 1.1.x, later ones do not handle rewrite base URL correctly.
*NB* ssl redirect is disabled, otherwise it will not work in http or in https unless you don have a valid certificate.

```bash
NGINX_INGRESS_RELEASE_NAME=nginx-ingress
helm upgrade --install \
  --set-string controller.config.ssl-redirect="false" \
  --version 1.1.5 \
  ${NGINX_INGRESS_RELEASE_NAME} stable/nginx-ingress
```

then add wildcard `*.${DOMAIN}` entry to DNS, for HTTPS use the setup provided by the Activiti cloud charts on ingress-nginx that works with any cloud provider.

#### for AWS

```bash
NGINX_INGRESS_CONTROLLER_NAME=nginx-ingress-controller
[[ "$NGINX_INGRESS_RELEASE_NAME" != 'nginx-ingress' ]] && NGINX_INGRESS_CONTROLLER_NAME=${NGINX_INGRESS_RELEASE_NAME}-${NGINX_INGRESS_CONTROLLER_NAME}
export ELB_ADDRESS=$(kubectl get services ${NGINX_INGRESS_CONTROLLER_NAME} -o jsonpath={.status.loadBalancer.ingress[0].hostname})
```

For HTTPS you have two options:
* use ELB and generate certificate on from the AWS certificate manager and set ELB to send SSL traffic to TCP with proxy protocol
* use NLB and install certificate manager on k8s and terminate SLL on ingress

### setup infrastructure

Setup/replace Activiti infrastructure with APS one:

```bash
export CHART_REPO=alfresco-incubator
export CHART_NAME=alfresco-process-infrastructure
export RELEASE_NAME=infrastructure

helm upgrade --install ${HELM_OPTS} \
  --set alfresco-infrastructure.persistence.enabled=true \
  --set alfresco-content-services.enabled=false \
  ${RELEASE_NAME} ${CHART_REPO}/${CHART_NAME}
  
# ingress hostname is ignored in alfresco-identity-service chart  
# kubectl edit ingress ${RELEASE_NAME}-alfresco-identity-service
# add spec.rules[0].host=${SSO_HOST}
```

#### install modeling

Install:
```bash
cd ${APS_APPLICATION_CHART_HOME}

export CHART_REPO=activiti-cloud-charts
export CHART_NAME=activiti-cloud-modeling
export RELEASE_NAME=${CHART_NAME}

helm upgrade --install \
  ${HELM_OPTS} \
  -f values-global.yaml \
  -f values-${CHART_NAME}.yaml \
  ${RELEASE_NAME} ${CHART_REPO}/${CHART_NAME}
``` 

then run modeling acceptance tests:

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

[[ -f values-application-${CLUSTER}.yaml ]] && HELM_OPTS="${HELM_OPTS} -f values-application-${CLUSTER}.yaml" 

helm upgrade --install \
  ${HELM_OPTS} \
  -f values-global.yaml \
  -f values-activiti-to-aps.yaml \
  ${RELEASE_NAME} ${CHART_REPO}/${CHART_NAME}
```

then [follow installation progress](#kubectl-tips).

#### run application acceptance tests

To test, [set test](#set-test-variables) then run:

```bash
cd ${ACTIVITI_CLOUD_ACCEPTANCE_TESTS_HOME}
mvn -pl 'runtime-acceptance-tests' clean verify serenity:aggregate
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
  ${FRONTEND_APP_NAME} alfresco-incubator/alfresco-adf-app
```

### deploy process-workspace-app

```bash
export FRONTEND_APP_NAME="alfresco-process-workspace-app"
```
then [as above](#deploy-process-admin-app).

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

Helper script to launch installationd:

    HELM_OPTS="--debug --dry-run" ./install.sh

Verify the k8s yaml output than launch again without `--dry-run`.

Supported optional vars:

* RELEASE_NAME to handle upgrade or a non auto-generated release name
* HELM_OPTS to pass extra options to helm 


### run in Docker for Desktop

A custom extra values file to add settings for _Docker for Desktop_ as specified in the [DBP README](https://github.com/Alfresco/alfresco-dbp-deployment#docker-for-desktop---mac) is provided:

    HELM_OPTS="-f docker-for-desktop-values.yaml" ./install.sh

## Pen Testing Setup

```bash
export APP_NAME="activiti-cloud-full-example"
export CHART_NAME="activiti-cloud-full-example"
export CHART_REPO="activiti-cloud-charts"
export CHART_VERSION="0.7.0"
export HELM_OPTS="--debug --dry-run"

helm install ${HELM_OPTS} -f values-aps2pentest-to-https.yaml \
  -f values-gateway-to-ingress.yaml \
  -f values-activiti-to-aps-images.yaml \
  --name $APP_NAME ${CHART_REPO}/${CHART_NAME} --version ${CHART_VERSION}  
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
export SSO_URL=https://activiti-keycloak.aps2pentest.envalfresco.com/auth
export REALM=activiti
export GATEWAY_URL=https://activiti-cloud-gateway.aps2pentest.envalfresco.com
mvn -pl '!security-policies-acceptance-tests' clean verify serenity:aggregate
```


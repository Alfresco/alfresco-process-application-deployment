# alfresco-process-application-deployment

Helm chart to install an APS 2.0 application.

## Prerequisites

The APS 2.0 infrastructure should be already installed and ingress configured with the external URLs.

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


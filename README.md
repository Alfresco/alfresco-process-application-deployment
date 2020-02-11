# alfresco-process-application-deployment

[![Build Status](https://travis-ci.com/Alfresco/alfresco-process-application-deployment.svg?branch=develop)](https://travis-ci.com/Alfresco/alfresco-process-application-deployment)

Helm chart to install an AAE application.

## Prerequisites

Setup a Kubernetes cluster with the [AAE infrastructure](https://github.com/Alfresco/alfresco-process-infrastructure-deployment):

```bash
HELM_OPTS+=" --set alfresco-deployment-service.enabled=false"

helm upgrade aae-infra alfresco-incubator/alfresco-process-infrastructure --version 7.1.0-M6 ${HELM_OPTS} --install --wait
```

A keycloak security client (<https://www.keycloak.org/docs/4.8/server_admin/#oidc-clients>)
must be created with the same name of the application before installing the helm chart.
By default the runtime bundle api will validate the user token against that client.

The expected client level roles are `ACTIVITI_USER` and `ACTIVITI_ADMIN`, and of course
users must be associated to either one of the client level roles.

[This procedure can be automated via the alfresco-deployment-cli](docs/create_application_security_client.md).

### add quay-registry-secret

Configure access to pull images from quay.io in the namespace where the app is to be installed: 

```bash
kubectl create secret \
  docker-registry quay-registry-secret \
    --docker-server=quay.io \
    --docker-username="${DOCKER_REGISTRY_USERNAME}" \
    --docker-password="${DOCKER_REGISTRY_PASSWORD}" \
    --docker-email="none"
```

### add license secret

Create a secret called _licenseaps_ containing the license file in the namespace where the app is to be installed.

```bash
kubectl create secret \
  generic licenseaps --from-file activiti.lic
```

## Install into current namespace using _application_ Helm release name

Helm command to install application chart (review and adjust values.yaml before):

```bash
helm upgrade application ./helm/alfresco-process-application --install --set global.gateway.domain=your-domain.com
```

### install.sh

Helper script to launch installation:

```bash
HELM_OPTS+=" --debug --dry-run" ./install.sh
```

Verify the k8s yaml output than launch again without `--dry-run`.

Supported optional vars:

* **RELEASE_NAME** to handle upgrade or a non auto-generated release name
* **HELM_OPTS** to pass extra options to helm 

## Environment Setup

### setup directories

Adjust as per your environment:

```bash
export AAE_APPLICATION_CHART_HOME="$HOME/src/Alfresco/alfresco-process-application-deployment"
export ACTIVITI_CLOUD_ACCEPTANCE_TESTS_HOME="$HOME/src/Activiti/activiti-cloud-acceptance-scenarios"
```

### set main variables

```bash
export APP_NAME="default-app"
export REALM="alfresco"
```

### set environment specific variables

Define a **PROTOCOL** (_http_ or _https_) and **DOMAIN** for your environment.

#### for Docker Desktop

```bash
export PROTOCOL="http"
export GATEWAY_HOST="localhost"
export SSO_HOST="kubernetes.docker.internal"
```

#### for AAE dev example environment

```bash
export CLUSTER="aaedev"
export PROTOCOL="https"
export DOMAIN="${CLUSTER}.envalfresco.com"
export GATEWAY_HOST="${GATEWAY_HOST:-gateway.${DOMAIN}}"
export SSO_HOST="${SSO_HOST:-identity.${DOMAIN}}"
```

### set helm env variables

```bash
export HELM_OPTS="
  --debug \
  --set global.gateway.http=$(if [[ "${PROTOCOL}" == "http" ]]; then echo true; else echo false; fi) \
  --set global.gateway.host=${GATEWAY_HOST} \
  --set global.keycloak.host=${SSO_HOST} \
  --set global.keycloak.realm=${REALM}
"
```

### set test variables

```bash
export MODELING_URL=${PROTOCOL}://${GATEWAY_HOST}/modeling-service
export GATEWAY_URL=${PROTOCOL}://${GATEWAY_HOST}/${APP_NAME}
export SSO_URL=${PROTOCOL}://${SSO_HOST}/auth
```

#### run application acceptance tests

To test, [set test](#set-test-variables) then run:

```bash
cd ${ACTIVITI_CLOUD_ACCEPTANCE_TESTS_HOME}
mvn -pl 'runtime-acceptance-tests' clean verify serenity:aggregate
```

### override Docker images with internal Docker Registry

```bash

export REGISTRY_HOST=registry.your-domain.com

make login

make values-registry.yaml

HELM_OPTS+="-f values-registry.yaml"
```
then [as install application](#install-application)


## Testing

### Notification Service

Open GraphiQL UI and login with an admin user like _testadmin:password_:
```bash
open ${GATEWAY_URL}/graphiql
```

and input the following GraphQL query after running acceptance tests to see _process instances_:
```
{
  ProcessInstances {
    select {
      id
      status
      name
      processDefinitionId
      processDefinitionKey
      processDefinitionVersion
      tasks {
        id
        name
        status
        assignee
      }
      variables {
        id
        name
        type
        value
      }
    }
  }
}
```

then input the following GraphQL to create a subscription and run processes to see events arriving via websockets:
```
subscription {
 engineEvents {
   serviceName
   appName
   businessKey
   PROCESS_STARTED {
     id
     timestamp
     entity {
       id
       parentId
       name
       description
       businessKey
       initiator
     }
   }
   PROCESS_COMPLETED {
     id
     timestamp
     entity {
       id
       parentId
       name
       description
       businessKey
       initiator
     }
   }
   TASK_CREATED {
     id
     entity {
       id
       priority
       status
       assignee
       dueDate
       createdDate
       claimedDate
       description
     }
   }
   TASK_ASSIGNED {
     id
     entity {
       id
       priority
       status
       assignee
       dueDate
       createdDate
       claimedDate
       description
     }
   }
   TASK_COMPLETED {
     id
     entity {
       id
       priority
       status
       assignee
       dueDate
       createdDate
       claimedDate
       description
     }
   }
 }
}
```
## CI/CD

Running on Travis, requires the following environment variable to be set:

| Name | Description |
|------|-------------|
| GITHUB_TOKEN | GitHub token to clone/push helm repo |

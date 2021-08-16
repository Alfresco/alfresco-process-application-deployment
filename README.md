# alfresco-process-application-deployment

[![Build Status](https://travis-ci.com/Alfresco/alfresco-process-application-deployment.svg?branch=develop)](https://travis-ci.com/Alfresco/alfresco-process-application-deployment)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Helm chart to install an AAE application.

For all the available values, see the chart [README.md](helm/alfresco-process-application/README.md#values).

## Prerequisites

Install the [AAE infrastructure](https://github.com/Alfresco/alfresco-process-infrastructure-deployment):

```bash
HELM_OPTS+=" --set alfresco-deployment-service.enabled=false"

helm upgrade aae alfresco/alfresco-process-infrastructure --version 7.1.0-M10 ${HELM_OPTS[*]} --install --wait
```

A [keycloak security client](https://www.keycloak.org/docs/latest/server_admin/#oidc-clients)
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

## Install Application

Make sure you add the secret of your registry under `registryPullSecrets` in values.yaml and review contents.

Helm command to install application chart:

```bash
helm upgrade app ./helm/alfresco-process-application --install --set global.gateway.domain=your-domain.com
```

## How To Configure Messaging Broker

To deploy Rabbitmq message broker, use `values-rabbitmq.yaml`
```yaml
global:
  messaging:
    broker: rabbitmq

rabbitmq:
  enabled: true

kafka:
  enabled: false
```

To deploy Kafka message broker, use `values-kafka.yaml`
```yaml
global:
  messaging:
    broker: kafka

rabbitmq:
  enabled: false

kafka:
  enabled: true
```

To connect to external Kafka broker, use global.kafka values:
```yaml
global:
  kafka:
    ## global.kafka.brokers -- Multiple brokers can be provided in a comma separated list host[:port], e.g. host1,host2:port
    brokers: "kafka"
    ## global.kafka.extraEnv -- extra environment variables string template for Kafka binder parameters,
    extraEnv: |
      - name: KAFKA_FOO
        value: "BAR"

## Disable provided Kafka chart
kafka:
  enabled: false
```


To enable partitioned messaging use the following `values-partitioned.yaml`
```yaml
global:
  messaging:
    partitioned: true
    partitionCount: 2
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

Adjust as in your local development environment:

```bash
export AAE_APPLICATION_CHART_HOME="$HOME/src/Alfresco/alfresco-process-application-deployment"
export ACTIVITI_CLOUD_ACCEPTANCE_TESTS_HOME="$HOME/src/Activiti/activiti-cloud-application/activiti-cloud-acceptance-scenarios"
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
export SSO_HOST="host.docker.internal"
```

#### for AAE dev example environment

```bash
export CLUSTER="aaedev"
export PROTOCOL="https"
export DOMAIN="${CLUSTER}.envalfresco.com"
export GATEWAY_HOST="${GATEWAY_HOST:-${DOMAIN}}"
export SSO_HOST="${SSO_HOST:-${DOMAIN}}"
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


### Configuration steps for using Volume to get Project files:
**Note**: This block of steps only relevant if you are using: [example-application-project](https://github.com/Alfresco/example-process-application/tree/master/example-application-project) to fetch project files.
```
1. Once the example-project image is built and push to your choice of registry, make sure you add the registry-secret for that registry on the namespace you going to deploy this app.
2. update values in **values.yaml***
   - add repository url for volumeinit to pull the project files image
   - In runtime-bundle - update projectName in order to allow PROJECT_MANIFEST_FILE_PATH to point to the correct json file.

Installation step:

Note: make sure your Release name is the same as CLASSPATH_DIRECTORY_NAME passed in build.properties for example-applcation-project.

helm upgrade app ./helm/alfresco-process-application  --install --set global.gateway.domain=your-domain.com
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
then [install application](#install-application)


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

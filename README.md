# alfresco-process-application-deployment

Helm chart to install an AAE application.

## Prerequisites

The [AAE infrastructure](https://git.alfresco.com/process-services-public/alfresco-process-infrastructure-deployment) should be already installed and ingress configured with the external URLs.

A keycloak security client(https://www.keycloak.org/docs/6.0/server_admin/#oidc-clients)
must be created with the same name of the application before installing the helm chart.
By default the runtime bundle api will validate the user token against that client.

The expected client level roles are ACTIVITI_USER and ACTIVITI_ADMIN, and of course
users must be associated to either one of the client level roles.

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
export APS_APPLICATION_CHART_HOME="$HOME/src/Alfresco/process-services-public/alfresco-process-application-deployment"
export ACTIVITI_CLOUD_ACCEPTANCE_TESTS_HOME="$HOME/src/Activiti/activiti-cloud-acceptance-scenarios"
```

### set main variables

```bash
export APP_NAME="default-app"
export REALM="alfresco"
```

### set environment specific variables

Define a **PROTOCOL** (_http_ or _https_) and **DOMAIN** for your environment.

#### for Docker for Desktop

```bash
export PROTOCOL="http"
export GATEWAY_HOST="localhost"
export SSO_HOST="host.docker.internal"
```

You need to add an entry in your hosts files to map the magic docker hostname to localhost for keycloak to work, similar to what is documented in the [DBP README](https://github.com/Alfresco/alfresco-dbp-deployment#8-add-local-dns):

```bash
sudo sh -c "echo \"127.0.0.1 host.docker.internal # entry for docker-for-desktop\" >> /etc/hosts"; cat /etc/hosts
```


#### for AWS DevCon example demo environment

```bash
export CLUSTER="aps2devcon"
export PROTOCOL="https"
export DOMAIN="${CLUSTER}.envalfresco.com"
export GATEWAY_HOST="${GATEWAY_HOST:-activiti-cloud-gateway.${DOMAIN}}"
export SSO_HOST="${SSO_HOST:-activiti-keycloak.${DOMAIN}}"
```

### set derived env variables

```bash
if [[ "${PROTOCOL}" == "http" ]]; then export HTTP=true; else export HTTP=false; fi  
export GATEWAY_URL="${PROTOCOL}://${GATEWAY_HOST}"
export SSO_URL="${PROTOCOL}://${SSO_HOST}/auth"
```

### set helm env variables

```bash
export HELM_OPTS="--debug
  --set global.gateway.http=${HTTP}
  --set global.gateway.host=${GATEWAY_HOST}
  --set global.keycloak.host=${SSO_HOST}
  --set global.keycloak.realm=${REALM}"
```

### set test variables

```bash
export MODELING_URL=${GATEWAY_URL}/modeling-service
export RUNTIME_BUNDLE_URL=${GATEWAY_URL}/${APP_NAME}/rb
export AUDIT_EVENT_URL=${GATEWAY_URL}/${APP_NAME}/audit
export QUERY_URL=${GATEWAY_URL}/${APP_NAME}/query
export GRAPHQL_URL=${GATEWAY_URL}/${APP_NAME}/notifications/graphql
export GRAPHQL_WS_URL=${GATEWAY_URL/http/ws}/${APP_NAME}/notifications/ws/graphql
```

## setup cluster

Setup a Kubernetes cluster using the guidelines in the [Alfresco DBP README](https://github.com/Alfresco/alfresco-dbp-deployment#alfresco-digital-business-platform-deployment).


### install helm

Install helm server on the cluster:

```bash
helm init --upgrade
```

then configure the required helm chart repositories:
```
helm repo add activiti-cloud-charts https://activiti.github.io/activiti-cloud-charts
helm repo add activiti-cloud-helm-charts https://activiti.github.io/activiti-cloud-helm-charts
helm repo add alfresco https://kubernetes-charts.alfresco.com/stable
helm repo add alfresco-incubator https://kubernetes-charts.alfresco.com/incubator
helm repo update
```

### helm tips

For any command on helm, please verify the output with `--dry-run` option, then execute without.

To install from the development chart repo, use `alfresco-incubator` rather than `alfresco` as **CHART_REPO** variable.

### kubectl tips

Check deployment progress with `kubectl get pods --watch` until all containers are running.
If anything is stuck check events with `kubectl get events --watch`.

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

export HELM_OPTS="${HELM_OPTS} -f values-registry.yaml"
```
then [as install application](#install-application)


## Testing

### Notification Service

Open GraphiQL UI and login with an admin user like _testadmin:password_:
```bash
open ${GATEWAY_URL}/${APP_NAME}/graphiql
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


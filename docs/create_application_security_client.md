## Description

The [alfresco-deployment-cli](https://git.alfresco.com/process-services/alfresco-process-cli) is a script to help in the setup of the Keycloak client with roles users/groups association.

In order for things to work, you'll need to have users or groups with a specific roles (`ACTIVITI_ADMIN`, `ACTIVITI_USER`).

## Usage

Run with an argument of the path to what is an application client json describing which users/groups should be associates with.

Create a file as follows, naming it `application.json`:

```json
{
  "name": "app_client_name",
  "security": [
    {
      "role": "APS_USER",
      "groups": [
        "your_user_group"
      ],
      "users": [
        "your_user"
      ]
    },
    {
      "role": "APS_ADMIN",
      "groups": [],
      "users": [
        "your_admin"
      ]
    }
  ]
}
```
*NB* The `role` field values needs to be as it is in this provided example, the `APS_ADMIN` stands for `ACTIVITI_ADMIN` and so on.

### How to run with Docker

Login on quay.io to pull the docker image with your credentials.

Set the target keycloak and specify your application json client file and execute as follows:

``` bash
docker run -it --rm \
  --env KEYCLOAK_AUTHSERVERURL=https://identity.***/auth \
  --env ACT_KEYCLOAK_CLIENT_APP=admin-cli \
  --env ACT_KEYCLOAK_CLIENT_USER=client \
  --env ACT_KEYCLOAK_CLIENT_PASSWORD=client \
  --volume "$PWD":/tmp/app \
  quay.io/alfresco/alfresco-deployment-cli:7.1.0.M4 /tmp/app/application.json
```

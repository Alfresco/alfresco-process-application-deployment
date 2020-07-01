alfresco-process-application
============================
A Helm chart for an Alfresco Activiti Enterprise application

Current chart version is `7.1.0-M9`

Source code can be found [here](https://github.com/Alfresco/alfresco-process-application-deployment)

## Chart Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://activiti.github.io/activiti-cloud-helm-charts | activiti-cloud-connector | 7.1.0-M9 |
| https://activiti.github.io/activiti-cloud-helm-charts | activiti-cloud-query | 7.1.0-M9 |
| https://activiti.github.io/activiti-cloud-helm-charts | runtime-bundle | 7.1.0-M9 |
| https://kubernetes-charts.alfresco.com/stable | alfresco-adf-app | 2.2.1 |
| https://kubernetes-charts.alfresco.com/stable | alfresco-adf-app | 2.2.1 |
| https://kubernetes-charts.alfresco.com/stable | alfresco-adf-app | 2.2.1 |
| https://kubernetes-charts.storage.googleapis.com | postgresql | 6.3.9 |
| https://kubernetes-charts.storage.googleapis.com | rabbitmq-ha | 1.38.1 |

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| activiti-cloud-connector.affinity | object | `{}` |  |
| activiti-cloud-connector.enabled | bool | `false` |  |
| activiti-cloud-connector.extraEnv | string | `"- name: SERVER_PORT\n  value: \"8080\"\n- name: SERVER_SERVLET_CONTEXTPATH\n  value: \"{{ tpl .Values.ingress.path . }}\"\n- name: SERVER_USEFORWARDHEADERS\n  value: \"true\"\n- name: SERVER_TOMCAT_INTERNALPROXIES\n  value: \".*\"\n- name: ACTIVITI_CLOUD_APPLICATION_NAME\n  value: \"{{ .Release.Name }}\"\n"` |  |
| activiti-cloud-connector.image.repository | string | `"activiti/example-cloud-connector"` |  |
| activiti-cloud-connector.image.tag | string | `"7.1.0-M9"` |  |
| activiti-cloud-connector.ingress.enabled | bool | `true` |  |
| activiti-cloud-connector.ingress.path | string | `"/{{ .Release.Name }}/{{ .Values.nameOverride }}"` |  |
| activiti-cloud-connector.nameOverride | string | `"example-cloud-connector"` |  |
| activiti-cloud-connector.probePath | string | `"{{ tpl .Values.ingress.path . }}/actuator/health"` |  |
| activiti-cloud-query.affinity | object | `{}` |  |
| activiti-cloud-query.enabled | bool | `true` |  |
| activiti-cloud-query.extraEnv | string | `"- name: SERVER_PORT\n  value: \"8080\"\n- name: SERVER_USEFORWARDHEADERS\n  value: \"true\"\n- name: SERVER_TOMCAT_INTERNALPROXIES\n  value: \".*\"\n- name: KEYCLOAK_USERESOURCEROLEMAPPINGS\n  value: \"false\"\n- name: ACTIVITI_CLOUD_APPLICATION_NAME\n  value: \"{{ .Release.Name }}\"\n- name: GRAPHIQL_GRAPHQL_WS_PATH\n  value: '/{{ .Release.Name }}/notifications/ws/graphql'\n- name: GRAPHIQL_GRAPHQL_WEB_PATH\n  value: '/{{ .Release.Name }}/notifications/graphql'\n"` |  |
| activiti-cloud-query.extraVolumeMounts | string | `"- name: license\n  mountPath: \"/root/.activiti/enterprise-license/\"\n  readOnly: true\n"` |  |
| activiti-cloud-query.extraVolumes | string | `"- name: license\n  secret:\n    secretName: licenseaps\n"` |  |
| activiti-cloud-query.image.repository | string | `"quay.io/alfresco/alfresco-process-query-service"` |  |
| activiti-cloud-query.image.tag | string | `"7.1.0-M9"` |  |
| activiti-cloud-query.ingress.enabled | bool | `true` |  |
| activiti-cloud-query.ingress.path | string | `"/{{ .Release.Name }}"` |  |
| activiti-cloud-query.nameOverride | string | `"query"` |  |
| activiti-cloud-query.postgres.enabled | bool | `true` |  |
| activiti-cloud-query.probePath | string | `"/actuator/health"` |  |
| alfresco-admin-app.enabled | bool | `false` |  |
| alfresco-admin-app.env.APP_CONFIG_APPS_DEPLOYED | string | `"[{\"name\": \"{{ .Release.Name }}\" }]"` |  |
| alfresco-admin-app.env.APP_CONFIG_AUTH_TYPE | string | `"OAUTH"` |  |
| alfresco-admin-app.env.APP_CONFIG_BPM_HOST | string | `"{{ include \"common.gateway-url\" . }}"` |  |
| alfresco-admin-app.env.APP_CONFIG_IDENTITY_HOST | string | `"{{ include \"common.keycloak-url\" . }}/admin/realms/{{ include \"common.keycloak-realm\" . }}"` |  |
| alfresco-admin-app.image.pullPolicy | string | `"Always"` |  |
| alfresco-admin-app.image.repository | string | `"quay.io/alfresco/alfresco-admin-app"` |  |
| alfresco-admin-app.image.tag | string | `"7.1.0-M9"` |  |
| alfresco-admin-app.ingress.path | string | `"/{{ .Release.Name }}/admin"` |  |
| alfresco-admin-app.nameOverride | string | `"admin-app"` |  |
| alfresco-digital-workspace-app.enabled | bool | `false` |  |
| alfresco-digital-workspace-app.env.APP_CONFIG_APPS_DEPLOYED | string | `"[{\"name\": \"{{ .Release.Name }}\" }]"` |  |
| alfresco-digital-workspace-app.env.APP_CONFIG_AUTH_TYPE | string | `"OAUTH"` |  |
| alfresco-digital-workspace-app.env.APP_CONFIG_BPM_HOST | string | `"{{ include \"common.gateway-url\" . }}"` |  |
| alfresco-digital-workspace-app.env.APP_CONFIG_ECM_HOST | string | `"{{ include \"common.gateway-url\" . }}"` |  |
| alfresco-digital-workspace-app.env.APP_CONFIG_IDENTITY_HOST | string | `"{{ include \"common.keycloak-url\" . }}/admin/realms/{{ include \"common.keycloak-realm\" . }}"` |  |
| alfresco-digital-workspace-app.env.APP_CONFIG_PROVIDER | string | `"ALL"` |  |
| alfresco-digital-workspace-app.env.APP_WITH_PROCESS | string | `"true"` |  |
| alfresco-digital-workspace-app.image.repository | string | `"quay.io/alfresco/alfresco-digital-workspace"` |  |
| alfresco-digital-workspace-app.image.tag | string | `"7.1.0-M9"` |  |
| alfresco-digital-workspace-app.ingress.path | string | `"/{{ .Release.Name }}/digital-workspace"` |  |
| alfresco-digital-workspace-app.nameOverride | string | `"digital-workspace-app"` |  |
| alfresco-process-workspace-app.enabled | bool | `false` |  |
| alfresco-process-workspace-app.env.APP_CONFIG_APPS_DEPLOYED | string | `"[{\"name\": \"{{ .Release.Name }}\" }]"` |  |
| alfresco-process-workspace-app.env.APP_CONFIG_AUTH_TYPE | string | `"OAUTH"` |  |
| alfresco-process-workspace-app.env.APP_CONFIG_BPM_HOST | string | `"{{ include \"common.gateway-url\" . }}"` |  |
| alfresco-process-workspace-app.image.repository | string | `"quay.io/alfresco/alfresco-process-workspace-app"` |  |
| alfresco-process-workspace-app.image.tag | string | `"7.1.0-M9"` |  |
| alfresco-process-workspace-app.ingress.path | string | `"/{{ .Release.Name }}/workspace"` |  |
| alfresco-process-workspace-app.nameOverride | string | `"workspace-app"` |  |
| global.applicationVersion | string | `"1"` |  |
| global.contentService.enabled | string | `"false"` |  |
| global.extraEnv | string | `""` | YAML formatted string to add extra environment properties to all deployments |
| global.gateway.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| global.gateway.annotations."nginx.ingress.kubernetes.io/cors-allow-headers" | string | `"*"` |  |
| global.gateway.annotations."nginx.ingress.kubernetes.io/enable-cors" | string | `"true"` |  |
| global.gateway.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$1"` |  |
| global.gateway.domain | string | `"REPLACEME"` | gateway domain template, i.e. {{ .Release.Namespace }}.1.3.4.5.nip.io helm upgrade activiti . --install --set global.gateway.domain=1.2.3.4.nip.io |
| global.gateway.host | string | `"{{ include \"common.gateway-domain\" . }}"` | global annotations for all service ingress resources |
| global.gateway.http | string | `"false"` |  |
| global.gateway.tlsacme | string | `"true"` |  |
| global.image.pullPolicy | string | `"Always"` |  |
| global.keycloak.host | string | `"{{ include \"common.gateway-domain\" . }}"` | Keycloak host template, i.e. "{{ .Release.Namespace }}.{{ .Values.global.gateway.domain }}" |
| global.keycloak.realm | string | `"alfresco"` | Keycloak realm |
| global.keycloak.resource | string | `"activiti"` | Keycloak resource |
| global.keycloak.url | string | `""` | full url to configure external Keycloak, https://keycloak.mydomain.com/auth |
| global.registryPullSecrets | list | `["quay-registry-secret"]` | Configure pull secrets for all deployments |
| persistence.accessModes[0] | string | `"ReadWriteMany"` |  |
| persistence.baseSize | string | `"1Gi"` |  |
| persistence.enabled | bool | `true` |  |
| persistence.storageClassName | string | `"default-sc"` |  |
| postgres.enabled | bool | `true` |  |
| postgres.image.repository | string | `"postgres"` |  |
| postgres.image.tag | float | `11.4` |  |
| postgres.postgresqlDataDir | string | `"/var/lib/postgresql/data/pgdata"` |  |
| postgres.postgresqlPassword | string | `"password"` |  |
| postgres.resources.requests.cpu | string | `"350m"` |  |
| postgres.resources.requests.memory | string | `"512Mi"` |  |
| rabbitmq.enabled | bool | `true` |  |
| rabbitmq.ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| rabbitmq.ingress.annotations."nginx.ingress.kubernetes.io/cors-allow-headers" | string | `"*"` |  |
| rabbitmq.ingress.annotations."nginx.ingress.kubernetes.io/enable-cors" | string | `"true"` |  |
| rabbitmq.ingress.annotations."nginx.ingress.kubernetes.io/x-forwarded-prefix" | string | `"true"` |  |
| rabbitmq.ingress.enabled | bool | `false` |  |
| rabbitmq.ingress.hostName | string | `"REPLACEME"` |  |
| rabbitmq.ingress.path | string | `"/rabbitmq"` |  |
| rabbitmq.persistentVolume.enabled | bool | `true` |  |
| rabbitmq.rabbitmqErlangCookie | string | `"124567890abcdefghijklmnopqrstuv"` |  |
| rabbitmq.rabbitmqPassword | string | `"guest"` |  |
| rabbitmq.rabbitmqSTOMPPlugin.enabled | bool | `true` |  |
| rabbitmq.rabbitmqUsername | string | `"guest"` |  |
| rabbitmq.rbac.create | bool | `true` |  |
| rabbitmq.replicaCount | int | `1` |  |
| rabbitmq.resources.limits.cpu | int | `1` |  |
| rabbitmq.resources.limits.memory | string | `"2Gi"` |  |
| rabbitmq.resources.requests.cpu | string | `"350m"` |  |
| rabbitmq.resources.requests.memory | string | `"512Mi"` |  |
| rabbitmq.service.clusterIP | string | `"None"` |  |
| runtime-bundle.affinity | object | `{}` |  |
| runtime-bundle.enabled | bool | `true` |  |
| runtime-bundle.extraEnv | string | `"- name: SERVER_PORT\n  value: \"8080\"\n- name: SERVER_USEFORWARDHEADERS\n  value: \"true\"\n- name: SERVER_TOMCAT_INTERNALPROXIES\n  value: \".*\"\n- name: ACTIVITI_CLOUD_APPLICATION_NAME\n  value: \"{{ .Release.Name }}\"\n- name: ACT_KEYCLOAK_RESOURCE\n  value: \"{{ .Release.Name }}\"\n- name: KEYCLOAK_USERESOURCEROLEMAPPINGS\n  value: \"true\"\n- name: SPRING_ACTIVITI_PROCESSDEFINITIONLOCATIONPREFIX\n  value: 'file:/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/processes/'\n- name: PROJECT_MANIFEST_FILE_PATH\n  value: 'file:/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/{{ .Values.projectName }}.json'\n- name: APPLICATION_VERSION\n  value: '{{ .Values.global.applicationVersion }}'\n- name: ACT_RB_SERVICE_URL\n  value: '{{ include \"common.gateway-url\" . }}/{{ .Release.Name }}/{{ .Values.nameOverride }}'\n- name: DMNCONFIGURATION_TABLESDEFINITIONSDIRECTORYPATH\n  value: 'file:/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/decision-tables/'\n- name: FORMCONFIGURATION_FORMSDEFINITIONSDIRECTORYPATH\n  value: 'file:/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/forms/'\n- name: CONTENTSERVICE_ENABLED\n  value: '{{ .Values.global.contentService.enabled }}'\n"` |  |
| runtime-bundle.extraVolumeMounts | string | `"- name: license\n  mountPath: \"/root/.activiti/enterprise-license/\"\n  readOnly: true\n- name: {{ .Release.Name }}\n  mountPath: '/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/'\n"` |  |
| runtime-bundle.extraVolumes | string | `"- name: license\n  secret:\n    secretName: licenseaps\n- name: {{ .Release.Name }}\n  persistentVolumeClaim:\n    claimName: {{ .Release.Name }}\n"` |  |
| runtime-bundle.image.repository | string | `"quay.io/alfresco/alfresco-process-runtime-bundle-service"` |  |
| runtime-bundle.image.tag | string | `"7.1.0-M9"` |  |
| runtime-bundle.ingress.enabled | bool | `true` |  |
| runtime-bundle.ingress.path | string | `"/{{ .Release.Name }}"` |  |
| runtime-bundle.ingress.subPaths[0] | string | `"/rb/?(.*)"` |  |
| runtime-bundle.ingress.subPaths[1] | string | `"/preference/?(.*)"` |  |
| runtime-bundle.ingress.subPaths[2] | string | `"/form/?(.*)"` |  |
| runtime-bundle.ingress.subPaths[3] | string | `"/process-storage/?(.*)"` |  |
| runtime-bundle.nameOverride | string | `"rb"` |  |
| runtime-bundle.postgres.enabled | bool | `true` |  |
| runtime-bundle.probePath | string | `"/actuator/health"` |  |
| runtime-bundle.projectName | string | `"example-app"` |  |
| volumeinit.enabled | bool | `true` |  |
| volumeinit.image.pullPolicy | string | `"Always"` |  |
| volumeinit.image.tag | string | `"latest"` |  |

# alfresco-process-application

![Version: 7.1.0-M11](https://img.shields.io/badge/Version-7.1.0--M11-informational?style=flat-square) ![AppVersion: 7.1.0-M11](https://img.shields.io/badge/AppVersion-7.1.0--M11-informational?style=flat-square)

A Helm chart for an Alfresco Activiti Enterprise application

**Homepage:** <https://github.com/Alfresco/alfresco-process-application-deployment>

## Requirements

Kubernetes: `>=1.15.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://activiti.github.io/activiti-cloud-helm-charts | activiti-cloud-connector | 7.1.0-M10 |
| https://activiti.github.io/activiti-cloud-helm-charts | activiti-cloud-query | 7.1.0-M10 |
| https://activiti.github.io/activiti-cloud-helm-charts | runtime-bundle | 7.1.0-M10 |
| https://charts.bitnami.com/bitnami | postgresql | 8.9.6 |
| https://charts.bitnami.com/bitnami | rabbitmq | 7.6.8 |
| https://kubernetes-charts.alfresco.com/incubator | alfresco-adf-app | 7.1.0-M11 |
| https://kubernetes-charts.alfresco.com/incubator | alfresco-adf-app | 7.1.0-M11 |
| https://kubernetes-charts.alfresco.com/incubator | alfresco-adf-app | 7.1.0-M11 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| activiti-cloud-connector.affinity | object | `{}` |  |
| activiti-cloud-connector.enabled | bool | `false` |  |
| activiti-cloud-connector.extraEnv | string | `"- name: SERVER_PORT\n  value: \"8080\"\n- name: SERVER_SERVLET_CONTEXTPATH\n  value: \"{{ tpl .Values.ingress.path . }}\"\n- name: SERVER_USEFORWARDHEADERS\n  value: \"true\"\n- name: SERVER_TOMCAT_INTERNALPROXIES\n  value: \".*\"\n- name: ACTIVITI_CLOUD_APPLICATION_NAME\n  value: \"{{ .Release.Name }}\"\n"` |  |
| activiti-cloud-connector.image.repository | string | `"activiti/example-cloud-connector"` |  |
| activiti-cloud-connector.image.tag | string | `"develop"` |  |
| activiti-cloud-connector.ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| activiti-cloud-connector.ingress.annotations."nginx.ingress.kubernetes.io/cors-allow-headers" | string | `"*"` |  |
| activiti-cloud-connector.ingress.annotations."nginx.ingress.kubernetes.io/enable-cors" | string | `"true"` |  |
| activiti-cloud-connector.ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$1"` |  |
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
| activiti-cloud-query.image.tag | string | `"develop"` |  |
| activiti-cloud-query.ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| activiti-cloud-query.ingress.annotations."nginx.ingress.kubernetes.io/cors-allow-headers" | string | `"*"` |  |
| activiti-cloud-query.ingress.annotations."nginx.ingress.kubernetes.io/enable-cors" | string | `"true"` |  |
| activiti-cloud-query.ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$1"` |  |
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
| alfresco-admin-app.image.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| alfresco-admin-app.image.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$1"` |  |
| alfresco-admin-app.image.repository | string | `"quay.io/alfresco/alfresco-admin-app"` |  |
| alfresco-admin-app.image.tag | string | `"develop"` |  |
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
| alfresco-digital-workspace-app.image.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| alfresco-digital-workspace-app.image.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$1"` |  |
| alfresco-digital-workspace-app.image.repository | string | `"quay.io/alfresco/alfresco-digital-workspace"` |  |
| alfresco-digital-workspace-app.image.tag | string | `"develop"` |  |
| alfresco-digital-workspace-app.ingress.path | string | `"/{{ .Release.Name }}/digital-workspace"` |  |
| alfresco-digital-workspace-app.nameOverride | string | `"digital-workspace-app"` |  |
| alfresco-process-workspace-app.enabled | bool | `false` |  |
| alfresco-process-workspace-app.env.APP_CONFIG_APPS_DEPLOYED | string | `"[{\"name\": \"{{ .Release.Name }}\" }]"` |  |
| alfresco-process-workspace-app.env.APP_CONFIG_AUTH_TYPE | string | `"OAUTH"` |  |
| alfresco-process-workspace-app.env.APP_CONFIG_BPM_HOST | string | `"{{ include \"common.gateway-url\" . }}"` |  |
| alfresco-process-workspace-app.image.repository | string | `"quay.io/alfresco/alfresco-process-workspace-app"` |  |
| alfresco-process-workspace-app.image.tag | string | `"develop"` |  |
| alfresco-process-workspace-app.ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| alfresco-process-workspace-app.ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$1"` |  |
| alfresco-process-workspace-app.ingress.path | string | `"/{{ .Release.Name }}/workspace"` |  |
| alfresco-process-workspace-app.nameOverride | string | `"workspace-app"` |  |
| global | object | `{"acs":{"enabled":false},"applicationVersion":"1","gateway":{"annotations":{},"domain":"","host":"{{ template \"common.gateway-domain\" . }}","http":false,"tlsacme":false},"image":{"pullPolicy":"Always"},"keycloak":{"host":"{{ template \"common.gateway-host\" . }}","realm":"alfresco","resource":"alfresco","url":""},"registryPullSecrets":["quay-registry-secret"]}` | for common values see https://github.com/Activiti/activiti-cloud-common-chart/blob/master/charts/common/README.md |
| global.acs.enabled | bool | `false` | enable support for ACS |
| global.gateway.annotations | object | `{}` | Configure global annotations for all service ingresses |
| global.gateway.domain | string | `""` | Set to configure gateway domain template, i.e. {{ .Release.Namespace }}.1.3.4.5.nip.io $ helm upgrade aae . --install --set global.gateway.domain=1.2.3.4.nip.io |
| global.gateway.host | string | `"{{ template \"common.gateway-domain\" . }}"` | Set to configure single host domain name for all services, i.e. "{{ .Release.Namespace }}.{{ template "common.gateway-domain" . }}" |
| global.gateway.http | bool | `false` | Set to false enables HTTPS configuration on all urls |
| global.gateway.tlsacme | bool | `false` | Set to enable automatic TLS for ingress if https is enabled |
| global.keycloak.host | string | `"{{ template \"common.gateway-host\" . }}"` | Configure Keycloak host template, i.e. "{{ .Release.Namespace }}.{{ .Values.global.gateway.domain }}" |
| global.keycloak.realm | string | `"alfresco"` | Configure Keycloak realm |
| global.keycloak.resource | string | `"alfresco"` | Configure Keycloak resource |
| global.keycloak.url | string | `""` | Set full url to configure external Keycloak, https://keycloak.mydomain.com/auth |
| global.registryPullSecrets | list | `["quay-registry-secret"]` | Configure pull secrets for all deployments |
| persistence.accessModes[0] | string | `"ReadWriteMany"` |  |
| persistence.baseSize | string | `"1Gi"` |  |
| persistence.enabled | bool | `true` |  |
| persistence.storageClassName | string | `"default-sc"` |  |
| postgresql.enabled | bool | `true` |  |
| postgresql.image.repository | string | `"postgres"` |  |
| postgresql.image.tag | float | `11.7` |  |
| postgresql.postgresqlDataDir | string | `"/var/lib/postgresql/data/pgdata"` |  |
| postgresql.postgresqlPassword | string | `"password"` |  |
| postgresql.resources.requests.cpu | string | `"350m"` |  |
| postgresql.resources.requests.memory | string | `"512Mi"` |  |
| rabbitmq.auth.erlangCookie | string | `"ylY79lOdNUWsJEwAGdVQnhjSazV4QZKO="` |  |
| rabbitmq.auth.password | string | `"guest"` |  |
| rabbitmq.auth.username | string | `"guest"` |  |
| rabbitmq.enabled | bool | `true` |  |
| rabbitmq.ingress.enabled | bool | `false` |  |
| rabbitmq.ingress.hostName | string | `"REPLACEME"` |  |
| rabbitmq.ingress.path | string | `"/rabbitmq"` |  |
| rabbitmq.persistence.storageClass | string | `nil` |  |
| rabbitmq.rbac.create | bool | `true` |  |
| rabbitmq.replicaCount | int | `1` |  |
| rabbitmq.resources.limits.cpu | string | `"1"` |  |
| rabbitmq.resources.limits.memory | string | `"2Gi"` |  |
| rabbitmq.resources.requests.cpu | string | `"350m"` |  |
| rabbitmq.resources.requests.memory | string | `"512Mi"` |  |
| runtime-bundle.affinity | object | `{}` |  |
| runtime-bundle.enabled | bool | `true` |  |
| runtime-bundle.extraEnv | string | `"- name: SERVER_PORT\n  value: \"8080\"\n- name: SERVER_USEFORWARDHEADERS\n  value: \"true\"\n- name: SERVER_TOMCAT_INTERNALPROXIES\n  value: \".*\"\n- name: ACTIVITI_CLOUD_APPLICATION_NAME\n  value: \"{{ .Release.Name }}\"\n- name: ACT_KEYCLOAK_RESOURCE\n  value: \"{{ .Release.Name }}\"\n- name: KEYCLOAK_USERESOURCEROLEMAPPINGS\n  value: \"true\"\n- name: SPRING_ACTIVITI_PROCESSDEFINITIONLOCATIONPREFIX\n  value: 'file:/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/processes/'\n- name: PROJECT_MANIFEST_FILE_PATH\n  value: 'file:/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/{{ .Values.projectName }}.json'\n- name: APPLICATION_VERSION\n  value: '{{ .Values.global.applicationVersion }}'\n- name: ACT_RB_SERVICE_URL\n  value: '{{ include \"common.gateway-url\" . }}/{{ .Release.Name }}/{{ .Values.nameOverride }}'\n- name: DMNCONFIGURATION_TABLESDEFINITIONSDIRECTORYPATH\n  value: 'file:/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/decision-tables/'\n- name: FORMCONFIGURATION_FORMSDEFINITIONSDIRECTORYPATH\n  value: 'file:/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/forms/'\n- name: CONTENT_SERVICE_ENABLED\n  value: \"{{ .Values.global.acs.enabled }}\"\n"` |  |
| runtime-bundle.extraVolumeMounts | string | `"- name: license\n  mountPath: \"/root/.activiti/enterprise-license/\"\n  readOnly: true\n- name: {{ .Release.Name }}\n  mountPath: '/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/'\n"` |  |
| runtime-bundle.extraVolumes | string | `"- name: license\n  secret:\n    secretName: licenseaps\n- name: {{ .Release.Name }}\n  persistentVolumeClaim:\n    claimName: {{ .Release.Name }}\n"` |  |
| runtime-bundle.image.repository | string | `"quay.io/alfresco/alfresco-process-runtime-bundle-service"` |  |
| runtime-bundle.image.tag | string | `"develop"` |  |
| runtime-bundle.ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| runtime-bundle.ingress.annotations."nginx.ingress.kubernetes.io/cors-allow-headers" | string | `"*"` |  |
| runtime-bundle.ingress.annotations."nginx.ingress.kubernetes.io/enable-cors" | string | `"true"` |  |
| runtime-bundle.ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$1"` |  |
| runtime-bundle.ingress.enabled | bool | `true` |  |
| runtime-bundle.ingress.path | string | `"/{{ .Release.Name }}"` |  |
| runtime-bundle.ingress.subPaths[0] | string | `"/rb/?(.*)"` |  |
| runtime-bundle.ingress.subPaths[1] | string | `"/preference/?(.*)"` |  |
| runtime-bundle.ingress.subPaths[2] | string | `"/form/?(.*)"` |  |
| runtime-bundle.nameOverride | string | `"rb"` |  |
| runtime-bundle.postgres.enabled | bool | `true` |  |
| runtime-bundle.probePath | string | `"/actuator/health"` |  |
| runtime-bundle.projectName | string | `"example-app"` |  |
| volumeinit.enabled | bool | `true` |  |
| volumeinit.image.pullPolicy | string | `"Always"` |  |
| volumeinit.image.tag | string | `"latest"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.4.0](https://github.com/norwoodj/helm-docs/releases/v1.4.0)

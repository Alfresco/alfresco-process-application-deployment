# alfresco-process-application

![Version: 7.1.0-M15](https://img.shields.io/badge/Version-7.1.0--M15-informational?style=flat-square) ![AppVersion: 7.1.0-M15](https://img.shields.io/badge/AppVersion-7.1.0--M15-informational?style=flat-square)

A Helm chart for an Alfresco Activiti Enterprise application

**Homepage:** <https://github.com/Alfresco/alfresco-process-application-deployment>

## Requirements

Kubernetes: `>=1.15.0-0`

| Repository | Name | Version |
|------------|------|---------|
| https://activiti.github.io/activiti-cloud-helm-charts | activiti-cloud-query(common) | 7.1.0-M14 |
| https://activiti.github.io/activiti-cloud-helm-charts | runtime-bundle(common) | 7.1.0-M14 |
| https://activiti.github.io/activiti-cloud-helm-charts | activiti-cloud-connector(common) | 7.1.0-M14 |
| https://activiti.github.io/activiti-cloud-helm-charts | alfresco-admin-app(common) | 7.1.0-M14 |
| https://activiti.github.io/activiti-cloud-helm-charts | alfresco-digital-workspace-app(common) | 7.1.0-M14 |
| https://charts.bitnami.com/bitnami | kafka | 12.x.x |
| https://charts.bitnami.com/bitnami | postgresql | 9.1.1 |
| https://charts.bitnami.com/bitnami | rabbitmq | 7.8.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| activiti-cloud-connector.affinity | object | `{}` |  |
| activiti-cloud-connector.enabled | bool | `false` |  |
| activiti-cloud-connector.extraEnv | string | `"- name: SERVER_PORT\n  value: \"8080\"\n- name: SERVER_SERVLET_CONTEXTPATH\n  value: \"{{ tpl .Values.ingress.path . }}\"\n- name: SERVER_USEFORWARDHEADERS\n  value: \"true\"\n- name: SERVER_TOMCAT_INTERNALPROXIES\n  value: \".*\"\n- name: ACTIVITI_CLOUD_APPLICATION_NAME\n  value: \"{{ .Release.Name }}\"\n"` |  |
| activiti-cloud-connector.image.pullPolicy | string | `"Always"` |  |
| activiti-cloud-connector.image.repository | string | `"activiti/example-cloud-connector"` |  |
| activiti-cloud-connector.image.tag | string | `"develop"` |  |
| activiti-cloud-connector.ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| activiti-cloud-connector.ingress.annotations."nginx.ingress.kubernetes.io/cors-allow-headers" | string | `"*"` |  |
| activiti-cloud-connector.ingress.annotations."nginx.ingress.kubernetes.io/enable-cors" | string | `"true"` |  |
| activiti-cloud-connector.ingress.enabled | bool | `true` |  |
| activiti-cloud-connector.ingress.path | string | `"/{{ .Release.Name }}/{{ .Values.nameOverride }}"` |  |
| activiti-cloud-connector.messaging.enabled | bool | `true` |  |
| activiti-cloud-connector.messaging.role | string | `"connector"` |  |
| activiti-cloud-connector.nameOverride | string | `"example-cloud-connector"` |  |
| activiti-cloud-connector.probePath | string | `"{{ tpl .Values.ingress.path . }}/actuator/health"` |  |
| activiti-cloud-query.activiti.keycloak.clientPassword | string | `"client"` |  |
| activiti-cloud-query.affinity | object | `{}` |  |
| activiti-cloud-query.db.ddlAuto | string | `"none"` | set to 'none' temporarily rather than default 'validate' that breaks |
| activiti-cloud-query.enabled | bool | `true` |  |
| activiti-cloud-query.extraEnv | string | `"- name: SERVER_PORT\n  value: \"8080\"\n- name: SERVER_USEFORWARDHEADERS\n  value: \"true\"\n- name: SERVER_TOMCAT_INTERNALPROXIES\n  value: \".*\"\n- name: KEYCLOAK_USERESOURCEROLEMAPPINGS\n  value: \"false\"\n- name: ACTIVITI_KEYCLOAK_CLIENT_PASSWORD\n  value: '{{ .Values.activiti.keycloak.clientPassword }}'\n- name: ACTIVITI_CLOUD_APPLICATION_NAME\n  value: \"{{ .Release.Name }}\"\n- name: GRAPHIQL_GRAPHQL_WS_PATH\n  value: '/{{ .Release.Name }}/notifications/ws/graphql'\n- name: GRAPHIQL_GRAPHQL_WEB_PATH\n  value: '/{{ .Release.Name }}/notifications/graphql'\n"` |  |
| activiti-cloud-query.extraVolumeMounts | string | `"- name: license\n  mountPath: \"/root/.activiti/enterprise-license/\"\n  readOnly: true\n"` |  |
| activiti-cloud-query.extraVolumes | string | `"- name: license\n  secret:\n    secretName: licenseaps\n"` |  |
| activiti-cloud-query.image.pullPolicy | string | `"Always"` |  |
| activiti-cloud-query.image.repository | string | `"quay.io/alfresco/alfresco-process-query-service"` |  |
| activiti-cloud-query.image.tag | string | `"develop"` |  |
| activiti-cloud-query.ingress.annotations."kubernetes.io/ingress.class" | string | `"nginx"` |  |
| activiti-cloud-query.ingress.annotations."nginx.ingress.kubernetes.io/affinity" | string | `"cookie"` |  |
| activiti-cloud-query.ingress.annotations."nginx.ingress.kubernetes.io/cors-allow-headers" | string | `"*"` |  |
| activiti-cloud-query.ingress.annotations."nginx.ingress.kubernetes.io/enable-cors" | string | `"true"` |  |
| activiti-cloud-query.ingress.annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"/$1"` |  |
| activiti-cloud-query.ingress.annotations."nginx.ingress.kubernetes.io/session-cookie-change-on-failure" | string | `"true"` |  |
| activiti-cloud-query.ingress.annotations."nginx.ingress.kubernetes.io/session-cookie-name" | string | `"activiti-cloud-query-session"` |  |
| activiti-cloud-query.ingress.enabled | bool | `true` |  |
| activiti-cloud-query.ingress.path | string | `"/{{ .Release.Name }}"` |  |
| activiti-cloud-query.ingress.subPaths[0] | string | `"/query/?(.*)"` |  |
| activiti-cloud-query.ingress.subPaths[1] | string | `"/audit/?(.*)"` |  |
| activiti-cloud-query.ingress.subPaths[2] | string | `"/notifications/?(.*)"` |  |
| activiti-cloud-query.javaOpts.xms | string | `"512m"` |  |
| activiti-cloud-query.javaOpts.xmx | string | `"2048m"` |  |
| activiti-cloud-query.liquibase.enabled | bool | `true` |  |
| activiti-cloud-query.messaging.enabled | bool | `true` |  |
| activiti-cloud-query.messaging.role | string | `"consumer"` |  |
| activiti-cloud-query.nameOverride | string | `"activiti-cloud-query"` |  |
| activiti-cloud-query.postgresql.enabled | bool | `true` |  |
| activiti-cloud-query.probePath | string | `"/actuator/health"` |  |
| activiti-cloud-query.resources.limits.cpu | string | `"1.5"` |  |
| activiti-cloud-query.resources.limits.memory | string | `"2048Mi"` |  |
| activiti-cloud-query.resources.requests.cpu | string | `"200m"` |  |
| activiti-cloud-query.resources.requests.memory | string | `"512Mi"` |  |
| activiti-cloud-query.service.name | string | `"query"` |  |
| alfresco-admin-app.enabled | bool | `false` |  |
| alfresco-admin-app.env.APP_CONFIG_APPS_DEPLOYED | string | `"[{\"name\": \"{{ .Release.Name }}\" }]"` |  |
| alfresco-admin-app.env.APP_CONFIG_AUTH_TYPE | string | `"OAUTH"` |  |
| alfresco-admin-app.env.APP_CONFIG_BPM_HOST | string | `"{{ include \"common.gateway-url\" . }}"` |  |
| alfresco-admin-app.env.APP_CONFIG_IDENTITY_HOST | string | `"{{ include \"common.keycloak-url\" . }}/admin/realms/{{ include \"common.keycloak-realm\" . }}"` |  |
| alfresco-admin-app.extraEnv | string | `"{{- if not .Values.global.acs.enabled }}\n- name: APP_CONFIG_PROVIDER\n  value: BPM\n{{- end }}"` |  |
| alfresco-admin-app.image.pullPolicy | string | `"Always"` |  |
| alfresco-admin-app.image.repository | string | `"quay.io/alfresco/alfresco-admin-app"` |  |
| alfresco-admin-app.image.tag | string | `"develop"` |  |
| alfresco-admin-app.ingress.path | string | `"/{{ .Release.Name }}/admin"` |  |
| alfresco-admin-app.nameOverride | string | `"admin-app"` |  |
| alfresco-admin-app.service.envType | string | `"frontend"` |  |
| alfresco-admin-app.service.name | string | `"admin-app"` |  |
| alfresco-digital-workspace-app.enabled | bool | `false` |  |
| alfresco-digital-workspace-app.env.APP_CONFIG_APPS_DEPLOYED | string | `"[{\"name\": \"{{ .Release.Name }}\" }]"` |  |
| alfresco-digital-workspace-app.env.APP_CONFIG_AUTH_TYPE | string | `"OAUTH"` |  |
| alfresco-digital-workspace-app.env.APP_CONFIG_BPM_HOST | string | `"{{ include \"common.gateway-url\" . }}"` |  |
| alfresco-digital-workspace-app.env.APP_CONFIG_ECM_HOST | string | `"{{ include \"common.gateway-url\" . }}"` |  |
| alfresco-digital-workspace-app.env.APP_CONFIG_IDENTITY_HOST | string | `"{{ include \"common.keycloak-url\" . }}/admin/realms/{{ include \"common.keycloak-realm\" . }}"` |  |
| alfresco-digital-workspace-app.env.APP_CONFIG_PROVIDER | string | `"ALL"` |  |
| alfresco-digital-workspace-app.image.pullPolicy | string | `"Always"` |  |
| alfresco-digital-workspace-app.image.repository | string | `"quay.io/alfresco/alfresco-digital-workspace"` |  |
| alfresco-digital-workspace-app.image.tag | string | `"develop"` |  |
| alfresco-digital-workspace-app.ingress.path | string | `"/{{ .Release.Name }}/digital-workspace"` |  |
| alfresco-digital-workspace-app.nameOverride | string | `"digital-workspace-app"` |  |
| alfresco-digital-workspace-app.service.envType | string | `"frontend"` |  |
| alfresco-digital-workspace-app.service.name | string | `"adw-app"` |  |
| global | object | `{"acs":{"enabled":false},"applicationVersion":"1","gateway":{"annotations":{},"domain":"","host":"{{ template \"common.gateway-domain\" . }}","http":false,"tlsacme":false},"kafka":{"brokers":"kafka","extraEnv":"- name: ACT_AUDIT_PRODUCER_TRANSACTION_ID_PREFIX\n  value: \"\"\n","zkNodes":"zookeeper"},"keycloak":{"host":"{{ template \"common.gateway-host\" . }}","realm":"alfresco","resource":"{{ .Release.Name }}","url":""},"messaging":{"broker":"rabbitmq","partitionCount":2,"partitioned":false},"rabbitmq":{"extraEnv":"","host":"rabbitmq","password":"guest","username":"guest"},"registryPullSecrets":["quay-registry-secret"]}` | for common values see https://github.com/Activiti/activiti-cloud-common-chart/blob/master/charts/common/README.md |
| global.acs.enabled | bool | `false` | enable support for ACS |
| global.gateway.annotations | object | `{}` | Configure global annotations for all service ingresses |
| global.gateway.domain | string | `""` | Set to configure gateway domain template, i.e. {{ .Release.Namespace }}.1.3.4.5.nip.io $ helm upgrade aae . --install --set global.gateway.domain=1.2.3.4.nip.io |
| global.gateway.host | string | `"{{ template \"common.gateway-domain\" . }}"` | Set to configure single host domain name for all services, i.e. "{{ .Release.Namespace }}.{{ template "common.gateway-domain" . }}" |
| global.gateway.http | bool | `false` | Set to false enables HTTPS configuration on all urls |
| global.gateway.tlsacme | bool | `false` | Set to enable automatic TLS for ingress if https is enabled |
| global.keycloak.host | string | `"{{ template \"common.gateway-host\" . }}"` | Configure Keycloak host template, i.e. "{{ .Release.Namespace }}.{{ .Values.global.gateway.domain }}" |
| global.keycloak.realm | string | `"alfresco"` | Configure Keycloak realm |
| global.keycloak.resource | string | `"{{ .Release.Name }}"` | Configure Keycloak resource |
| global.keycloak.url | string | `""` | Set full url to configure external Keycloak, https://keycloak.mydomain.com/auth |
| global.messaging.broker | string | `"rabbitmq"` | required supported messaging broker, i.e rabbitmq or kafka |
| global.messaging.partitionCount | int | `2` | configures number of partitioned consumers and producers |
| global.messaging.partitioned | bool | `false` | enables partitioned messaging in combination with common values of messaging.enabled=true and messaging.role=producer|consumer |
| global.registryPullSecrets | list | `["quay-registry-secret"]` | Configure pull secrets for all deployments |
| kafka.enabled | bool | `false` |  |
| kafka.fullnameOverride | string | `"kafka"` |  |
| kafka.offsetsTopicReplicationFactor | int | `1` |  |
| kafka.replicaCount | int | `1` |  |
| kafka.zookeeper.fullnameOverride | string | `"zookeeper"` |  |
| kafka.zookeeper.replicaCount | int | `1` |  |
| persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| persistence.baseSize | string | `"1Gi"` |  |
| persistence.enabled | bool | `true` |  |
| persistence.storageClassName | string | `nil` |  |
| postgresql.commonAnnotations.application | string | `"activiti"` |  |
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
| rabbitmq.extraPlugins | string | `""` |  |
| rabbitmq.fullnameOverride | string | `"rabbitmq"` |  |
| rabbitmq.ingress.enabled | bool | `false` |  |
| rabbitmq.ingress.hostName | string | `"REPLACEME"` |  |
| rabbitmq.ingress.path | string | `"/rabbitmq"` |  |
| rabbitmq.livenessProbe.timeoutSeconds | int | `90` |  |
| rabbitmq.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| rabbitmq.persistence.storageClass | string | `nil` |  |
| rabbitmq.readinessProbe.timeoutSeconds | int | `90` |  |
| rabbitmq.replicaCount | int | `1` |  |
| rabbitmq.resources.limits.cpu | string | `"1"` |  |
| rabbitmq.resources.limits.memory | string | `"2Gi"` |  |
| rabbitmq.resources.requests.cpu | string | `"350m"` |  |
| rabbitmq.resources.requests.memory | string | `"512Mi"` |  |
| runtime-bundle.activiti.keycloak.clientPassword | string | `"client"` |  |
| runtime-bundle.affinity | object | `{}` |  |
| runtime-bundle.enabled | bool | `true` |  |
| runtime-bundle.extraEnv | string | `"- name: SERVER_PORT\n  value: \"8080\"\n- name: SERVER_USEFORWARDHEADERS\n  value: \"true\"\n- name: SERVER_TOMCAT_INTERNALPROXIES\n  value: \".*\"\n- name: ACTIVITI_CLOUD_APPLICATION_NAME\n  value: \"{{ .Release.Name }}\"\n- name: KEYCLOAK_USERESOURCEROLEMAPPINGS\n  value: \"true\"\n- name: ACTIVITI_KEYCLOAK_CLIENT_PASSWORD\n  value: '{{ .Values.activiti.keycloak.clientPassword }}'\n- name: SPRING_ACTIVITI_PROCESSDEFINITIONLOCATIONPREFIX\n  value: 'file:/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/processes/'\n- name: PROJECT_MANIFEST_FILE_PATH\n  value: 'file:/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/{{ .Values.projectName }}.json'\n- name: APPLICATION_VERSION\n  value: \"{{ .Values.global.applicationVersion }}\"\n- name: ACT_RB_SERVICE_URL\n  value: '{{ include \"common.gateway-url\" . }}/{{ .Release.Name }}/rb'\n- name: DMNCONFIGURATION_TABLESDEFINITIONSDIRECTORYPATH\n  value: 'file:/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/decision-tables/'\n- name: FORMCONFIGURATION_FORMSDEFINITIONSDIRECTORYPATH\n  value: 'file:/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/forms/'\n- name: CONTENT_SERVICE_ENABLED\n  value: \"{{ .Values.global.acs.enabled }}\"\n- name: \"APPLICATION_EMAIL_ENABLED\"\n  value: \"false\"\n"` |  |
| runtime-bundle.extraVolumeMounts | string | `"- name: license\n  mountPath: \"/root/.activiti/enterprise-license/\"\n  readOnly: true\n- name: {{ .Release.Name }}\n  mountPath: '/root/.activiti/project-release-volume/{{ .Values.global.applicationVersion }}/'\n"` |  |
| runtime-bundle.extraVolumes | string | `"- name: license\n  secret:\n    secretName: licenseaps\n- name: {{ .Release.Name }}\n  persistentVolumeClaim:\n    claimName: {{ .Release.Name }}\n"` |  |
| runtime-bundle.image.pullPolicy | string | `"Always"` |  |
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
| runtime-bundle.javaOpts.xms | string | `"512m"` |  |
| runtime-bundle.javaOpts.xmx | string | `"2048m"` |  |
| runtime-bundle.messaging.enabled | bool | `true` |  |
| runtime-bundle.messaging.role | string | `"producer"` |  |
| runtime-bundle.nameOverride | string | `"runtime-bundle"` |  |
| runtime-bundle.postgresql.enabled | bool | `true` |  |
| runtime-bundle.probePath | string | `"/actuator/health"` |  |
| runtime-bundle.projectName | string | `"example-app"` |  |
| runtime-bundle.resources.limits.cpu | string | `"2"` |  |
| runtime-bundle.resources.limits.memory | string | `"2048Mi"` |  |
| runtime-bundle.resources.requests.cpu | string | `"200m"` |  |
| runtime-bundle.resources.requests.memory | string | `"512Mi"` |  |
| runtime-bundle.service.name | string | `"rb"` |  |
| volumeinit.enabled | bool | `true` |  |
| volumeinit.image | object | `{"pullPolicy":"Always","repository":"alfresco/example-application-project","tag":"latest"}` | REPLACE with your image containing project files |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.5.0](https://github.com/norwoodj/helm-docs/releases/v1.5.0)

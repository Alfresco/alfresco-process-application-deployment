DOCKER_REGISTRY := $(or $(DOCKER_REGISTRY),$(REGISTRY_HOST))
VALUES_REGISTRY_TMPL := $(or $(VALUES_REGISTRY_TMPL), values-registry.tmpl)

.EXPORT_ALL_VARIABLES:

AC_TAG := 7.1.0.M3.1
AAE_TAG := 2.3.0
APW_APP_TAG := 2.3.0
APA_APP_TAG := 2.3.0
RABBITMQ_TAG := 3.7-alpine
POSTGRESQL_TAG := 10.7.0
ALPINE_TAG := 3.8
BUSYBOX_TAG := 1.30.1
MINIDEB_TAG := stretch

IMAGES := activiti/example-cloud-connector@$(AC_TAG) \
activiti/example-runtime-bundle@$(AC_TAG) \
quay.io/alfresco/alfresco-process-audit-service@$(AAE_TAG) \
quay.io/alfresco/alfresco-process-query-service@$(AAE_TAG) \
quay.io/alfresco/alfresco-admin-app@$(APA_APP_TAG) \
quay.io/alfresco/alfresco-process-notifications-graphql-service@$(AAE_TAG) \
quay.io/alfresco/alfresco-process-workspace-app@$(APW_APP_TAG) \
quay.io/alfresco/alfresco-dmn-runtime-service@$(AAE_TAG) \
quay.io/alfresco/alfresco-form-service@$(AAE_TAG) \
quay.io/alfresco/alfresco-preference-service@$(AAE_TAG) \
alpine@$(ALPINE_TAG) \
bitnami/postgresql@$(POSTGRESQL_TAG) \
bitnami/minideb@$(MINIDEB_TAG) \
busybox@$(BUSYBOX_TAG) \
rabbitmq@$(RABBITMQ_TAG)

.PHONY: $(IMAGES)

all: images values

test:
	@if test -z "$(DOCKER_REGISTRY)"; then echo "Error: missing DOCKER_REGISTRY argument or env variable."; exit 1; fi

login: test
	docker login quay.io
	docker login $(DOCKER_REGISTRY)

pull: $(foreach image,$(IMAGES),$(image)\pull)

tag: test $(foreach image,$(IMAGES),$(image)\tag)

push: test $(foreach image,$(IMAGES),$(image)\push)

images: test pull tag push

values: 
	@envsubst < $(VALUES_REGISTRY_TMPL) > values-registry.yaml
	@echo Values generated in values-registry.yaml

list: $(foreach image,$(IMAGES),$(image)\print)

clean:
	rm values-registry.yaml || true

$(foreach image,$(IMAGES),$(image)\pull): ## Pull container image
	$(eval IMAGE := $(subst \, ,$@))
	docker pull $(word 1, $(subst @,:,$(IMAGE)))

$(foreach image,$(IMAGES),$(image)\tag): ## Tag container image
	$(eval IMAGE := $(subst \, ,$@))
	docker tag $(word 1, $(subst @,:,$(IMAGE))) $(DOCKER_REGISTRY)/$(word 1, $(subst @,:,$(IMAGE)))

$(foreach image,$(IMAGES),$(image)\push): ## Push container image
	$(eval IMAGE := $(subst \, ,$@))
	docker push $(DOCKER_REGISTRY)/$(word 1, $(subst @,:,$(IMAGE)))

$(foreach image,$(IMAGES),$(image)\print): ## Print container image
	$(eval IMAGE := $(subst \, ,$@))
	@echo $(word 1, $(subst @,:,$(IMAGE)))

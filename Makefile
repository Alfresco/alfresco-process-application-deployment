DOCKER_REGISTRY := $(or $(DOCKER_REGISTRY),$(APS_REGISTRY_HOST))
VALUES_REGISTRY_TMPL := $(or $(VALUES_REGISTRY_TMPL), values-registry.tmpl)

IMAGES := activiti/example-cloud-connector@7.0.0.GA \
activiti/activiti-cloud-notifications-graphql@7.0.0.GA \
activiti/activiti-cloud-modeling@7.0.0.GA \
activiti/activiti-modeling-app@7.0.0.GA \
quay.io/alfresco/alfresco-process-audit-service@develop \
quay.io/alfresco/alfresco-process-query-service@develop \
quay.io/alfresco/alfresco-example-process-runtime-bundle-service@develop \
quay.io/alfresco/alfresco-admin-app@latest \
quay.io/alfresco/alfresco-process-workspace-app@latest \
alpine@3.8 \
bitnami/postgresql@10.7.0 \
wrouesnel/postgres_exporter@v0.4.7 \
bitnami/minideb@latest \
busybox@latest \
rabbitmq@3.7-alpine \
kbudde/rabbitmq-exporter@v0.29.0

.PHONY: $(IMAGES)

values-registry.yaml: test pull tag push values

test:
	test $(DOCKER_REGISTRY)

login: test
	docker login quay.io
	docker login $(DOCKER_REGISTRY)

pull: $(foreach image,$(IMAGES),$(image)\pull)

tag: $(foreach image,$(IMAGES),$(image)\tag)

push: $(foreach image,$(IMAGES),$(image)\push)

values: test
	@envsubst < $(VALUES_REGISTRY_TMPL) > values-registry.yaml
	@echo Values generated in values-registry.yaml

print: $(foreach image,$(IMAGES),$(image)\print)

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

EXCLUDE_FIELDS ?= .metadata.uid, .status, .metadata.namespace, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.annotations
NAMESPACE ?= openshift-user-workload-monitoring

#
# alertmanager tasks
#
alertmanager-config:
	@oc apply -f alertmanager/alertmanager-config.yaml

alertmanager-trusted-bundle:
	@oc -n openshift-monitoring get cm alertmanager-trusted-ca-bundle -o yaml | \
		yq e --no-colors 'del($(EXCLUDE_FIELDS))' | oc -n $(NAMESPACE) apply -f -

alertmanager-proxy-secret:
	@oc -n openshift-monitoring get secret alertmanager-main-proxy -o yaml | yq e --no-colors 'del($(EXCLUDE_FIELDS))' | oc -n $(NAMESPACE) apply -f -

alertmanager-app:
	@oc apply -f alertmanager/alertmanager.yaml

#
# prometheus tasks
#
prometheus-trusted-bundle:
	@oc -n openshift-monitoring get cm prometheus-trusted-ca-bundle -o yaml | \
		yq e --no-colors 'del($(EXCLUDE_FIELDS))' | oc -n $(NAMESPACE) apply -f -

prometheus-kubelet-bundle:
	@oc -n openshift-monitoring get cm kubelet-serving-ca-bundle -o yaml | \
		yq e --no-colors 'del($(EXCLUDE_FIELDS))' | oc -n $(NAMESPACE) apply -f -

prometheus-metrics-certs:
	@oc -n openshift-monitoring get secret metrics-client-certs -o yaml | \
		yq e --no-colors 'del($(EXCLUDE_FIELDS))' | oc -n $(NAMESPACE) apply -f -

prometheus-proxy-secret:
	@oc -n openshift-monitoring get secret prometheus-k8s-proxy -o yaml | yq e --no-colors 'del($(EXCLUDE_FIELDS))' | oc -n $(NAMESPACE) apply -f -

prometheus-config-role:
	@oc -n openshift-monitoring get role prometheus-k8s-config -o yaml | yq e --no-colors 'del($(EXCLUDE_FIELDS))' | oc -n $(NAMESPACE) apply -f -

prometheus-alertmanager-role:
	@oc -n openshift-monitoring get role monitoring-alertmanager-edit -o yaml | yq e --no-colors 'del($(EXCLUDE_FIELDS))' | oc -n $(NAMESPACE) apply -f -

prometheus-app:
	@oc apply -f prometheus/prometheus.yaml

#
# workflow tasks (create)
#
.PHONY: setup
setup: namespace metrics-client-ca

.PHONY: alertmanager
alertmanager: alertmanager-config alertmanager-trusted-bundle alertmanager-proxy-secret alertmanager-app

.PHONY: prometheus
prometheus: prometheus-trusted-bundle prometheus-kubelet-bundle prometheus-metrics-certs prometheus-proxy-secret prometheus-config-role prometheus-alertmanager-role prometheus-app

#
# workflow tasks (destroy)
#
alertmanager-destroy:
	@oc delete -f alertmanager/alertmanager.yaml && \
		oc -n $(NAMESPACE) delete secret alertmanager-custom alertmanager-main-proxy && \
		oc -n $(NAMESPACE) delete cm alertmanager-trusted-ca-bundle

prometheus-destroy:
	@oc delete -f prometheus/prometheus.yaml && \
		oc -n $(NAMESPACE) delete secret metrics-client-certs prometheus-k8s-proxy && \
		oc -n $(NAMESPACE) delete cm prometheus-trusted-ca-bundle kubelet-serving-ca-bundle

clean:
	oc delete ns $(NAMESPACE)

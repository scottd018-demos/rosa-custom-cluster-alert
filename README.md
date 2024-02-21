# Summary

This is a quick walkthrough to show you how to configure custom alerts, beyond user-workload alerts, to include 
cluster alerts in ROSA.

**NOTE:** ROSA relies on a dedicated SRE team to monitor the cluster.  This would be helpful in an instance in which 
you need to be alerted on something specific to the platform, **in addition** to having SRE monitor for you.  This is 
not common but may serve some use cases.


## Prereqs

- ROSA Cluster Running with user-workload-monitoring enabled
- yq (used for make targets)
- cluster-admin to the ROSA cluster


## Review the Alert Manager Config

First, review the AlertManager config file in the `alertmanager/alertmanager-config.yaml` directory.  The sample 
includes the following:

- All alerts from a ROSA cluster (version 4.14)
- Sample Slack backend

You may wish to eliminate some of this configuration and switch your backend (e.g. PagerDuty)


## Deploy AlertManager

The following deploys AlertManager into the `openshift-user-workload-monitoring` namespace.  This namespace is used 
because it already has an instance of the Prometheus operator running.

```
make alertmanager
```


## Deploy Prometheus

The following deploys Prometheus into the `openshift-user-workload-monitoring` namespace.  This namespace is used 
because it already has an instance of the Prometheus operator running.

```
make prometheus
```


## Disclaimer

I am by no means a Prometheus expert.  The project is sufficiently large and complex enough that there could be better 
ways to deploy this.  I simply was after demonstrating a working concept.  If you have suggestions, I am happy to take 
them and either update or take a PR!

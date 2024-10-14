
# Steps to Deploy on K8S

The deployment of the resources was done in the Kubernetes cluster that is distributed along with Docker Desktop. The main advantage of solving the exercise here is that I can deploy a local image in the Kubernetes cluster.

If you are testing in a different cluster, you must upload the image to a Docker image repository like Docker Hub or any other.

1.- Install prometheus

`helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`
`helm repo update`
`helm upgrade prometheus prometheus-community/kube-prometheus-stack`

When I installed Prometheus in the cluster, I detected an issue with the prometheus-node-exporter pod. The problem is explained here (https://github.com/prometheus-community/helm-charts/issues/325)

To solve the issue, set hostRootFsMount to false:

`helm show values prometheus-community/kube-prometheus-stack > values.yaml`

Then, edit values.yaml and add the following:

```yaml
prometheus-node-exporter:
    hostRootFsMount:
        enabled: false
```

Finally, apply the changes:

`helm upgrade prometheus prometheus-community/kube-prometheus-stack -f  values.yaml`

## 2 - Deploy storage API

- Create deployment for store API  expose port 5000 (deployment.yaml)
- Create storage service (service.yaml)
- Create ServiceMonitor for prometheus(serviceMonitor.yaml)

### 2.1 - Deploy the resources
> kubectl apply -f deployment.yaml
> kubectl apply -f service.yaml
> kubectl apply -f serviceMonitor.yaml

### 2.2 - Add ServiceMonitorSelector to prometheus.

- modify values.yaml adding
  
```yaml
ServiceMonitorSelector:
    matchLabels:
        app: storage
```

- apply changes on prometheus

`helm upgrade prometheus prometheus-community/kube-prometheus-stack -f  values.yaml`
  
## 3- Install Grafana

`helm repo add grafana https://grafana.github.io/helm-charts`
`helm repo update`

`helm install grafana grafana/grafana`

### 3.1 - Authenticating using the secret

`kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`

### 3.2 - Set Datasource prometheus

http://prometheus-kube-prometheus-prometheus:9090
    (I can do by code but i dont have time now)

## 4- Create Dashboard

- To access the Grafana and Prometheus services, perform port-forwarding
- make port-forwarding to storage service and run the script `generate_traffic.sh`

## Destroy All

```sh
helm delete prometheus
helm delete grafana 
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
kubectl delete -f serviceMonitor.yaml
```

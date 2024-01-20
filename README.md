# Configurations

This repository contains the configurations for developing and deploying the microservices-based application Frankensound.  
Follow the instructions below to setup:

## Development
1. Clone the repository
    ```
    git clone git@github.com:frankensound/configurations.git
    ```
2. Create an  ``` .env ``` file in the root directory of the repository
3. Copy and modify the values in the provided ```example.env``` file. Since we are using Docker Compose to run the containers, the host value will be ```host.docker.internal```.  

    To supply the Auth0 values, create an account and create a domain for your application.  
    Then, follow tutorials to setup a Machine to Machine application with Auth0 Management API privileges.  
    Lastly, generate a token (which expires every 24h) for this and add it to the environment variables.  

4. Clone the other repositories in the organization in the following hierarchy:
    ```
    frankensound/
    ├─ backend/
    │  ├─ gateway/
    │  │  ├─ Accounts/
    │  │  ├─ Gateway/
    │  ├─ microservices/
    │  │  ├─ history/
    │  │  ├─ songs/
    ├─ client/
    ├─ configurations/
    │  ├─ kubernetes/
    │  ├─ README.md   <--- you are here
    ```
5. Navigate to the configurations folder in your terminal of choice and run:
    ```
    docker compose up
    ```
## Deployment
### Local
Before starting to follow the steps below, move the files in ```kubernetes/secrets/examples``` into ```kubernetes/secrets``` and populate the keys with your values.

Remember to encode the secrets to base64 before proceeding.
#### Minikube
1. Clone the repository
    ```
    git clone git@github.com:frankensound/configurations.git
    ```
2. Install kubectl and minikube on your system of choice
3. Run the following commands:
    ```
    minikube start
    # Optional command, if minikube can't find the context
    docker context use default 
    minikube addons enable ingress
    ```
4. Navigate to the ```kubernetes``` folder, and run:
    ```
    kubectl apply -f .\secrets\
    kubectl apply -f .\applications\
    kubectl apply -f .\applications\ingress\
    ```
5. On Windows, edit the hosts file under ```C:\Windows\System32\drivers\etc``` and add the following line at the end:
    ```
    127.0.0.1 frankensound.test
    ```
6. Finally, open a new terminal and run:
    ```
    minikube tunnel
    ```
Now the application should be accessible by navigating to ```http://frankensound.test```.  
Alternatively, you can leave out the host name configuration, and the application will be accessible at ```http://localhost```.  

You can always visualise the deployments by running ```minikube dashboard``` in a new terminal.
#### Docker Desktop
1. Clone the repository
    ```
    git clone git@github.com:frankensound/configurations.git
    ```
2. Install kubectl on your system of choice
3. Enable Kubernetes engine in Docker Desktop settings
4. Install the ingress controller manually:
    ```
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
    ```
5. On Windows, edit the hosts file under ```C:\Windows\System32\drivers\etc``` and add the following line at the end:
    ```
    127.0.0.1 frankensound.test
    ```
6. Navigate to the ```kubernetes``` folder, and run:
    ```
    kubectl apply -f .\secrets\
    kubectl apply -f .\applications\
    kubectl apply -f .\applications\ingress\
    ```
Now the application should be accessible by navigating to ```http://frankensound.test```.  
Alternatively, you can leave out the host name configuration, and the application will be accessible at ```http://kubernetes.docker.internal```.

### Cloud
Using Terraform and the Azure CLI, as well as services from AWS and MongoDB.
1. First, login using ```az login``` command in your terminal of choice.
2. Set the current subscription to the subscription that you want to use by running:
    ```
    az account set --subscription <id>
    ```
3. Then create a service principal with ```owner``` rights:
    ```
    az ad sp create-for-rbac --name "<name>" --role owner --scopes /subscriptions/<id> --sdk-auth
    ```
4. Set the following environment variables into the Terraform Cloud workspace as sensitive environment variables: 
- For Azure:
    - ```ARM_CLIENT_ID```
    - ```ARM_CLIENT_SECRET```
    - ```ARM_CLIENT_SECRET```
    - ```ARM_SUBSCRIPTION_ID```
    - ```ARM_TENANT_ID```
- For AWS:
    - For the Aurora PostgreSQL database, add ```TF_VAR_master_password```
    - For RabbitMQ:
        - ```TF_VAR_username```
        - ```TF_VAR_password```
- For MongoDB Atlas:
    - ```MONGODB_ATLAS_PUBLIC_KEY```
    - ```MONGODB_ATLAS_PRIVATE_KEY```
    - ```mongodb_org_id``` as a Terraform variable instead of an environmental variable
5. Initialize Terraform and apply:
    ```
    terraform init    # Initialize Terraform
    terraform plan    # Review the plan
    terraform apply   # Apply the configuration
    ```
6. Change the kubeconfig to point to the cluster by running:
    ```
    az aks get-credentials --resource-group frankengroup --name dev-frankencluster
    ```
Now you can access the cluster by running ```kubectl get nodes```.  

To destroy the resources, run: ```terraform destroy```.
## Monitoring
To enable monitoring with Prometheus and Grafana, follow the steps below. First, install Helm if it is not already on your system. I am using the ```Chocolatey``` package manager:
```
choco install Kubernetes-helm
```
### Setup
Start by deploying the applications as described above.
Then, follow the steps below:

1. Download the Helm repository containing the **kube-prometheus-stack**. This also comes with Grafana out-of-the-box:
    ```
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    ```
2. Update the repository:
    ```
    helm repo update
    ```
3. Install the chart into the cluster:
    ```
    helm install prometheus prometheus-community/kube-prometheus-stack
    ```
4. On Windows, edit the hosts file under ```C:\Windows\System32\drivers\etc``` and extend the host names to cover the sub-domains needed for Prometheus and Grafana:
    ```
    127.0.0.1 frankensound.test grafana.frankensound.test prometheus.frankensound.test
    ```
5. Now you can apply the service monitors and expose both Prometheus and Grafana by running the following commands from the ```kubernetes``` folder:
    ```
    kubectl apply -f .\monitoring\services\
    kubectl apply -f .\monitoring\ingress\
    ```
6. Finally, open a new terminal and run:
    ```
    minikube tunnel
    ```
7. Login into the Grafana dashboard with the default username ```admin``` and the ```prom-operator``` password.
8. Add Prometheus as the data source in the UI.  
Then, add the internal cluster URL where the Prometheus application is running: 
```http://prometheus-kube-prometheus-prometheus.default.svc.cluster.local:9090``` and click on ```Save & Test```. 

9. Import a dashboard from ```grafana.com``` and use the Prometheus data source we created, or create a dashboard from scratch. To create a dashboard from scratch, use these metrics:
    - CPU usage per service @ Kubernetes Service-level
        ```
        sum(rate(container_cpu_usage_seconds_total{namespace="default", pod=~"$application-.*"}[1h]))
        ```
    - RAM usage per service @ Kubernetes Service-level
        ```
        sum(rate(container_memory_usage_bytes{namespace="default", pod=~"$application-.*"}[1h]))
        ```
    - Availability (uptime)
        ```
        (
        sum(avg_over_time(kube_pod_status_ready{namespace="default", pod=~"$application-.*", condition="true"}[1m])) 
        / 
        sum(avg_over_time(kube_pod_status_ready{namespace="default", pod=~"$application-.*"}[1m]))
        ) * 100
        ```
    - Crash/restart events @ Kubernetes Service-level
        ```
        sum(kube_pod_container_status_restarts_total{namespace="default", pod=~"$application-.*"})
        ```
    - Application Response Time (latency [ms] lower is better) @ Application-level
        ```
        sum(rate(request_duration_milliseconds_sum{service="$application"}[1h]))
        /
        sum(rate(request_duration_milliseconds_count{service="$application"}[1h]))
        ```
    - Peak Response Time (latency [ms], jitter[ms] lower is better) @ Application-level
        ```
        histogram_quantile(0.99, sum(rate(request_duration_milliseconds_bucket{service="$application"}[5m])) by (le))
        ```

Now monitoring should be setup locally for the cluster.
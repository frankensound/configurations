# Configurations

This repository contains the necessary configurations for developing and deploying the microservices-based application Frankensound, as a whole, on a local environment.  
Follow the instructions below to setup your local environment.

## Setup development
1. Clone the repository
```
git clone git@github.com:frankensound/configurations.git
```
2. Create an  ``` .env ``` file in the root directory of the repository
3. Copy and modify the values in the provided ```.env.example``` file. Since we are using Docker Compose to run the containers, the host value will be ```host.docker.internal```.  
To supply the Auth0 values, create an account and create a domain for your application. Then, follow tutorials to setup a Machine to Machine application with Auth0 Management API privileges. Lastly, generate a token (which expires every 24h) for this and add it to the environment variables.
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
## Setup deployment
First, setup the secrets folder in the kubernetes directory. It should contain the following:
- A file called ```auth0.yaml```, with the content:
```
apiVersion: v1
kind: Secret
metadata:
  name: auth0
type: Opaque

data:
  DOMAIN:
  AUDIENCE:
  TOKEN:
```
- A file called ```historydb.yaml```, with the content:
```
apiVersion: v1
kind: Secret
metadata:
  name: historydb
type: Opaque

data:
  ORG:
  BUCKET:
  URL:
  TOKEN:
```
- A file called ```songsdb.yaml```, with the content:
```
apiVersion: v1
kind: Secret
metadata:
  name: songsdb
type: Opaque

data:
  URL:
  USERNAME:
  PASSWORD:
```
- A file called ```rabbitmq.yaml```, with the content:
```
apiVersion: v1
kind: Secret
metadata:
  name: rabbitmq
type: Opaque

data:
  HOST:
  PORT:
  USER:
  PASSWORD:
  QUEUE:
  URL:
```
Remember to encode the secrets to base64 before proceeding.
### Minikube
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
4. Navigate to the configurations folder, and run:
```
kubectl apply -f .\kubernetes\secrets\
kubectl apply -f .\kubernetes\
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
### Docker Desktop
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
6. Navigate to the configurations folder, and run:
```
kubectl apply -f .\kubernetes\secrets\
kubectl apply -f .\kubernetes\
```
Now the application should be accessible by navigating to ```http://frankensound.test```.  
Alternatively, you can leave out the host name configuration, and the application will be accessible at ```http://kubernetes.docker.internal```.

## Monitoring
To enable monitoring with Prometheus and Grafana, follow the steps below.  
First, install Helm if it is not already on your system. I am using the ```Chocolatey``` package manager.
```
choco install Kubernetes-helm
```
### Setup

1. Download the Helm repository containing the kube-prometheus stack. This also comes with Grafana out-of-the-box.
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
4. Now, it is time to expose the services to access them:
- For Grafana, execute the following commands:
  ```
  kubectl expose service prometheus-grafana --type=NodePort --target-port=3000 --name=grafana-ext
  minikube service grafana-ext
  ```
- For Prometheus, execute the following commands:
  ```
  kubectl expose service prometheus-kube-prometheus-prometheus --type=NodePort --target-port=9090 --name=prometheus-server-ext
  minikube service prometheus-server-ext
  ```
5. Login into the Grafana dashboard with the default username ```admin``` and the ```prom-operator``` password.  
Add Prometheus as the data source in the UI. Then, add the internal cluster URL where the Prometheus application is running. Then, click on ```Save & Test```. 

6. Import a dashboard from ```grafana.com``` and use the Prometheus data source we created.  
Now monitoring should be setup locally for the cluster.
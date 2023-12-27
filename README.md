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
minikube addons enable ingress
```
4. Navigate to the configurations folder, and run:
```
kubectl apply- f .\kubernetes\secrets\
kubectl apply- f .\kubernetes\
```
5. Finally, open a new terminal and run:
```
minikube tunnel
```
Now the application should be accessible by navigating to localhost.
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
5. Uncomment the ```host: frankensound.test``` property in the ```gateway.yaml``` deployment
6. On Windows, edit the hosts file under ```C:\Windows\System32\drivers\etc``` and add the following line at the end:
```
127.0.0.1 frankensound.test
```
7. Navigate to the configurations folder, and run:
```
kubectl apply- f .\kubernetes\secrets\
kubectl apply- f .\kubernetes\
```
Now the application should be accessible by navigating to frankensound.test.
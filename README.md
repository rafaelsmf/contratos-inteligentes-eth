# contratos-inteligentes-eth

## In Progress...

# Deploy Minikube Cluster

```/bin/sh
cd infrastructure/minikube
terraform init
terraform plan
terraform apply
```

# Open new terminal window and start Minikube Tunnel

```/bin/sh
minikube tunnel -p local-k8s
```

# Deploy K8s Resourcers

```/bin/sh
cd ../k8s/
terraform init
terraform plan
terraform apply
```

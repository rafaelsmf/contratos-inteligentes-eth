#!/bin/bash

# Start minikube with specified resources
if ! minikube start --memory 6144 --cpus=4 --nodes=2; then
  echo "Failed to start minikube"
  exit 1
fi

minikube addons enable metrics-server

sleep 15

helm install postgres ./applications/postgres/postgres-1.3.3.tgz
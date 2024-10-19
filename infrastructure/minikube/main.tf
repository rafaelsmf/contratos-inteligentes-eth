resource "null_resource" "minikube_cluster" {

  provisioner "local-exec" {
    command = "minikube start -p local-k8s --memory=8g --cpus=4"
  }

  provisioner "local-exec" {
    command = "minikube addons enable metrics-server -p local-k8s"
    when = create
  }

  provisioner "local-exec" {
    when    = destroy
    command = "minikube delete -p local-k8s"
  }
}
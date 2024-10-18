# Spark Namespace
resource "kubectl_manifest" "spark-namespace" {
  yaml_body = file("${path.module}/manifests/spark-namespace.yaml")
}

# Spark Service account and Cluster Role Binding
data "kubectl_path_documents" "spark-service-account" {
  pattern = "${path.module}/manifests/spark-service-account.yaml"
}

resource "kubectl_manifest" "spark-service-account" {
  depends_on = [
    kubectl_manifest.spark-namespace
  ]
  count     = length(data.kubectl_path_documents.spark-service-account.documents)
  yaml_body = element(data.kubectl_path_documents.spark-service-account.documents, count.index)
}


# Add Spark-Operator using Helm
resource "helm_release" "spark-operator" {
  name      = "spark-operator"
  chart     = "../../applications/spark-operator"
  namespace = "processing"
  values    = ["${file("../../applications/spark-operator/values.yaml")}"]
  wait      = false
}

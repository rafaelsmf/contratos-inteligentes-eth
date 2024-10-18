# Spark Namespace
resource "kubectl_manifest" "spark_operator_namespace" {
  yaml_body = file("./manifests/spark-operator-namespace.yaml")
}

# Spark ServiceAccount
resource "kubectl_manifest" "spark_operator_serviceaccount" {
  yaml_body = file("./manifests/spark-operator-serviceaccount.yaml")
}

# Spark ClusterRole
resource "kubectl_manifest" "spark_operator_clusterrole" {
  yaml_body = file("./manifests/spark-operator-clusterrole.yaml")
}

# Spark ClusterRoleBinding
resource "kubectl_manifest" "spark_operator_clusterrolebinding" {
  depends_on = [kubectl_manifest.spark_operator_clusterrole]
  yaml_body = file("./manifests/spark-operator-clusterrolebinding.yaml")
}

# GCP Secrets
resource "kubectl_manifest" "gcp_secrets" {
  yaml_body = file("./manifests/gcp-secrets.yaml")
}

# Add Spark-Operator using Helm
resource "helm_release" "spark" {
  depends_on = [kubectl_manifest.spark_operator_namespace, kubectl_manifest.spark_operator_serviceaccount, kubectl_manifest.spark_operator_clusterrolebinding, kubectl_manifest.gcp_secrets]
  name       = "spark"
  repository = "https://kubeflow.github.io/spark-operator"
  chart      = "spark-operator"
  namespace  = kubectl_manifest.spark_operator_namespace.name
  values = [file("../../applications/spark-operator/values.yaml")]
  wait       = false
}
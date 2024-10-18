# Spark Namespace
resource "kubectl_manifest" "spark_operator_namespace" {
  yaml_body = file("./manifests/spark-operator-namespace.yaml")
}

# Spark ServiceAccount
resource "kubectl_manifest" "spark_operator_serviceaccount" {
  yaml_body = file("./manifests/spark-operator-serviceaccount.yaml")
}

# Spark ClusterRoleBinding
resource "kubectl_manifest" "spark_operator_clusterrolebinding" {
  yaml_body = file("./manifests/spark-operator-clusterrolebinding.yaml")
}

# Add Spark-Operator using Helm
resource "helm_release" "spark" {
  depends_on = [kubectl_manifest.spark_operator_namespace, kubectl_manifest.spark_operator_serviceaccount, kubectl_manifest.spark_operator_clusterrolebinding]
  name       = "spark"
  repository = "https://kubeflow.github.io/spark-operator"
  chart      = "spark-operator"
  namespace  = kubectl_manifest.spark_operator_namespace.name
  wait       = false
}

# Add Jupyterhub using Helm
resource "helm_release" "jupyterhub" {
  depends_on = [kubectl_manifest.spark_operator_namespace]
  name       = "jupyterhub"
  repository = "https://jupyterhub.github.io/helm-chart"
  chart      = "jupyterhub"
  namespace  = kubectl_manifest.spark_operator_namespace.name
  wait       = false
}
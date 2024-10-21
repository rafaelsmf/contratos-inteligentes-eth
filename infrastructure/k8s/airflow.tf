# Airflow Namespace
resource "kubectl_manifest" "airflow_namespace" {
  yaml_body = file("./manifests/airflow-namespace.yaml")
}

# Airflow Secrets
resource "kubectl_manifest" "airflow_secrets" {
  yaml_body = file("./manifests/git-secrets.yaml")
}

# Add Airflow using Helm
resource "helm_release" "airflow" {
  depends_on = [kubectl_manifest.airflow_namespace, kubectl_manifest.airflow_secrets]
  name       = "airflow"
  chart      = "../../applications/airflow"
  namespace  = kubectl_manifest.airflow_namespace.name
  values    = ["${file("../../applications/airflow/values.yaml")}"]
  wait      = false
}
# Airflow Namespace
resource "kubectl_manifest" "airflow_namespace" {
  yaml_body = file("./manifests/airflow-namespace.yaml")
}

# Add Airflow using Helm
resource "helm_release" "airflow" {
  depends_on = [kubectl_manifest.airflow_namespace]
  name       = "airflow"
  repository = "https://airflow.apache.org"
  chart      = "airflow"
  namespace  = kubectl_manifest.airflow_namespace.name
  values = [file("../../applications/airflow/values.yaml")]
  wait       = false
}
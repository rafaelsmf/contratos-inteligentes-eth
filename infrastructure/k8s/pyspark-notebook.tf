# pyspark-notebook Namespace
resource "kubectl_manifest" "pyspark_notebook_namespace" {
  yaml_body = file("./manifests/pyspark-notebook-namespace.yaml")
}

# Add pyspark-notebook using Helm
resource "helm_release" "pyspark_notebook" {
  depends_on = [kubectl_manifest.pyspark_notebook_namespace]
  name       = "pyspark-notebook"
  repository = "https://a3data.github.io/pyspark-notebook-helm/"
  chart      = "pyspark-notebook"
  namespace  = kubectl_manifest.pyspark_notebook_namespace.name
  values = [file("../../applications/pyspark-notebook/values.yaml")]
  wait       = false
}
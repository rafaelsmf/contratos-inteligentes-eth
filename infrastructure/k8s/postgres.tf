# Postgres Namespace
resource "kubectl_manifest" "postgres_namespace" {
  yaml_body = file("./manifests/postgres-namespace.yaml")
}

# Add Postgres using Helm
resource "helm_release" "postgres" {
  depends_on = [kubectl_manifest.postgres_namespace]
  name       = "postgres"
  chart      = "../../applications/postgres/postgres-1.4.0.tgz"
  namespace  = kubectl_manifest.postgres_namespace.name
  values =     [file("../../applications/postgres/values.yaml")]
  wait       = false
}
from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.providers.cncf.kubernetes.operators.spark_kubernetes import SparkKubernetesOperator
from airflow.operators.dummy_operator import DummyOperator
from datetime import timedelta


# Default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': True,
    'start_date': days_ago(7),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

# Define the DAG
dag = DAG(
    'spark_bigquery_to_postgres',
    default_args=default_args,
    description='A DAG that runs a PySpark job to read BigQuery data and save it to PostgreSQL',
    schedule_interval=timedelta(days=1),
)

# Task to trigger the Spark job using the Kubernetes operator
spark_job = SparkKubernetesOperator(
    task_id='spark_submit',
    namespace='processing',  # Ensure the namespace matches where Spark operator is running
    application_file="./manifests/tokens-ingestion-incremental.yaml",  # This YAML file is your Spark job definition
    kubernetes_conn_id='k8s_cluster',  # Airflow connection to the Kubernetes cluster
    dag=dag,
)

# Dummy task to signal the end of the workflow
end = DummyOperator(task_id='end', dag=dag)

# Define task dependencies
spark_job >> end

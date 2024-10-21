from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.providers.cncf.kubernetes.operators.spark_kubernetes import SparkKubernetesOperator
from airflow.providers.cncf.kubernetes.sensors.spark_kubernetes import SparkKubernetesSensor
from airflow.operators.dummy_operator import DummyOperator
from datetime import timedelta


SPARK_NAMESPACE = "processing"

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
    description='A DAG that runs a PySpark job to read BigQuery data and save it to PostgreSQL (D-1)',
    schedule_interval=timedelta(days=1),
)

# Dummy task to signal the start of the workflow
start = DummyOperator(task_id='start', dag=dag)

# Task to trigger the Spark job using the Kubernetes operator
task_id = "bigquery_to_postgres"
spark_job = SparkKubernetesOperator(
    task_id=task_id,
    namespace=SPARK_NAMESPACE,  
    application_file="./manifests/tokens-ingestion-incremental.yaml",  
    kubernetes_conn_id='local_k8s',
    dag=dag,
)

# monitor spark application
spark_job_sensor = SparkKubernetesSensor(
    task_id=f'{task_id}_sensor',
    namespace=SPARK_NAMESPACE,
    application_name=f"{{{{ task_instance.xcom_pull(task_ids='{task_id}')['metadata']['name'] }}}}",
    kubernetes_conn_id="local_k8s",
    attach_log=True,
    dag=dag
)

# Dummy task to signal the end of the workflow
end = DummyOperator(task_id='end', dag=dag)

# Define task dependencies
start >> spark_job
spark_job >> spark_job_sensor
spark_job_sensor >> end

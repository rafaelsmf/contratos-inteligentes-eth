from pyspark.sql import SparkSession
import pyspark.sql.functions as F
import sys
from datetime import datetime


def create_spark_session():
    """
    Configura a sessão Spark com os pacotes necessários.
    """
    spark = (
        SparkSession.builder
        .appName('BigQuery Crypto Ethereum')
        .config('spark.jars.packages', 'com.google.cloud.spark:spark-bigquery-with-dependencies_2.12:0.41.0,org.postgresql:postgresql:42.2.23')
        .config("spark.sql.execution.arrow.enabled", "true")
        .getOrCreate()
    )

    return spark


def read_bigquery_data(spark, project_id, table):
    """
    Lê os dados do BigQuery.
    
    :param spark: Sessão Spark
    :param project_id: ID do projeto no BigQuery
    :param table: Nome da tabela no BigQuery
    :return: DataFrame com os dados do BigQuery
    """
    return (
        spark.read
        .format("bigquery")
        .option("project", project_id)
        .option("table", table)
        .load()
    )


def filter_data_by_date(df, start_date, end_date):
    """
    Filtra os dados com base na data do dia anterior.
    
    :param df: DataFrame original
    :param start_date: Data de início do filtro
    :param end_date: Data de fim do filtro
    :return: DataFrame filtrado
    """
    return df.filter(
        (F.col('block_timestamp') >= start_date) & (F.col('block_timestamp') <= end_date)
    )


def write_to_postgres(df, postgres_url, table_name, properties):
    """
    Escreve os dados filtrados no banco PostgreSQL.
    
    :param df: DataFrame filtrado
    :param postgres_url: URL de conexão ao PostgreSQL
    :param table_name: Nome da tabela no PostgreSQL
    :param properties: Propriedades de conexão
    """
    df.write.jdbc(url=postgres_url, table=table_name, mode="append", properties=properties)


def main(execution_date):
    """
    Função principal que orquestra o processo de leitura, processamento e escrita dos dados.
    
    :param execution_date: Data de execução da DAG (D-1)
    """
    # Criar a sessão Spark
    spark = create_spark_session()

    # Convertendo a data de execução para datetime
    execution_date_dt = datetime.strptime(execution_date, "%Y-%m-%d")
    
    # Definir o intervalo do dia anterior
    start_date = execution_date_dt.strftime('%Y-%m-%d 00:00:00')
    end_date = execution_date_dt.strftime('%Y-%m-%d 23:59:59')

    # Leitura dos dados do BigQuery
    project_id = "desafio-stone-439013"
    bigquery_table = "bigquery-public-data.crypto_ethereum.tokens"
    df = read_bigquery_data(spark, project_id, bigquery_table)

    # Filtrar os dados do dia anterior
    df_filtered = filter_data_by_date(df, start_date, end_date)

    # Conexão com PostgreSQL
    postgres_url = "jdbc:postgresql://10.106.35.153:5432/crypto_ethereum"
    postgres_properties = {
        "user": "admin",
        "password": "admin",
        "driver": "org.postgresql.Driver"
    }

    # Escrever os dados no PostgreSQL
    write_to_postgres(df_filtered, postgres_url, "public.crypto_tokens", postgres_properties)

    # Encerrar a sessão Spark
    spark.stop()


if __name__ == "__main__":
    # Leitura do argumento de execução
    execution_date = sys.argv[1]
    
    # Executar o fluxo principal
    main(execution_date)


## Visão Geral

Este projeto tem como objetivo construir uma solução de processamento de dados no Kubernetes utilizando Minikube como cluster local. A pipeline coleta dados de uma tabela pública do BigQuery e os grava em um banco de dados PostgreSQL, utilizando Spark para processamento e Airflow para orquestração das tarefas.

## Ferramentas Utilizadas

- **Docker**: Para gerenciar contêineres e imagens.
- **Helm**: Para gerenciar pacotes do Kubernetes.
- **Terraform**: Para automação da infraestrutura como código (IaC).
- **Minikube**: Para criar um cluster Kubernetes local.
- **VS Code/OpenLens/DBeaver**: Ferramentas de desenvolvimento com extensões para facilitar o gerenciamento de Kubernetes e edição de código.
- **Airflow**: Para orquestrar o pipeline de dados.
- **Spark**: Para processar dados com alta performance.
- **PostgreSQL**: Banco de dados para persistir os dados processados.

## Passo a Passo para Configuração e Deploy

### 1. Instalação de Pré-requisitos

Instalar as seguintes ferramentas na máquina local:
- Docker
- Helm
- Terraform

### 2. Clonar o Repositório

Clone o repositório do projeto:
```bash
git clone -v --no-checkout -b develop https://github.com/rafaelsmf/contratos-inteligentes-eth.git
```

### 3. Deploy do Cluster Minikube
Navegue até a pasta infrastructure/minikube e inicialize o Terraform para criar o cluster Minikube:

```bash
Copiar código
cd infrastructure/minikube
terraform init
terraform plan
terraform apply
```

### 4. Iniciar o Tunnel do Minikube
Abra uma nova janela de terminal e execute o comando para iniciar o Minikube Tunnel:

```bash
Copiar código
minikube tunnel -p local-k8s
```

### 5. Deploy dos Recursos Kubernetes
Depois de configurar o Minikube, navegue para a pasta k8s/ e faça o deploy dos recursos do Kubernetes com Terraform:

```bash
Copiar código
cd ../k8s/
terraform init
terraform plan
terraform apply
```
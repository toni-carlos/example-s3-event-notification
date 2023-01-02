# s3-event-notification

O s3-event-notification é uma demonstração de como capturar eventos do bucket S3 e deixá-los acessíveis
através de uma fila no AWS SQS para que aplicação consuma esses eventos e atenda uma  necessidade de negócio. 
Está sendo usado o Terraform para provisionar os recursos necessários para esse exemplo na conta AWS.

## Arquitetura

![alt arquitetura](images/arquitetura-event-notification.png)

### Descrição da arquitetura

1. Os eventos(PutObject, GetObject, DeleteObject e etc) realizado no bucket AWS S3 são monitorados
pelo Event Notification.

2. Event Notification envia os eventos para o tópico AWS SNS. Outros destinos podem
ser configurado como AWS Lambda, AWS SQS. Para mais detalhes veja: [Using Amazon SQS, Amazon SNS, and Lambda](https://docs.aws.amazon.com/AmazonS3/latest/userguide/how-to-enable-disable-notification-intro.html)

3. Os eventos tópico são enviados para o fila do AWS SQS. O objetivo de assinar uma fila SQS
no tópico SNS foi para visualizar no próprio console o formado no eventos enviado para o tópico do SNS

## Pré Requisitos
- [Conta AWS](https://comunidadecloud.com/como-criar-uma-conta-na-aws/).
- [Instalação e configuração do AWS CLI](https://www.treinaweb.com.br/blog/como-instalar-e-configurar-o-aws-cli)
- [Instalação e configuração do Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## Instruções para provisionar a infra e as configurações


```
# Comando para inicializar o terraform na máquina local
$ terraform init

# Comando para ver o plano que execução do recurso que será provisionado na AWS 
$ terraform plan

# Comando criar os recursos na conta AWS
$ terraform apply

```

Ao executar os comandos acima, serão criados os recursos que foram definidos no arquivo main.tf

## Destrua os recursos criados nesse exemplo para não gerar custos na conta AWS

```
$ terraform destroy
```



    











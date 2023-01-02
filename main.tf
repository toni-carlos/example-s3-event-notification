terraform {
  required_version = "1.2.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
  }
}


provider "aws"{
  region     = "sa-east-1"
}

# criação de fila padrão SQS
resource "aws_sqs_queue" "orders_to_notify" {
  name                       = "orders-to-notify-queue"
  receive_wait_time_seconds  = 20
  message_retention_seconds  = 18400
}

# criação de topico SNS
resource "aws_sns_topic" "topic" {
  name = "s3-event-notification-topic"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": { "Service": "s3.amazonaws.com" },
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:*:*:s3-event-notification-topic",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${aws_s3_bucket.my-test-bucket.arn}"}
        }
    }]
}
POLICY
}

#  Assina o fila SQS em um tópico SNS
resource "aws_sns_topic_subscription" "orders_to_notify_subscription" {
  protocol             = "sqs"
  raw_message_delivery = true
  topic_arn            = aws_sns_topic.topic.arn
  endpoint             = aws_sqs_queue.orders_to_notify.arn
}

# Cria bucket S3
resource "aws_s3_bucket" "my-test-bucket" {
  bucket = "my-bucket-test-notification-15422122322334"
  acl    = "private"

  tags = {
    Name        = "my bucket"
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Owner       = " "
  }

}

# Configura o Event contification no bucket S3. Para mais informações acesse o link: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.my-test-bucket.id

  topic {
    topic_arn     = aws_sns_topic.topic.arn
    events        = ["s3:ObjectCreated:*"]
  }
}

# Cria policy usada na fila SQS
resource "aws_sqs_queue_policy" "orders_to_notify_subscription" {
  queue_url = aws_sqs_queue.orders_to_notify.id
  policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": [
        "sqs:SendMessage"
      ],
      "Resource": [
        "${aws_sqs_queue.orders_to_notify.arn}"
      ],
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.topic.arn}"
        }
      }
    }
  ]
}
EOF
}
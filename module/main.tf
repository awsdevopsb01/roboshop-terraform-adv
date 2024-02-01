
resource "aws_instance" "instance" {
  ami = data.aws_ami.centos.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.selected.id]

  tags = {
    Name  = var.component_name
  }
}

resource "aws_route53_record" "dnsrecord" {
  zone_id = "Z01307132WU1DJMGVKGO6"
  name    = "${var.component_name}-dev.nldevopsb01.online"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.private_ip]
}

resource "null_resource" "provisioner" {
  depends_on = [aws_instance.instance, aws_route53_record.dnsrecord]
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "centos"
      password = "DevOps321"
      host     = aws_instance.instance.private_ip
    }

    inline = var.app_type == "db" ? local.db_commands : local.app_commands
  }
}

resource "aws_iam_role" "iam_role" {
  name = "${var.component_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.component_name}-role"
  }
}

resource "aws_iam_policy" "iam-policy" {
  name        = "${var.component_name}-ssm-policy"
  path        = "/"
  description = "Iam Policy for microservices"

  policy = jsonencode({
    Version = "2012-10-17"
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "ssm:DescribeParameters",
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource": "*"
      }
    ]
  })
  tags = {
    tag-key = "${var.component_name}-ssm-policy"
  }
}
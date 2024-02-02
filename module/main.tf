
resource "aws_instance" "instance" {
  ami = data.aws_ami.centos.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  iam_instance_profile = aws_iam_instance_profile.iam_ssm_instance_profile.name

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

resource "aws_iam_role_policy" "iam_ssm_role_policy" {
  name = "${var.component_name}-role-policy"
  role = aws_iam_role.iam_role.id

 policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "kms:Decrypt",
          "ssm:GetParameterHistory",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Resource": [
          "arn:aws:kms:us-east-1:280878923025:key/1598ad31-8c90-467c-8523-f3a951215606",
          "arn:aws:ssm:us-east-1:280878923025:parameter/dev.${var.component_name}.*"
        ]
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": "ssm:DescribeParameters",
        "Resource": "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "iam_ssm_instance_profile" {
  name = "${var.component_name}-instance-profile"
  role = aws_iam_role.iam_role.name
}
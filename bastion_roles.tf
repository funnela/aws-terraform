resource "aws_iam_role" "bastion_ec2_role" {
  name = "funnela_${var.account}_bastion_ec2_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
              "Service": "ec2.amazonaws.com"
          }
      }
  ]
}
EOF
}


data "template_file" "bastion_parameter_store_policy_template" {
  template = <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeParameters",
        "ssm:GetParameters",
        "ssm:GetParameter",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": [
        "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/*",
        "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:*",
        "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
      ]
    }
  ]
}
EOT
}

resource "aws_iam_policy" "bastion_parameter_store" {
  name = "funnela_${var.account}_bastion_parameter_store"
  path = "/"

  policy = data.template_file.bastion_parameter_store_policy_template.rendered
}

resource "aws_iam_role_policy_attachment" "bastion_parameter_store" {
  role      = aws_iam_role.bastion_ec2_role.name
  policy_arn = aws_iam_policy.bastion_parameter_store.arn
}


data "template_file" "bastion_ecs_policy_template" {
  template = <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:DescribeTask",
        "ecs:DescribeTasks",
        "ecs:ExecuteCommand",
        "ecs:ListTasks"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOT
}

resource "aws_iam_policy" "bastion_ecs" {
  name = "funnela_${var.account}_bastion_ecs"
  path = "/"

  policy = data.template_file.bastion_ecs_policy_template.rendered
}

resource "aws_iam_role_policy_attachment" "bastion_ecs" {
  role      = aws_iam_role.bastion_ec2_role.name
  policy_arn = aws_iam_policy.bastion_ecs.arn
}

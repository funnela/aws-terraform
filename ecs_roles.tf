resource "aws_iam_role" "task_execution_role" {
  name = "funnela_${var.account}_ecs_task_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "template_file" "parameter_store_policy_template" {
  template = <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeParameters",
        "ssm:GetParameters",
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

resource "aws_iam_policy" "parameter_store" {
  name = "funnela_${var.account}_parameter_store"
  path = "/"

  policy = data.template_file.parameter_store_policy_template.rendered
}

resource "aws_iam_role_policy_attachment" "parameter_store" {
  role      = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.parameter_store.arn
}



data "template_file" "cloud_watch_policy" {
  template = <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOT
}

resource "aws_iam_policy" "cloud_watch" {
  name = "funnela_${var.account}_cloud_watch"
  path = "/"

  policy = data.template_file.cloud_watch_policy.rendered
}

resource "aws_iam_role_policy_attachment" "cloud_watch" {
  role      = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.cloud_watch.arn
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role      = aws_iam_role.task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}


resource "aws_iam_role" "task_role" {
  name = "funnela_${var.account}_ecs_task_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "template_file" "task_ses_policy_template" {
  template = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ses:*"
            ],
            "Resource": "*"
        }
    ]
}
EOT
}


data "template_file" "ecs_exec_policy_template" {
  template = <<-EOT
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource": "*"
      }
    ]
}
EOT
}

resource "aws_iam_policy" "ecs_exec_policy" {
  name = "funnela_${var.account}_ecs_exec"
  path = "/"

  policy = data.template_file.ecs_exec_policy_template.rendered
}

resource "aws_iam_role_policy_attachment" "task_ecs_exec" {
  role      = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}

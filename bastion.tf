data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

data "template_file" "bastion_user_data" {
  template = file("${path.module}/bastion_user_data.sh")
  vars = {
    authorized_keys = var.bastion_authorized_keys
    aws_region = data.aws_region.current.name
    ssm_parameter_postgres_password = aws_ssm_parameter.db_password.name
    db_host = aws_db_instance.database.address
    db_user = aws_db_instance.database.username
    ecs_cluster = aws_ecs_cluster.ecs_cluster.name
    ecs_service = aws_ecs_service.funnela-web.name
  }
}


resource "aws_iam_instance_profile" "bastion_profile" {
  name = "funnela-bastion-sync-${var.account}_profile"
  role = aws_iam_role.bastion_ec2_role.name
}


resource "aws_instance" "bastion" {
  count = var.bastion_enable ? 1 : 0

  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t4g.small"
  subnet_id = data.aws_subnet.first_az_public_subnet.id
  associate_public_ip_address = true
  user_data = data.template_file.bastion_user_data.rendered
  user_data_replace_on_change = true
  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  root_block_device {
    volume_size = 50
  }

  vpc_security_group_ids = [
    aws_security_group.bastion.id,
    aws_security_group.default.id,
  ]

  lifecycle {
    ignore_changes = [
      ami,  # we do not want to recreate host every time new image shows up
    ]
  }
}

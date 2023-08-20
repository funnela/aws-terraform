#! /bin/bash

cat - > /home/ec2-user/.ssh/authorized_keys <<< "${authorized_keys}"

sudo amazon-linux-extras install -y postgresql13 redis6
sudo yum install -y mc nc

pip3 install awscli
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_arm64/session-manager-plugin.rpm" -o "/tmp/session-manager-plugin.rpm"
sudo yum install -y /tmp/session-manager-plugin.rpm
rm /tmp/session-manager-plugin.rpm

echo "export PGPASSWORD=\`aws ssm --region=${aws_region} get-parameter --name ${ssm_parameter_postgres_password} --with-decryption --output text --query Parameter.Value\`" >> /home/ec2-user/.bashrc
echo "export PGHOST=${db_host}"  >> /home/ec2-user/.bashrc

echo "ecs-get-task-id(){ /usr/local/bin/aws ecs list-tasks --region ${aws_region} --cluster \$1 --service \$2 --output text --query taskArns\[0\]; }" >> /home/ec2-user/.bashrc
echo "ecs-connect(){ cluster=\$${1:-${ecs_cluster}}; service=\$${2:-${ecs_service}}; /usr/local/bin/aws ecs execute-command --region ${aws_region} --cluster \$cluster --task \$(ecs-get-task-id \$cluster \$service) --container migrate --interactive --command '/app/entrypoint.sh /bin/bash'; }" >> /home/ec2-user/.bashrc

echo "alias db-connect=\"/usr/bin/psql --user=${db_user} --host=${db_host}\"" >> /home/ec2-user/.bashrc

echo '# exit and don`t show welcome message for non-interactive sessions like scp:' >> /home/ec2-user/.bashrc

echo 'if [ -z "$PS1" ]; then return; fi' >> /home/ec2-user/.bashrc
echo '' >> /home/ec2-user/.bashrc

echo 'echo' >> /home/ec2-user/.bashrc
echo 'echo "Use the following commands to connect to various resources:"' >> /home/ec2-user/.bashrc
echo 'echo "  db-connect - connect to RDS database psql shell"' >> /home/ec2-user/.bashrc
echo 'echo "  ecs-connect - connect to migrations container shell in ECS cluster"' >> /home/ec2-user/.bashrc
echo 'echo' >> /home/ec2-user/.bashrc

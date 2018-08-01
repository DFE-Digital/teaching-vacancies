#!/bin/bash

mkdir -p /etc/ecs
echo 'ECS_CLUSTER=${ecs_cluster_name}' >> /etc/ecs/ecs.config
echo '${ecs_ssh_keys}' >> /home/ec2-user/.ssh/authorized_keys

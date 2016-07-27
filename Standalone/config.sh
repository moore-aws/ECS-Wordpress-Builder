#!/bin/bash
#Author: Scott Moore

#Variables pre-filled below can be used or changed depending on needs. 

#Input AWS Account ID and the Region you would like to deploy your containers to. Oregon[us-west-2], N.VA[us-west-1]
AWSAccountID=
AWSRegion=us-west-2


ecr_repo1=demo/wordpress
ecr_repo2=demo/mysql

dockerhubimg1=wordpress
dockerhubimg2=mysql

ecs_cluster=demo_wordpress
task_def=demo-task
taskdef_count=:1

ecs_taskdef_path=file://task.json

EC2IAMRoleARN=arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role
EC2IAMRole=ecs-instance-role

RolePolicyDocPath=file://ecs-instance-role.json
ec2_ami=ami-241bd844

instance_type=t2.medium
#Either use an existing keypair or create a new one. Input the name of the keypair below.
keypair=
#Either use an existing security group or create a new one. Input the security group ID below. Ensure security group has at least Port 80 [HTTP] open 
security_group=
#Input a public subnet (should have internet gateway attached) and put the subnet-id below.
subnet_id=subnet-6b69bd33
user_data_path=file://userdata.txt

#Set CloudWatch Logs Groups name below - make sure to update TaskDef file as well!
CWL_Group_Name1=awslogs-wordpress
CWL_Group_Name2=awslogs-mysql
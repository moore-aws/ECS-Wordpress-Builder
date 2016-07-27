#!/bin/bash
#Author: Scott Moore

#Variables pre-filled below can be used or changed depending on needs. 

#Input AWS Account ID and the Region you would like to deploy your containers to. Oregon[us-west-2], N.VA[us-west-1]
AWSAccountID=524049045104
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
keypair=smoore-dev
#Either use an existing security group or create a new one. Input the security group ID below. Ensure security group has at least Port 80 [HTTP] open 
security_group=sg-32772254
#Input a public subnet (should have internet gateway attached) and put the subnet-id below.
subnet_id=subnet-6b69bd33
user_data_path=file://userdata.txt

#Set CloudWatch Logs Groups name below - make sure to update TaskDef file as well!
CWL_Group_Name1=awslogs-wordpress
CWL_Group_Name2=awslogs-mysql

echo "Logging into AWS ECR"
aws ecr get-login > ecr_creds.sh
bash ecr_creds.sh
rm ecr_creds.sh

echo "Creating ECR Repository for Wordpress"
rm aws ecr create-repository --repository-name $ecr_repo1
echo "Creating ECR Repository for MySQL"
rm aws ecr create-repository --repository-name $ecr_repo2

echo "Pulling Wordpress from DockerHub"
rm docker pull $dockerhubimg1

echo "Pulling MySQL from DockerHub"
rm docker pull $dockerhubimg2

echo "Tagging Wordpress & MySQL images with AWS ECR repo"
rm docker tag $dockerhubimg1 $AWSAccountID.dkr.ecr.$AWSRegion.amazonaws.com/$ecr_repo1
rm docker tag $dockerhubimg2 $AWSAccountID.dkr.ecr.$AWSRegion.amazonaws.com/$ecr_repo2

echo "Pushing Wordpress image to AWS ECR Wordpress repo"
rm docker push $AWSAccountID.dkr.ecr.$AWSRegion.amazonaws.com/$ecr_repo1

echo "Pushing MySQL image to AWS ECR MySQL repo"
rm docker push $AWSAccountID.dkr.ecr.$AWSRegion.amazonaws.com/$ecr_repo2

echo "Creating a Cluster in AWS ECS"
rm aws ecs create-cluster --cluster-name $ecs_cluster

echo "Registering Task Definition in AWS ECS"
rm aws ecs register-task-definition --cli-input-json $ecs_taskdef_path

echo "Creating IAM Role"
rm aws iam create-role --role-name $EC2IAMRole --assume-role-policy-document $RolePolicyDocPath

echo "Creating Instance Profile"
rm aws iam create-instance-profile --instance-profile-name $EC2IAMRole

echo "Adding Role to Instance Profile"
rm aws iam add-role-to-instance-profile --role-name $EC2IAMRole --instance-profile-name $EC2IAMRole

echo "Attaching Managed Policy to IAM Role"
rm aws iam attach-role-policy --policy-arn $EC2IAMRoleARN --role-name $EC2IAMRole


echo "Creating CloudWatch Logs Group"
rm aws logs create-log-group --log-group-name $CWL_Group_Name1 --region us-west-2
rm aws logs create-log-group --log-group-name $CWL_Group_Name2 --region us-west-2


echo "Deploying ECS Optimized Image with IAM role"
rm aws ec2 run-instances --iam-instance-profile Name=$EC2IAMRole --image-id $ec2_ami --count 1 --instance-type $instance_type --key-name $keypair --security-group-ids $security_group --block-device-mapping "[ { \"DeviceName\": \"/dev/xvda\", \"Ebs\": { \"VolumeSize\":40 } } ]" --subnet-id $subnet_id --user-data $user_data_path

echo "Waiting for EC2 instance to join cluster..."


echo "Running Task on Cluster"
rm aws ecs run-task --cluster $ecs_cluster --task-definition $task_def$taskdef_count --count 1

echo "Wordpress is being deployed...Give the Running Task at least 30 seconds to update and check Container Instance"
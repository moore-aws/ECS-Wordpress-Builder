#!/bin/bash
source config.sh

echo "Logging into AWS ECR"
aws ecr get-login > ecr_creds.sh
bash ecr_creds.sh
rm ecr_creds.sh

echo "Creating ECR Repository for Wordpress"
aws ecr create-repository --repository-name $ecr_repo1
echo "Creating ECR Repository for MySQL"
aws ecr create-repository --repository-name $ecr_repo2

echo "Pulling Wordpress from DockerHub"
docker pull $dockerhubimg1

echo "Pulling MySQL from DockerHub"
docker pull $dockerhubimg2

echo "Tagging Wordpress & MySQL images with AWS ECR repo"
docker tag $dockerhubimg1 $AWSAccountID.dkr.ecr.$AWSRegion.amazonaws.com/$ecr_repo1
docker tag $dockerhubimg2 $AWSAccountID.dkr.ecr.$AWSRegion.amazonaws.com/$ecr_repo2

echo "Pushing Wordpress image to AWS ECR Wordpress repo"
docker push $AWSAccountID.dkr.ecr.$AWSRegion.amazonaws.com/$ecr_repo1

echo "Pushing MySQL image to AWS ECR MySQL repo"
docker push $AWSAccountID.dkr.ecr.$AWSRegion.amazonaws.com/$ecr_repo2

echo "Creating a Cluster in AWS ECS"
aws ecs create-cluster --cluster-name $ecs_cluster

echo "Registering Task Definition in AWS ECS"
aws ecs register-task-definition --cli-input-json $ecs_taskdef_path

echo "Creating IAM Role"
aws iam create-role --role-name $EC2IAMRole --assume-role-policy-document $RolePolicyDocPath

echo "Creating Instance Profile"
aws iam create-instance-profile --instance-profile-name $EC2IAMRole

echo "Adding Role to Instance Profile"
aws iam add-role-to-instance-profile --role-name $EC2IAMRole --instance-profile-name $EC2IAMRole

echo "Attaching Managed Policy to IAM Role"
aws iam attach-role-policy --policy-arn $EC2IAMRoleARN --role-name $EC2IAMRole
sleep 10

echo "Creating CloudWatch Logs Group"
aws logs create-log-group --log-group-name $CWL_Group_Name1 --region us-west-2
aws logs create-log-group --log-group-name $CWL_Group_Name2 --region us-west-2
sleep 5

echo "Deploying ECS Optimized Image with IAM role"
aws ec2 run-instances --iam-instance-profile Name=$EC2IAMRole --image-id $ec2_ami --count 1 --instance-type $instance_type --key-name $keypair --security-group-ids $security_group --block-device-mapping "[ { \"DeviceName\": \"/dev/xvda\", \"Ebs\": { \"VolumeSize\":40 } } ]" --subnet-id $subnet_id --user-data $user_data_path

echo "Waiting for EC2 instance to join cluster..."
sleep 140

echo "Running Task on Cluster"
aws ecs run-task --cluster $ecs_cluster --task-definition $task_def$taskdef_count --count 1

echo "Wordpress is being deployed...Give the Running Task at least 30 seconds to update and check Container Instance"
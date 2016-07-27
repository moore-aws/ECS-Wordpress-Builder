ECS Builder Demo

Script Prerequisites:
*AWS CLI
*Docker Toolbox
*Create a security group for this script (SSH-your IP, HTTP-ALL), write down security group-id.
*Use existing or create a new keypair
*Note a publicly available subnet in an AWS VPC, write down subnet-id.  

Instructions:
*Unzip file and move Demo folder to somewhere easy to find.
*Ensure the following files are in your Demo folder:
-build.sh
-ecs-instance-role.json
-task.json
-userdata.txt
*Open build.sh in a code/text editor.
*Fill in variables with your information.
*Open ‘task.json’ and change ‘xxxxxxxxxxxx’ to the right of images to your AWS Account ID. Do this for the bottom container as well. 

*Open terminal (Docker QuickStart)
-cd [to your Demo folder path]
-run ‘sh build.sh’ 


Description of script: Build.sh will authenticate to ECR using Docker client. Then the script will create an ECR repository in both Wordpress and MySQL, Pull down the Wordpress and MySQL docker images from Docker hub and tag them with the ECR repository values. After tagging the local images, the script will then Push the Wordpress and MySQL images from your computer to the ECR repositories it previously created for both images. Once done, it will create an ECS cluster, call the “task.json” file and register the Task Definitions with ECS.

Once the Task Definitions have been registered, the script will then create an IAM role based on the managed policy: AmazonEC2ContainerServiceforEC2Role. The script calls file “ecs-instance-role.json” to create the IAM Role and associate the above managed policy to it, then adds the Role to an Instance Profile. The script then goes on to deploy an EC2 instance using the ECS Optimized Linux Amazon Machine Image, with the newly created IAM Role, and specified key pair, security group, subnet and then bootstrap the instance with User Data called from file “userdata.txt”. 

This User Data script will register the EC2 instance with the named cluster ‘demo-wordpress’ as specified in the file. Once the EC2 instance clears status checks, the ECS agent on the newly created EC2 instance will use this script to connect to the ECS Cluster and a Wait condition will run for 2 minutes and 20 seconds to ensure the connection is established. If successful, the Cluster will be ready to deploy the Task definition. In the final step, the script will take the previously registered Task Definition and run it on the cluster. The Task will switch to a “Pending” status while deploying a container for Wordpress and a container for MySQL. Once done, the Task status should change to “Running”…Click on the ECS Instances tab and then click on the Container Instance. You should see an output for the Public IP address. Input that into your browser, and the Wordpress install wizard should display. 

 
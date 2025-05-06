
[![Petclinic-Ci](https://github.com/tanya-domi/k8s-microservices-Gitops-ArgoCD/actions/workflows/CI.yaml/badge.svg)](https://github.com/tanya-domi/k8s-microservices-Gitops-ArgoCD/actions/workflows/CI.yaml)

Note, This Project is a fork of the Spring Boot PetClinic, a widely recognized reference application designed to demonstrate the architecture and best practices of Spring Boot.

We extend our appreciation to the original maintainers and contributors for open-sourcing this excellent demo. PetClinic is often cited as one of the most effective examples for understanding real-world use of Spring Boot, layered architecture, testing strategies, and integration patterns.

This Project may include enhancements, environment-specific configurations, or CI/CD integrations to suit custom deployment or educational needs.


![Image](https://github.com/user-attachments/assets/0d58e42a-843d-4b26-9342-0b5b736a9700)


# Project Introduction:

Welcome to the End-to-End DevOps Kubernetes Project guide! This guide offers practical experience in deploying a secure, scalable microservices architecture on AWS with Kubernetes, incorporating DevOps best practices, security, and monitoring.

# Project Overview:

In this project, we will cover the following key aspects:

Step 1. IAM User Setup: 
Create an IAM user on AWS with the necessary permissions to facilitate deployment and management activities.

Step 2. Infrastructure as Code (IaC): 
Uses GitHub Actions to automate the deployment of a Jumphost (bastion) server on AWS EC2. The CI pipeline provisions the instance using Infrastructure as Code (Terraform).

Step 3. Github Actions Configuration: 
configure essential github actions workflow, including  Docker, Sonarqube, Terraform, Kubectl, and Trivy.

Step 4. EKS Cluster Deployment: 
Utilize eksctl commands to create a customize Amazon EKS cluster, a managed Kubernetes service on AWS.

Step 5. Load Balancer Controller Configuration: 
Configure AWS Application Load Balancer (ALB) for the EKS cluster.
    
Step 6. Create Iamserviceaccount : 
Create an IAM role for the AWS Load Balancer Controller and attach the role to the Kubernetes service account.

Step 7. Create RDS Mysql Database: 
Create security group to allow access for RDS Database on port 3306 and create DB Subnet Group in RDS.

Step 8. Dockerhub Repositories: 
Automatically create repository for Docker images on Dockerhub.

Step 9. ArgoCD Installation: 
Install and set up ArgoCD for continuous delivery and following GitOps approach.

Step 10. Sonarqube Integration: 
Integrate Sonarqube for code quality analysis in the CI pipeline.

Step 11 .Trivy Integration: 
Trivy for container image and filesystem vulnerability scanning in the CI pipeline.

Step 12. Set up SSL: Create  SSL certificate in Certificate Manager

Step 13. Monitoring Setup: 
Implement monitoring for the EKS cluster using Helm, Prometheus,  Grafana and  ELK.

Step 14. ArgoCD Application Deployment: 
Leverage ArgoCD to implement a GitOps workflow, ensuring that application and infrastructure deployments are automated, auditable, and version-controlled.

Step 15. DNS Configuration: 
Configure DNS settings to make the application accessible via custom subdomains.Creating an A-Record in AWS Route 53 Using ALB DNS.

Step 16. Data Persistence: 
Test the application's ability to maintain data persistence to ensure that application state and user data are reliably stored and retained across deployments and pod restarts.

Conclusion and Monitoring: 
Conclude the project by creating custom dashboards in Grafana and Kibana to visualize key application metrics, system performance, and logs for monitoring and troubleshooting and summarize key achievements.


# Prerequisites:
- An AWS account with the necessary permissions to provision resources.
  
- Install Terraform & AWS CLI Install & Configure Terraform and AWS CLI on your local machine.
  
- Familiarity with Kubernetes, Docker, CICD pipelines, Github Actions, Terraform, and DevOps principles.
  
- Deploy the Jumphost Server(EC2) using Terraform on Github Actions CI.
  
- Verify the Jumphost configuration, we have installed some services such as Docker, Terraform, Kubectl, eksctl, AWS CLI and Trivy to validate whether all our tools are installed or not using these commands.
   
==> docker --version 

==> docker ps 

==> terraform --version 

==> kubectl version 

==> aws --version 

==> trivy --version 


# Pre-requisite-2: Create EKS Cluster and Worker Nodes
eksctl create cluster --name=petclinic-eks-cluster \
                      --region=us-east-1 \
                      --zones=eu-north-1a,eu-north-1b \
                      --version="1.29" \
                      --without-nodegroup 

# Create & Associate IAM OIDC Provider for our EKS Cluster. 
To enable and use AWS IAM roles for Kubernetes service accounts on our EKS cluster.
eksctl utils associate-iam-oidc-provider \
    --region eu-north-1 \
    --cluster etclinic-eks-cluster  \
    --approve

# Create EKS NodeGroup in VPC Private Subnets .
eksctl create nodegroup --cluster=petclinic-eks-cluster \
                        --region=eu-north-1 \
                        --name=eksdemo1-ng-private1 \
                        --node-type=t3.medium \
                        --nodes-min=2 \
                        --nodes-max=4 \
                        --node-volume-size=20 \
                        --ssh-access \
                        --ssh-public-key=norway \
                        --managed \
                        --asg-access \
                        --external-dns-access \
                        --full-ecr-access \
                        --appmesh-access \
                        --alb-ingress-access \
                        --node-private-networking  

# Pre-requisite-3: 
Verify Cluster, Node Groups and configure kubectl cli.

# Verfy EKS Cluster
eksctl get cluster

# Verify EKS Cluster version
kubectl version --short

# Verify EKS Node Groups
eksctl get nodegroup --cluster=petclinic-eks-cluster

# Configure kubeconfig for kubectl
aws eks --region eu-north-1 update-kubeconfig --name petclinic-eks-cluster

# Verify EKS Nodes in EKS Cluster using kubectl
kubectl get nodes

# Load Balancer Controller Configuration

# Download IAM Policy
curl -o iam_policy_latest.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

# Create IAM Policy using policy downloaded 
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy_latest.json

Make a note of Policy ARN as we are going to use that in next step when creating IAM Role.
Replaced name, cluster and policy arn.

# Template
eksctl create iamserviceaccount \
  --cluster=my_cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \ #Note:  K8S Service Account Name that need to be bound to newly created IAM Role
  --attach-policy-arn=arn:aws:iam::111122223333:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

# Install the AWS Load Balancer Controller.
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=<region-code> \
  --set vpcId=<vpc-xxxxxxxx> \
  --set image.repository=<account>.dkr.ecr.<region-code>.amazonaws.com/amazon/aws-load-balancer-controller


![Image](https://github.com/user-attachments/assets/1a513bca-209f-476e-9db3-7961c8915960)





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
[![terraform](https://github.com/tanya-domi/s3-action/actions/workflows/terraform.yaml/badge.svg)](https://github.com/tanya-domi/s3-action/actions/workflows/terraform.yaml)

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

Step 12. Set up SSL: 
Create  SSL certificate in Certificate Manager

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

![Image](https://github.com/user-attachments/assets/65843a2c-6b93-4777-8dac-c470ffe4d3a0)


# Create RDS Database

Pre-requisite-1: Create DB Security Group

Create security group to allow access for RDS Database on port 3306

Security group name: eks_rds_db_sg

Description: Allow access for RDS Database on Port 3306

VPC: eksctl-eksdemo1-cluster/VPC

Inbound Rules
Type: MySQL/Aurora

Protocol: TPC

Port: 3306

Source: Anywhere (0.0.0.0/0)

Description: Allow access for RDS Database on Port 3306

Pre-requisite-2: Create DB Subnet Group in RDS

Go to RDS -> Subnet Groups

Click on Create DB Subnet Group

Name: eks-rds-db-subnetgroup

Description: EKS RDS DB Subnet Group

VPC: eksctl-eksdemo1-cluster/VPC

Availability Zones: eu-north-1a, eu-north-1b

Subnets: 2 subnets in 2 AZs
Click on Create

# Create RDS Database

Go to Services -> RDS
Click on Create Database

Choose a Database Creation Method: Standard Create

Engine Options: MySQL

Edition: MySQL Community

Version: 5.7.22 (default populated)

Template Size: Free Tier

DB instance identifier: petclinic

Master Username: petclinic

Master Password: petclinic

Confirm Password: petclinic

DB Instance Size: leave to defaults

Storage: leave to defaults

Connectivity
VPC: eksctl-eksdemo1-cluster/VPC

Additional Connectivity Configuration

Subnet Group: eks-rds-db-subnetgroup

Publicyly accessible: YES (for our learning and troubleshooting - if required)

VPC Security Group: Create New

Name: eks-rds-db-securitygroup

Availability Zone: No Preference

Database Port: 3306

Click on Create Database
![Image](https://github.com/user-attachments/assets/6d134a23-ee9a-46df-af62-87619e43f25e)

# Create mysql externalName Service
- Accessing RDS via ExternalName Service:
- To enable your Kubernetes workloads to connect to an Amazon RDS MySQL database, you can create a Kubernetes ExternalName service.
- This service maps a Kubernetes DNS name to the RDS MySQL connection endpoint, allowing pods to access the database using a consistent internal name without exposing credentials

![Image](https://github.com/user-attachments/assets/6e9ba0b3-cad1-4917-bb22-258dd97e85e7)


![Image](https://github.com/user-attachments/assets/ca84bc0d-94a4-4043-9116-a2b87af7ed9d)


# Connect to RDS Database using kubectl and create petclinic schema/db

kubectl run -it --rm --image=mysql:latest --restart=Never mysql-client -- mysql -h usermgmtdb.c7hldelt9xfp.eu-north-1.rds.amazonaws.com -u petclinic -ppetclinic

![Image](https://github.com/user-attachments/assets/8bfa82dd-6c01-4395-89f1-dc623c83cf0b)

# ArgoCD Installation:
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml

- Now, expose the argoCD server as LoadBalancer using the below command
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Set up the Monitoring for our EKS Cluster using Prometheus and Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

![Image](https://github.com/user-attachments/assets/b120c5ae-f692-402a-9f75-f64c8be47ff6)

# Review and Deploy Application 
CI/CD Automation with GitHub Actions and ArgoCD on AWS EKS:
GitHub Actions is used to automate the continuous integration (CI) process by building the application, creating a Docker image, and pushing it to a container registry (e.g., Amazon ECR). As part of the pipeline, the Kubernetes manifest files (e.g., Deployment, Service) are updated with the new image tag.

ArgoCD, configured to watch the Git repository, automatically detects changes to the manifests and synchronizes them to the Amazon EKS cluster. This enables a fully automated GitOps workflow, ensuring consistent, version-controlled, and auditable deployments to Kubernetes.

![Image](https://github.com/user-attachments/assets/8343aad1-dbeb-4a3e-a499-87cab5e5e9c0)


# Installation of ELK
# Deploy Amazon EBS CSI Driver for Kibana on EKS:
To enable persistent storage for Kibana in Amazon EKS, deploy the Amazon EBS CSI (Container Storage Interface) driver. This driver allows Kubernetes to dynamically provision and manage Amazon EBS volumes for stateful workloads like Kibana, ensuring log data and dashboard configurations persist across pod restarts or rescheduling.

![Image](https://github.com/user-attachments/assets/3c44f11f-a2e5-42d8-bd53-de2b1e0dda5e)

Kibana is exposed through an Ingress using an Application Load Balancer, allowing access via a web UI.

![Image](https://github.com/user-attachments/assets/1a2e56be-00a3-4fd0-97d8-9c3e600f0c9b)

# DNS Configuration: 
The domain’s DNS is configured by creating A Record in Route 53, which maps the domain name to the load balancer's DNS
![Image](https://github.com/user-attachments/assets/7af78ba9-ff10-46f4-8e95-3170cf943426)

# You validate  the Load Balancer  created 
![Image](https://github.com/user-attachments/assets/6e16c50a-fda4-4337-9bf2-13645da35ad8)

# Deployment is synced and healthy
![Image](https://github.com/user-attachments/assets/d856a4d8-5bdd-49d5-9880-f193b5c130dc)

Route 53 is used to manage DNS records that point to services (Application Load Balancer). An SSL certificate, typically issued through AWS Certificate Manager (ACM), is attached to the load balancer to enable HTTPS traffic.

![Image](https://github.com/user-attachments/assets/419b1deb-ca85-46f2-9b52-a45f64cd5409)

![Image](https://github.com/user-attachments/assets/9c750bcd-d695-499b-ade2-c670d15601f5)

# Build Custom Grafana Dashboards:
Here are tailored Grafana dashboards to visualize key application and infrastructure metrics by selecting relevant data sources (Prometheus) and designing panels that display time-series data, logs, or alerts.

![Image](https://github.com/user-attachments/assets/b3210975-6151-4c19-b548-4849744c0413)

![Image](https://github.com/user-attachments/assets/536046da-39a8-44f0-b1fa-53f89117d973)

# kibana
![Image](https://github.com/user-attachments/assets/e450a4f6-4701-4d08-8b70-249792a79cb6)

![Image](https://github.com/user-attachments/assets/a277a653-69be-4849-a9c3-03e0a496dc27)

# Slack Notification Channnel
![Image](https://github.com/user-attachments/assets/a0de18ee-fcc7-4aa4-9d0c-24e3f60cc21b)

# Conclusion:

In this comprehensive DevOps Kubernetes project, we successfully:

- Established IAM user and Terraform for AWS setup.
- Deployed Infrastructure on AWS using Github Actions and Terraform and, configured tools.
- Set up an EKS cluster, and configured a Load Balancer.
- Installed and configured ArgoCD for GitOps practices.
- Created Github Action pipelines for CI/CD, deploying microservice architecture application.
- Ensured Data Persistence Using RDS MySQL with Persistent Volume Claims:Integrated Amazon RDS MySQL with Kubernetes applications to ensure reliable, managed data persistence.
- Implemented Monitoring and Logging Stack with Helm:
Deployed a full observability stack using Helm charts to simplify installation and configuration. Monitoring was set up using Prometheus for metrics collection and Grafana for visualizations through custom dashboards.
- Logs from Kubernetes workloads were aggregated and analyzed using Kibana, providing powerful search and filtering capabilities. This setup enables real-time monitoring, alerting, and log analysis, ensuring better visibility into application and infrastructure performance.



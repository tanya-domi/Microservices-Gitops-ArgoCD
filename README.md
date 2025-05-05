
[![Petclinic-Ci](https://github.com/tanya-domi/k8s-microservices-Gitops-ArgoCD/actions/workflows/CI.yaml/badge.svg)](https://github.com/tanya-domi/k8s-microservices-Gitops-ArgoCD/actions/workflows/CI.yaml)

Note, This Project is a fork of the Spring Boot PetClinic, a widely recognized reference application designed to demonstrate the architecture and best practices of Spring Boot.

We extend our appreciation to the original maintainers and contributors for open-sourcing this excellent demo. PetClinic is often cited as one of the most effective examples for understanding real-world use of Spring Boot, layered architecture, testing strategies, and integration patterns.

This Project may include enhancements, environment-specific configurations, or CI/CD integrations to suit custom deployment or educational needs.


![Image](https://github.com/user-attachments/assets/0d58e42a-843d-4b26-9342-0b5b736a9700)


# Project Introduction:
Welcome to the End-to-End DevOps Kubernetes Project guide! This guide offers practical experience in deploying a secure, scalable microservices architecture on AWS with Kubernetes, incorporating DevOps best practices, security, and monitoring.

#Project Overview:

In this project, we will cover the following key aspects:
1. IAM User Setup: 
Create an IAM user on AWS with the necessary permissions to facilitate deployment and management activities.

2. Infrastructure as Code (IaC): 
Use Terraform and AWS CLI to set up the Jumphost server (EC2 instance) on AWS.

3. Github Actions Configuration: 
configure essential github actions workflow, including  Docker, Sonarqube, Terraform, Kubectl, and Trivy.

4. EKS Cluster Deployment: 
Utilize eksctl commands to create a customize Amazon EKS cluster, a managed Kubernetes service on AWS.

5. Load Balancer Controller Configuration: 
Configure AWS Application Load Balancer (ALB) for the EKS cluster.
    
6. Create Iamserviceaccount : 
Create an IAM role for the AWS Load Balancer Controller and attach the role to the Kubernetes service account.

7. Create RDS Mysql Database: 
Create security group to allow access for RDS Database on port 3306 and create DB Subnet Group in RDS.

6. Dockerhub Repositories: 
Automatically create repository for Docker images on Dockerhub.

7. ArgoCD Installation: 
Install and set up ArgoCD for continuous delivery and following GitOps approach.

8. Sonarqube Integration: 
Integrate Sonarqube for code quality analysis in the CI pipeline.

9 .Trivy Integration: 
Integrate Trivy for container image and filesystem vulnerability scanning in the CI pipeline.

10. Set up SSL: Create  SSL certificate in Certificate Manager

11. Monitoring Setup: 
Implement monitoring for the EKS cluster using Helm, Prometheus,  Grafana and  ELK.

12. ArgoCD Application Deployment: 
Leverage ArgoCD to implement a GitOps workflow, ensuring that application and infrastructure deployments are automated, auditable, and version-controlled.

13. DNS Configuration: 
Configure DNS settings to make the application accessible via custom subdomains.

14. Data Persistence: 
Test the application's ability to maintain data persistence to ensure that application state and user data are reliably stored and retained across deployments and pod restarts.

Conclusion and Monitoring: 
Conclude the project by creating custom dashboards in Grafana and Kibana to visualize key application metrics, system performance, and logs for monitoring and troubleshooting and summarize key achievements.

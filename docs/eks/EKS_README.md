
# Installation
aws --version
aws configure
aws ec2 describe-vpcs

  
kubectl version

eksctl version


# EKS admin role

Przypisać usera do roli
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::340507401402:user/pregnant-pills-pkimak"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}


Dodać uprawnienia
-  AWSCloudFormationFullAccess – eksctl tworzy klastry przez CloudFormation
- AmazonEC2FullAccess / AmazonVPCFullAccess – sieć, SG, ENI, subnets itd.
- EksAllAccess – akcje EKS (+ SSM/KMS jeśli wklejałaś wg wzorca)
- IamLimitedAccess – tworzenie ról/instance profile/oidc + iam:PassRole dla ról eksctl
- AmazonVPCFullAccess jest potrzebne, jeśli eksctl ma tworzyć VPC/subnety. 

Edytować profil aws
nano ~/.aws/config
[profile eks-admin]
role_arn = arn:aws:iam::340507401402:role/EksAdminRole
source_profile = default
region = eu-west-1

export AWS_PROFILE=eks-admin
export AWS_REGION=eu-west-1


# EKS
eksctl create cluster --name=ekstest1 \
                      --region=eu-west-1 \
                      --zones=eu-west-1a,eu-west-1b \
                      --without-nodegroup 


eksctl get cluster   

# To enable and use AWS IAM roles for Kubernetes service accounts on our EKS cluster, we must create & associate OIDC identity provider.

eksctl utils associate-iam-oidc-provider \
    --region eu-west-1 \
    --cluster ekstest1 \
    --approve

# Create a new EC2 Keypair with name as kube-demo
chmod 600 kube-demo.pem

# Create Public Node Group   
eksctl create nodegroup --cluster=ekstest1 \
                       --region=eu-west-1 \
                       --name=ekstest1-ng-public2 \
                       --node-type=t3.medium \
                       --nodes=2 \
                       --nodes-min=2 \
                       --nodes-max=4 \
                       --node-volume-size=20 \
                       --ssh-access \
                       --ssh-public-key=kube-demo \
                       --managed \
                       --asg-access \
                       --external-dns-access \
                       --full-ecr-access \
                       --appmesh-access \
                       --alb-ingress-access 



# zalogować sie do instancji przy pomocy kube-demo
ssh -i kube-demo.pem ec2-user@108.130.98.167


# z laptopa

## Upewnij się, że używasz profilu roli (a nie usera):
export AWS_PROFILE=eks-admin
export AWS_REGION=eu-west-1
aws sts get-caller-identity

## Pobierz kubeconfig dla EKS:
aws eks update-kubeconfig --name ekstest1 --region eu-west-1

# spr
kubectl get nodes -o wide
kubectl get pods -A

eksctl get cluster
eksctl get nodegroup --cluster=ekstest1
kubectl get nodes -o wide
kubectl config view --minify

# remove
eksctl delete nodegroup --cluster ekstest1 --name ekstest1-ng-public1 --region eu-west-1
eksctl delete cluster ekstest1


# PIA - pod identity access - aby pody miały dostep do uslug w aws
 Amazon EKS Pod Identity enables pods in your cluster to securely assume IAM roles without managing static credentials or using IRSA 

 ## Install the EKS Pod Identity Agent add-on
EKS → Clusters → Add-ons →  Pod Identity Agent

eksctl create addon \
  --cluster ekstest1 \
  --region eu-west-1 \
  --name eks-pod-identity-agent

## Create an IAM Role with trust policy for Pod Identity → allow Pods to access Amazon S3
Go to IAM Console → Roles → Create Role
Select Trusted entity type → Custom trust policy
Add trust policy for Pod Identity, for example:
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "pods.eks.amazonaws.com"
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        }
    ]
}
Attach AmazonS3ReadOnlyAccess policy
Create role → example name: EKS-PodIdentity-S3-ReadOnly-Role-101



## Create a Pod Identity Association between the Kubernetes Service Account and IAM Role
Go to EKS Console → Cluster → Access → Pod Identity Associations

Create new association:
Namespace: default
Service Account: aws-cli-sa
IAM Role: EKS-PodIdentity-S3-ReadOnly-Role-101

## Re-test from the AWS CLI Pod, successfully list S3 buckets
Pods don’t automatically refresh credentials after a new Pod Identity Association; they must be restarted.
kubectl delete pod aws-cli -n default
kubectl apply -f kube-manifests/k8s_aws_cli_pod.yaml
kubectl get pods

# List S3 buckets
kubectl exec -it aws-cli -- aws s3 ls


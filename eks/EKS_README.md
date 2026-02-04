
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
                       --name=ekstest1-ng-public1 \
                       --node-type=t3.micro \
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


                       
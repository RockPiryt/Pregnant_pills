
Jako pregnant-pills-pkimak lokalnie
aws configure
podac access keys

aws sts get-caller-identity


terraform init
terraform plan
terraform apply 

terraform import aws_key_pair.preg_key_pair2 preg-key-2

cd infra/terraform/preg-k3s
terraform destroy

-----------------------------------------------------
terraform output -raw k3s_public_ip
export K3S_IP="$(terraform output -raw k3s_public_ip)"
echo "$K3S_IP"
----------------------------------------
spr fingerprint 
ssh-keygen -lf ~/.ssh/id_rsa.pub
aws ec2 describe-key-pairs --key-names preg-key-2 --query "KeyPairs[0].KeyFingerprint" --output text
------------------------------------------------------------------------------
ssh -i ~/.ssh/id_rsa admin@$K3S_IP "sudo cat /etc/rancher/k3s/k3s.yaml" > kubeconfig
export KUBECONFIG="$PWD/kubeconfig"

---------------------------------------
Zrób tunel do API servera k3s (w osobnym terminalu)
ssh -i ~/.ssh/id_rsa -N -L 6443:127.0.0.1:6443 admin@$K3S_IP


kubectl get nodes -o wide
kubectl get pods -A
----------------------------------------------

kubectl apply -k infra/kubernetes/k8s-preg/overlays/dev
kubectl delete -k infra/kubernetes/k8s-preg/overlays/dev

----------------------
To jest podgląd manifestów, które Kustomize generuje przed wysłaniem do klastra.
 kubectl kustomize infra/kubernetes/k8s-preg/overlays/dev | sed -n '/kind: Service/,/---/p'





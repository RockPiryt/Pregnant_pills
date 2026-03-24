
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

export EIP="$(terraform output -raw eip_public_ip)"
echo "$EIP"
----------------------------------------
spr fingerprint 
ssh-keygen -lf ~/.ssh/id_rsa.pub
aws ec2 describe-key-pairs --key-names preg-key-2 --query "KeyPairs[0].KeyFingerprint" --output text
------------------------------------------------------------------------------
ssh -i ~/.ssh/id_rsa admin@$K3S_IP "sudo cat /etc/rancher/k3s/k3s.yaml" > kubeconfig
export KUBECONFIG="$PWD/kubeconfig"

ssh -i ~/.ssh/id_rsa admin@$EIP "sudo cat /etc/rancher/k3s/k3s.yaml" > kubeconfig
export KUBECONFIG="$PWD/kubeconfig"

---------------------------------------
Zrób tunel do API servera k3s (w osobnym terminalu)
ssh -i ~/.ssh/id_rsa -N -L 6443:127.0.0.1:6443 admin@$K3S_IP

ssh -i ~/.ssh/id_rsa -N -L 6443:127.0.0.1:6443 admin@$EIP

kubectl get nodes -o wide
kubectl get pods -A
----------------------------------------------

kubectl apply -k infra/kubernetes/k8s-preg/overlays/dev
kubectl delete -k infra/kubernetes/k8s-preg/overlays/dev

kubectl apply -k infra/kubernetes/k8s-preg/overlays/test
kubectl delete -k infra/kubernetes/k8s-preg/overlays/test


----------------------
To jest podgląd manifestów, które Kustomize generuje przed wysłaniem do klastra.
 kubectl kustomize infra/kubernetes/k8s-preg/overlays/dev | sed -n '/kind: Service/,/---/p'


---------------
kubectl -n preg-test exec -it test-postgres-686f6f64-7jzxh  -- psql -U postgres -d pill_db

Porownanie
kubectl -n preg-test describe deploy test-pregnant-pills-app | sed -n '/Environment:/,/Mounts:/p'

cd infra/kubernetes/k8s-preg/overlays/test
kubectl apply -f postgres-db-job-reset.yaml

Aby złapać problemy z job
sed 's/name: test-db-reset/name: test-db-reset-2/' postgres-db-job-reset.yaml | kubectl apply -n preg-test -f -
kubectl -n preg-test logs -f job/test-db-reset


export APP_ENV=testing
export DATABASE_URL=postgresql://postgres:mysecretpassword@localhost:5432/pill_db
export FLASK_APP=wsgi.py

flask db migrate -m "update models"
flask db upgrade

Commit migracji
build nowego obrazu
push

-----
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

---------------------
TAG=$(git rev-parse --short HEAD)
docker build -t rockpiryt/pregnant-pills:$TAG -t rockpiryt/pregnant-pills:latest .






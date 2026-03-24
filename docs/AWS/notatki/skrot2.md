
aws ssm start-session \
  --target i-XXXXXXXXXXXX \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["6443"],"localPortNumber":["6443"]}' \
  --region eu-west-1


  W drugim terminalu możesz sprawdzić czy port odpowiada:

curl -k https://127.0.0.1:6443

Jeśli K3s działa, zobaczysz odpowiedź API (może być JSON z błędem auth — to OK).


-----------
kustomize build infra/kubernetes/k8s-preg/overlays/prod 
✅ Jeśli to działa, znaczy, że wszystkie resources i patches istnieją i mają poprawne ścieżki.

kustomize build infra/kubernetes/k8s-preg/overlays/prod | kubeval
kustomize build infra/kubernetes/k8s-preg/overlays/prod | kube-linter lint -
To wykrywa:niepoprawne API w danej wersji K8s,brak wymaganych pól w Deployment / Service / Ingress

kubectl apply -k

------------------------------------------------
sudo k3s kubectl get pods -n preg-prod -o wide

---------------
lokalne budowanie Wariant B — budujesz obrazy lokalnie

Np. masz:

docker build -t prod-preg-baby:local ./baby
docker build -t prod-preg-memo:local ./memo
docker build -t prod-preg-nutri:local ./nutri
docker build -t prod-preg-org:local ./org
docker build -t prod-preg-pills:local ./pills

To potem załaduj je do klastra:

kind load docker-image prod-preg-baby:local --name preg-local
kind load docker-image prod-preg-memo:local --name preg-local
kind load docker-image prod-preg-nutri:local --name preg-local
kind load docker-image prod-preg-org:local --name preg-local
kind load docker-image prod-preg-pills:local --name preg-local


kubectl apply -k ~/preg/Pregnant_app/infra/kubernetes/k8s-preg/overlays/prod

kubectl get all -n preg-prod

--------------
docker system prune -a
------------
kind create cluster --name preg-local
kubectl config get-contexts
kubectl config use-context kind-preg-local
----------------------

terraform state list - lista utworzonych rzeczy przez terraform
terraform destroy -target=aws_instance.app

terraform plan -destroy \
  -target=aws_nat_gateway.preg_nat_a \
  -target=aws_nat_gateway.preg_nat_b \
  -target=aws_eip.preg_nat_eip_a \
  -target=aws_eip.preg_nat_eip_b \
  -target=aws_lb.preg_alb \
  -target=aws_db_instance.preg_postgres \
  -target=aws_instance.k3s_master \
  -target=aws_instance.k3s_worker_a \
  -target=aws_instance.k3s_worker_b


terraform destroy \
  -target=aws_nat_gateway.preg_nat_a \
  -target=aws_nat_gateway.preg_nat_b \
  -target=aws_eip.preg_nat_eip_a \
  -target=aws_eip.preg_nat_eip_b \
  -target=aws_lb.preg_alb \
  -target=aws_db_instance.preg_postgres \
  -target=aws_instance.k3s_master \
  -target=aws_instance.k3s_worker_a \
  -target=aws_instance.k3s_worker_b
------------------------------------------------------------------
  Problem z scheduler jak pending
  Wredy brak logow

Znalezienie przyczyny:
 
 Events:
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  3m45s  default-scheduler  0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. no new claims to deallocate, preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling.


  Sprawdzić nodeSelector i node labels
  node-role.kubernetes.io/worker: "true"
  kubectl get nodes --show-labels


  Przydzielenie podów do nodów
  kubectl -n preg-prod get pods -o wide

  Spr nazw nodów
kubectl get nodes
kubectl label node preg-local-control-plane node-role.kubernetes.io/worker=true

Dokładny opis nodów
 kubectl describe nodeskubectl -n preg-prod describe pod prod-preg-baby-app-75b8f4499f-v6t88

 -----------------
 gdy chce spr czy sie popranie wygeneruja pliki
 kustomize build . 
 ---------
 1. Czy AWS Load Balancer Controller w ogóle działa
kubectl get pods -n kube-system
kubectl get deployment -n kube-system
i potem:
kubectl logs -n kube-system deployment/aws-load-balancer-controller

2. Czy Ingress w ogóle został przyjęty przez kontroler (ALB DNS zobacze przez Kubernetes:)
kubectl get ingress -n preg-prod
kubectl describe ingress -n preg-prod ingress-preg


-----------------
dostep do poda bezposrednio
kubectl -n preg-prod port-forward svc/prod-preg-baby-svc 8080:80

bo bez svc/ albo pod/ kubectl próbował potraktować to jak pod, stąd:

curl -i http://localhost:8080/
curl -i http://localhost:8080/health
na ec2 i zadziała


-------------
reczne dodanie noda do clustra
curl -sfL https://get.k3s.io | \
  K3S_URL="https://10.0.27.3:6443" \
  K3S_TOKEN="pregnant-pills-token" \
  sh -

-----------------------------------------------------
env zawiera sciezke do lokalnej db a nie aws#

w compute
user_data = templatefile("${path.module}/scripts/install_k3s_master.sh", {
  K3S_TOKEN      = var.k3s_token
  MASTER_TLS_SAN = "127.0.0.1"
  ACM_CERT_ARN   = aws_acm_certificate_validation.preg_cert_validation.certificate_arn
  SECRET_KEY     = var.secret_key
  DATABASE_URL   = "postgresql://${var.db_user}:${var.db_password}@${aws_db_instance.preg_postgres.address}:5432/${var.db_name}?sslmode=require"
})

---------------
terraform state list - lista utworzonych rzeczy przez terraform
terraform destroy -target=aws_instance.app

terraform plan -destroy \
  -target=aws_nat_gateway.preg_nat_a \
  -target=aws_nat_gateway.preg_nat_b \
  -target=aws_eip.preg_nat_eip_a \
  -target=aws_eip.preg_nat_eip_b \
  -target=aws_lb.preg_alb \
  -target=aws_db_instance.preg_postgres \
  -target=aws_instance.k3s_master \
  -target=aws_instance.k3s_worker_a \
  -target=aws_instance.k3s_worker_b


terraform destroy \
  -target=aws_nat_gateway.preg_nat_a \
  -target=aws_nat_gateway.preg_nat_b \
  -target=aws_eip.preg_nat_eip_a \
  -target=aws_eip.preg_nat_eip_b \
  -target=aws_lb.preg_alb \
  -target=aws_db_instance.preg_postgres \
  -target=aws_instance.k3s_master \
  -target=aws_instance.k3s_worker_a \
  -target=aws_instance.k3s_worker_b


  Główne kosztowe zasoby
    • aws_db_instance.preg_postgres 
    • aws_instance.k3s_master 
    • aws_instance.k3s_worker_a 
    • aws_instance.k3s_worker_b 
    • aws_lb.preg_alb 
    • aws_nat_gateway.preg_nat_a 
    • aws_nat_gateway.preg_nat_b 
    • aws_eip.preg_nat_eip_a 
    • aws_eip.preg_nat_eip_b 

    
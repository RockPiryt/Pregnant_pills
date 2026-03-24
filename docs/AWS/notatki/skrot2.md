
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

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
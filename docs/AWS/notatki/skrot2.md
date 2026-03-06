
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


  
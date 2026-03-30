When running with a cloud-controller-manager (which one should do, since everything is out of tree), at various calls, it is expected to pass the node provider ID to the ccm as <provider>://<id>.

k3s, though, passes it as k3s://<hostname>. This makes a CCM reject it.

https://github.com/k3s-io/k3s/issues/1049

https://github.com/dereknola/docs-k3s/blob/8327f649a9dbed67a7f7fd0931f83ef56479381a/docs/networking/networking.md



---------------
1. AWS Load Balancer Controller - kontroler od:
- ALB / NLB
- Ingress / TargetGroupBinding

2. AWS Cloud Controller Manager - komponent od:
- integracji node ↔ cloud provider
- providerID
- adresów node’ów
- klastra jako “AWS-aware”


---------------------------
Tak. W Twoim klastrze musisz wdrożyć external AWS CCM, bo teraz masz tylko aws-load-balancer-controller, a to nie jest to samo. AWS CCM odpowiada za integrację node’ów z AWS, w tym rozpoznanie instancji i uzupełnianie danych cloud-provider; sam AWS Load Balancer Controller tego nie zastępuje. K3s wymaga wyłączenia wbudowanego CCM przez --disable-cloud-controller, a jeśli ustawisz kubelet na cloud-provider=external bez działającego zewnętrznego CCM, node’y mogą pozostać nie w pełni zainicjalizowane.

Co jest nie tak w Twoim obecnym skrypcie

W tej chwili instalujesz k3s tak:

INSTALL_K3S_EXEC="server \
  --disable traefik \
  --write-kubeconfig-mode 644 \
  --tls-san ${MASTER_TLS_SAN} \
  --node-taint node-role.kubernetes.io/control-plane=true:NoSchedule"

czyli bez:

--disable-cloud-controller
--kubelet-arg=cloud-provider=external

A dla klastra z external CCM te elementy są wymagane po stronie K3s/kubeleta. K3s udostępnia też pass-through flagi do kube-apiserver, kube-controller-manager i kubeleta.

Ważna konsekwencja

Sama zmiana skryptu nie naprawi już istniejących node’ów z providerID: k3s://.... Repozytorium K3s i utrzymujący projekt wskazują, że po zmianie modelu cloud providera node trzeba usunąć i dołączyć ponownie; kompatybilność wersji AWS CCM z Kubernetes też trzeba trzymać blisko wersji klastra.
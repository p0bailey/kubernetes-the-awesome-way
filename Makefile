#Authored by Phillip Bailey
.PHONY: all kube_bootstrap kube_ingress kube_dashboard kube_get_token kube_join_node  kube_status kube_up kube_down kube_Destroy
.SILENT:
SHELL := '/bin/bash'


all:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

kube_bootstrap: kube_up  ## Start and provision kubernetes cluster and helm.
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts.vagrant  ansible/kube-cluster-bootstrap.yml; \
	ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts.vagrant  ansible/kube-cluster-join.yml; \
	./kubectl apply -f kubernetes/manifests/tiller-sa.yaml; \
	./helm init --service-account tiller; \
	./helm  repo update; \
	make kube_status

kube_setup:  ## Install Metallb, Dashboard add-ons.
	./helm   upgrade --install   metallb --namespace=metallb-system -f  kubernetes/helm/charts/metallb/values.yaml stable/metallb; \
	./kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended/kubernetes-dashboard.yaml; \
	./kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml; \
	./kubectl apply -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml; \
	./kubectl apply -f kubernetes/manifests/dashboard-sa.yaml; \
	make kube_status

kube_ingress: ## Install Nginx ingress controller.
	./helm upgrade --install nginx-ingress  stable/nginx-ingress --set rbac.create=true; \
	make kube_status

kube_cheese_services_install: ## Install Cheese services.
	./kubectl apply -f kubernetes/manifests/cheeses_ingress/stilton.yaml; \
	./kubectl apply -f kubernetes/manifests/cheeses_ingress/cheddar.yaml; \
	make kube_status

kube_cheese_services_remove: ## Remove Cheese services.
	./kubectl delete -f kubernetes/manifests/cheeses_ingress/stilton.yaml; \
	./kubectl delete -f kubernetes/manifests/cheeses_ingress/cheddar.yaml; \
	make kube_status

kube_provision: kube_setup kube_ingress kube_cheese_services_install

kube_get_token: ## Retieve dashboard access token.
	./kubectl describe secret  my-dashboard-sa -n kube-system > dashboard_token.txt; \
	cat dashboard_token.txt

kube_dashboard: kube_get_token ## Open kubernetes dashboard.
		@open  http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

kube_join_node: kube_up  ## Joins new node into the cluster.
		ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts.vagrant  ansible/kube-cluster-join.yml

kube_status:  ## Show kubernetes cluster status.
	echo "All K8 Services";\
	./kubectl get svc --all-namespaces; \
	echo "All K8 Pods";\
	./kubectl  get pods --all-namespaces; \
	echo "All K8 Cluster nodes";\
	./kubectl  get nodes -o wide

kube_up: ## Start kubernetes cluster.
	  vagrant up --parallel

kube_down: ## Start kubernetes cluster.
	  vagrant halt

kube_Destroy: ## Destroy kubernetes cluster!!!.
	  vagrant destroy --force; \
		rm -f .admin.conf; \
		rm -f dashboard_token.txt

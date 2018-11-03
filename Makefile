#Authored by Phillip Bailey
.PHONY: all kube_bootstrap kube_dashboard kube_get_token kube_join_node  kube_status kube_up kube_down kube_Destroy
.SILENT:
SHELL := '/bin/bash'

all:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

kube_bootstrap: kube_up  ## Start and provision kubernetes cluster.
		ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts.vagrant  ansible/kube-cluster-bootstrap.yml -v; \
		ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts.vagrant  ansible/kube-cluster-join.yml -v; \
		./kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml; \
		./kubectl create serviceaccount my-dashboard-sa; \
		./kubectl create clusterrolebinding my-dashboard-sa \
     --clusterrole=cluster-admin \
     --serviceaccount=default:my-dashboard-sa; \
		./kubectl apply -f kubernetes/manifests/tiller.yml; \
		./helm init --service-account tiller; \
    ./helm  update

kube_dashboard: kube_get_token ## Open kubernetes dashboard.
		@open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

kube_get_token: ## Retieve dashboard access token.
	./kubectl  describe secret  my-dashboard-sa-token- | grep token:

kube_join_node: kube_up  ## Joins new node into the cluster.
		ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/hosts.vagrant  ansible/kube-cluster-join.yml

kube_status:  ## Show kubernetes cluster status.
	 ./kubectl get pods --all-namespaces; \
	 ./kubectl get nodes

kube_up: ## Start kubernetes cluster.
	  vagrant up

kube_down: ## Start kubernetes cluster.
	  vagrant halt

kube_Destroy: ## Destroy kubernetes cluster.
	  vagrant destroy --force; \
		rm -rf .vagrant/; \
		rm -f admin.conf

TF_DIR=terraform
ANS_DIR=ansible

.PHONY: up provision destroy

up:
	cd $(TF_DIR) && terraform init && terraform apply -auto-approve

provision:
	cd $(ANS_DIR) && ansible-playbook -i inventories/hosts.ini site.yml

destroy:
	cd $(TF_DIR) && terraform destroy -auto-approve
init:	
	terraform init -backend-config="resource_group_name=rg-state-dtype-dev" -backend-config="storage_account_name=stdtypestatedev" -backend-config="container_name=state" -backend-config="key=state.tfstate" 
plan:
	terraform plan -var-file="tfvars/dev.tfvars" -var="service_principal_name=Github"
apply:
	terraform apply -var-file="tfvars/dev.tfvars" -var="service_principal_name=Github"
lint:
	terraform fmt -recursive
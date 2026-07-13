TERRAFORM_CMD := docker run --rm -it -v `pwd`:/terraform-aws-modules -w /terraform-aws-modules hashicorp/terraform:latest

.PHONY: fmt

fmt: ## Format all .tf files in the repo using the terraform docker image
	$(TERRAFORM_CMD) fmt -recursive .

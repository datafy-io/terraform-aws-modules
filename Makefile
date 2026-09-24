TERRAFORM_CMD := docker run --rm -it -v `pwd`:/terraform-aws-modules -w /terraform-aws-modules hashicorp/terraform:latest

.PHONY: fmt
fmt: ## Format all .tf files in the repo using the terraform docker image
	$(TERRAFORM_CMD) fmt -recursive .

.PHONY: test
test: ## Run terraform test for every module that has tests, using the terraform docker image
	@for dir in modules/*/; do \
		[ -d "$$dir/tests" ] || continue; \
		echo; echo "==> $$dir"; \
		$(TERRAFORM_CMD) -chdir="$$dir" init -backend=false || exit 1; \
		$(TERRAFORM_CMD) -chdir="$$dir" test || exit 1; \
	done

# Nginx Example Makefile
# Common commands for building, testing, and deploying

.PHONY: help build deploy-dev deploy-prod test clean lint

# Default target
help:
	@echo "Available commands:"
	@echo "  build        - Build the application manifests"
	@echo "  deploy-dev   - Deploy to development environment"
	@echo "  deploy-staging - Deploy to staging environment"
	@echo "  deploy-prod  - Deploy to production environment"
	@echo "  test         - Test the application"
	@echo "  clean        - Clean up resources"
	@echo "  lint         - Lint Kubernetes manifests"
	@echo "  status       - Check application status"

# Build manifests
build:
	@echo "Building manifests..."
	kubectl kustomize k8s/overlays/dev > build/dev-manifests.yaml
	kubectl kustomize k8s/overlays/staging > build/staging-manifests.yaml
	kubectl kustomize k8s/overlays/prod > build/prod-manifests.yaml
	@echo "Manifests built in build/ directory"

# Deploy to development
deploy-dev:
	@echo "Deploying to development environment..."
	./scripts/deploy.sh dev

# Deploy to staging
deploy-staging:
	@echo "Deploying to staging environment..."
	./scripts/deploy.sh staging

# Deploy to production
deploy-prod:
	@echo "Deploying to production environment..."
	./scripts/deploy.sh prod

# Test the application
test:
	@echo "Testing application..."
	@echo "Checking if kubectl is available..."
	@kubectl version --client --short
	@echo "Checking cluster connectivity..."
	@kubectl cluster-info
	@echo "Testing kustomize build..."
	@kubectl kustomize k8s/overlays/dev > /dev/null
	@kubectl kustomize k8s/overlays/prod > /dev/null
	@echo "All tests passed!"

# Clean up resources
clean:
	@echo "Cleaning up resources..."
	kubectl delete namespace nginx-example-dev --ignore-not-found=true
	kubectl delete namespace nginx-example-staging --ignore-not-found=true
	kubectl delete namespace nginx-example-prod --ignore-not-found=true
	@echo "Cleanup completed"

# Lint manifests
lint:
	@echo "Linting Kubernetes manifests..."
	@if command -v kubeval >/dev/null 2>&1; then \
		echo "Using kubeval for validation..."; \
		kubectl kustomize k8s/overlays/dev | kubeval --strict; \
		kubectl kustomize k8s/overlays/prod | kubeval --strict; \
	else \
		echo "kubeval not found, using kubectl --dry-run..."; \
		kubectl apply -k k8s/overlays/dev --dry-run=client; \
		kubectl apply -k k8s/overlays/prod --dry-run=client; \
	fi

# Check application status
status:
	@echo "Checking application status..."
	@echo "Development environment:"
	kubectl get all -n nginx-example-dev 2>/dev/null || echo "Namespace not found"
	@echo ""
	@echo "Staging environment:"
	kubectl get all -n nginx-example-staging 2>/dev/null || echo "Namespace not found"
	@echo ""
	@echo "Production environment:"
	kubectl get all -n nginx-example-prod 2>/dev/null || echo "Namespace not found"

# Create build directory
build-dir:
	mkdir -p build

# Install ArgoCD application
install-argocd:
	@echo "Installing ArgoCD application..."
	kubectl apply -f argocd-app.yaml
	@echo "ArgoCD application installed"

# Uninstall ArgoCD application
uninstall-argocd:
	@echo "Uninstalling ArgoCD application..."
	kubectl delete -f argocd-app.yaml --ignore-not-found=true
	@echo "ArgoCD application uninstalled"

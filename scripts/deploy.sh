#!/bin/bash

# Nginx Example ArgoCD Deployment Script
# Usage: ./deploy.sh [dev|prod|base]

set -e

ENVIRONMENT=${1:-dev}
NAMESPACE="nginx-example-${ENVIRONMENT}"

echo "🚀 Deploying nginx-example to ${ENVIRONMENT} environment..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we're connected to a cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Not connected to a Kubernetes cluster"
    exit 1
fi

echo "📋 Current cluster context: $(kubectl config current-context)"

# Create namespace if it doesn't exist
echo "🔧 Creating namespace: ${NAMESPACE}"
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# Deploy using kustomize
echo "📦 Deploying from k8s/overlays/${ENVIRONMENT}..."
kubectl apply -k k8s/overlays/${ENVIRONMENT}

# Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/nginx-example -n ${NAMESPACE}

# Get service information
echo "🔍 Service information:"
kubectl get svc -n ${NAMESPACE}

# Get pod status
echo "📊 Pod status:"
kubectl get pods -n ${NAMESPACE}

echo "✅ Deployment completed successfully!"
echo ""
echo "To access the application:"
echo "  kubectl port-forward svc/nginx-example 8080:80 -n ${NAMESPACE}"
echo "  Then open http://localhost:8080 in your browser"
echo ""
echo "To check logs:"
echo "  kubectl logs -f deployment/nginx-example -n ${NAMESPACE}"

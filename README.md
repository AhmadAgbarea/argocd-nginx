# Nginx Example - ArgoCD Ready Repository

This repository contains a complete nginx application example that's ready to be deployed using ArgoCD with GitOps principles. It demonstrates best practices for multi-environment deployments using Kustomize overlays.

## 🏗️ Repository Structure

```
nginx-example/
├── README.md                           # This file
├── argocd-app.yaml                    # ArgoCD Application manifest
├── k8s/                               # Kubernetes manifests
│   ├── base/                          # Base configuration
│   │   ├── kustomization.yaml         # Base kustomization
│   │   ├── deployment.yaml            # Nginx deployment
│   │   ├── service.yaml               # Service definition
│   │   ├── ingress.yaml               # Ingress configuration
│   │   └── configmap.yaml             # Nginx configuration
│   └── overlays/                      # Environment-specific overlays
│       ├── dev/                       # Development environment
│       │   ├── kustomization.yaml     # Dev kustomization
│       │   ├── patch.yaml             # Dev-specific patches
│       │   └── ingress-patch.yaml     # Dev ingress configuration
│       ├── staging/                   # Staging environment
│       │   ├── kustomization.yaml     # Staging kustomization
│       │   ├── patch.yaml             # Staging-specific patches
│       │   └── ingress-patch.yaml     # Staging ingress configuration
│       └── prod/                      # Production environment
│           ├── kustomization.yaml     # Prod kustomization
│           ├── patch.yaml             # Prod-specific patches
│           └── ingress-patch.yaml     # Prod ingress configuration
└── scripts/
    └── deploy.sh                      # Deployment script
```

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster with ArgoCD installed
- `kubectl` configured to access your cluster
- `argocd` CLI tool (optional)

### 1. Clone and Customize

```bash
# Clone this repository
git clone <your-repo-url>
cd nginx-example

# Update the repository URL in argocd-app.yaml
# Replace: https://github.com/your-username/your-repo.git
# With: your actual repository URL
```

### 2. Deploy with ArgoCD

```bash
# Apply the ArgoCD Application
kubectl apply -f argocd-app.yaml

# Check application status
kubectl get applications -n argocd
argocd app get nginx-example
```

### 3. Manual Deployment (Alternative)

```bash
# Make the deployment script executable
chmod +x scripts/deploy.sh

# Deploy to development environment
./scripts/deploy.sh dev

# Deploy to production environment
./scripts/deploy.sh prod
```

## 🔧 Configuration

### Base Configuration

The base configuration (`k8s/base/`) contains:
- **Deployment**: 2 replicas with health checks and resource limits
- **Service**: ClusterIP service on port 80
- **Ingress**: Base ingress configuration with SSL/TLS support
- **ConfigMap**: Custom nginx configuration with health endpoint

### Environment Overlays

#### Development (`k8s/overlays/dev/`)
- 1 replica for cost optimization
- Lower resource limits (50m CPU, 64Mi memory)
- Debug logging enabled
- Development-specific labels

#### Staging (`k8s/overlays/staging/`)
- 2 replicas for testing
- Moderate resource limits (100m CPU, 128Mi memory)
- Staging logging (info level)
- Staging-specific labels

#### Production (`k8s/overlays/prod/`)
- 3 replicas for high availability
- Higher resource limits (200m CPU, 256Mi memory)
- Production logging (info level)
- Prometheus monitoring annotations
- Production-specific labels

## 🌐 Ingress and Domain Configuration

### Domain Structure
The application is configured with the following domain pattern:
- **Development**: `nginx-dev.iqball.tech`
- **Staging**: `nginx-staging.iqball.tech`
- **Production**: `nginx-prod.iqball.tech`

### Ingress Features
- **SSL/TLS**: Automatic certificate management with cert-manager
- **SSL Redirect**: Production environment forces HTTPS
- **Rate Limiting**: Production includes rate limiting (100 requests/minute)
- **Health Endpoint**: Custom `/health` endpoint for monitoring
- **Custom Headers**: Environment-specific headers for identification

### Prerequisites for Ingress
- NGINX Ingress Controller installed in the cluster
- cert-manager installed and configured
- DNS records pointing to your ingress controller
- Cluster issuers configured for Let's Encrypt

## 📊 ArgoCD Integration

### Application Manifest

The `argocd-app.yaml` file configures:
- **Source**: Points to this repository with dev overlay as default
- **Destination**: Deploys to `nginx-example` namespace
- **Sync Policy**: Automated sync with pruning and self-healing
- **Namespace Creation**: Automatically creates target namespace

### GitOps Workflow

1. **Make Changes**: Edit manifests in the `k8s/` directory
2. **Commit & Push**: Push changes to your Git repository
3. **Auto-Sync**: ArgoCD automatically detects changes and syncs
4. **Monitor**: Check sync status in ArgoCD UI or CLI

## 🧪 Testing

### Health Check

```bash
# Port forward to access the service
kubectl port-forward svc/nginx-example 8080:80 -n nginx-example-dev

# Test health endpoint
curl http://localhost:8080/health
```

### Logs

```bash
# Check application logs
kubectl logs -f deployment/nginx-example -n nginx-example-dev
```

## 🔒 Security Considerations

- **Network Policy**: Consider adding NetworkPolicies for production use
- **RBAC**: Implement proper RBAC for ArgoCD applications
- **Secrets**: Use sealed secrets or external secret operators for sensitive data
- **Image Scanning**: Implement container image scanning in your CI/CD pipeline

## 🚨 Troubleshooting

### Common Issues

1. **Sync Failed**: Check ArgoCD application logs
   ```bash
   argocd app logs nginx-example
   ```

2. **Pods Not Ready**: Check pod events and logs
   ```bash
   kubectl describe pods -n nginx-example-dev
   kubectl logs -n nginx-example-dev
   ```

3. **Service Not Accessible**: Verify service and endpoints
   ```bash
   kubectl get svc,ep -n nginx-example-dev
   ```

### Debug Commands

```bash
# Check ArgoCD sync status
argocd app sync-status nginx-example

# Force sync
argocd app sync nginx-example

# Check application resources
argocd app resources nginx-example
```

## 📈 Monitoring

### Prometheus Integration

The production overlay includes Prometheus annotations for metrics collection:
- `prometheus.io/scrape: "true"`
- `prometheus.io/port: "80"`
- `prometheus.io/path: "/metrics"`

### Custom Metrics

The nginx configuration includes a `/health` endpoint for health checks and monitoring.

## 🔄 Updates and Maintenance

### Updating Nginx Version

1. Update the image tag in base kustomization
2. Commit and push changes
3. ArgoCD will automatically sync the new version

### Adding New Environments

1. Create a new overlay directory (e.g., `k8s/overlays/staging/`)
2. Copy and customize the kustomization and patch files
3. Update ArgoCD application to point to the new overlay

## 📚 Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kustomize Documentation](https://kustomize.io/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/)
- [GitOps Principles](https://www.gitops.tech/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

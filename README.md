# homelab-flux

Flux v2-managed Kubernetes clusters.

- **kind** = dev cluster
- **k3s** = stage cluster

## Bootstrap

### Prerequisites

```bash
kind get clusters   # should list: kind-flux
flux version        # verify flux CLI is installed
export GITHUB_TOKEN=ghp_your_token_here
```

### Configure

Edit `Makefile` and change `--owner=skravops-cmd` to your GitHub username.

### Bootstrap Flux

```bash
make bootstrap
```

Installs Flux (with `image-reflector-controller` and `image-automation-controller`) into the cluster and commits manifests to `clusters/kind-flux`.

### Verify

```bash
flux get kustomizations
```

### Force reconciliation

```bash
flux reconcile source git flux-system
flux reconcile kustomization flux-system
```

## Repository structure

```
apps/                    # Application workloads
  nginx/                 #   raw manifests (Deployment + Service)
    base/
    overlays/dev/
    overlays/stage/
  uptime-kuma/           #   HelmRelease
    base/
    overlays/dev/
    overlays/stage/
  homepage/              #   raw manifests (Deployment + Service + Ingress)
    base/
    overlays/dev/
    overlays/stage/
clusters/
  kind-flux/             # dev cluster config
    flux-system/         #   Flux controllers + sync manifests
    kustomization.yaml   #   root overlay including apps + infrastructure
    apps.yaml            #   references dev overlays
    infrastructure.yaml  #   references HelmRepository sources
  k3s-flux/              # stage cluster config (same structure)
infrastructure/
  sources/
    helmrepositories/    # HelmRepository definitions (bitnami)
Makefile
```

## Clusters

| Cluster | Path | nginx replicas | uptime-kuma | homepage | traefik access |
|---------|------|----------------|-------------|----------|----------------|
| kind (dev) | `clusters/kind-flux/` | 1 | dev overlay | raw manifests | `kubectl port-forward -n kube-system svc/traefik 8080:80 8443:443`; `kubectl port-forward -n homepage svc/homepage 3000:3000` |
| k3s (stage) | `clusters/k3s-flux/` | 3 | stage overlay | raw manifests | LoadBalancer IP (k3s ServiceLB); `http://homepage.local` (add to /etc/hosts) |

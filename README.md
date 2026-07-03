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
| kind (dev) | `clusters/kind-flux/` | 1 | dev overlay | raw manifests | `kubectl port-forward -n kube-system svc/traefik 8080:80` (see [Access](#access)) |
| k3s (stage) | `clusters/k3s-flux/` | 3 | stage overlay | raw manifests | Traefik LoadBalancer IP; needs real domain |

## Access

### Dev (kind)

kind has no built-in LoadBalancer, so port-forward Traefik to reach all Ingress routes:

```bash
# Terminal 1 — keep this running
kubectl port-forward -n kube-system svc/traefik 8080:80
```

Add to your Windows hosts file (`C:\Windows\System32\drivers\etc\hosts`):
```
127.0.0.1 nginx.local uptime.local homepage.local
```

Then open in your browser:
- http://nginx.local:8080
- http://uptime.local:8080
- http://homepage.local:8080

### Stage (k3s)

k3s ServiceLB assigns a real LoadBalancer IP to Traefik. Once you have a domain, update the Ingress hosts from `.local` to your domain and add DNS A records pointing to the Traefik IP.

```bash
kubectl get svc -n kube-system traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

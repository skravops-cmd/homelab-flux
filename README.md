# homelab-flux

Flux v2-managed Kubernetes cluster on kind.

## Prerequisites

- [flux CLI](https://fluxcd.io/flux/installation/#install-the-flux-cli) v2.8.8

```bash
curl -s https://fluxcd.io/install.sh | sudo bash
```

- [kind](https://kind.sigs.k8s.io/) cluster running
- GitHub token with `repo` scope: `export GITHUB_TOKEN=<your-token>`

## Bootstrap

```bash
# Regenerate controller manifests (if you change the component list)
make install

# Bootstrap flux into the cluster
make bootstrap

# Force reconciliation after pushing changes
flux reconcile source git flux-system
flux reconcile kustomization apps-home-helm
flux reconcile kustomization infrastructure
```

## Repository structure

```
apps/                  # Application workloads
  home-base/           #   podinfo as a plain Deployment
  home-helm/           #   podinfo as a HelmRelease
  home-overlay/        #   podinfo with overlay patch
clusters/kind-flux/    # Cluster config: Flux Kustomizations + controllers
infra/                 # Image automation (ImagePolicy, ImageRepository, etc.)
```

# homelab-flux

Flux v2-managed Kubernetes cluster on kind.

## Bootstrap

### 1. Prerequisites

- **kind cluster** running (named `kind-flux`):
  ```bash
  kind get clusters   # should list: kind-flux
  ```

- **flux CLI** installed:
  ```bash
  curl -s https://fluxcd.io/install.sh | sudo bash
  flux version        # verify
  ```

- **GitHub token** with `repo` scope:
  ```bash
  export GITHUB_TOKEN=ghp_your_token_here
  ```

### 2. Configure the owner

Edit `Makefile` and change `--owner=skravops-cmd` to your GitHub username.

### 3. Bootstrap Flux into the cluster

```bash
make bootstrap
```

This installs Flux (with `image-reflector-controller` and `image-automation-controller`) into the cluster and commits the manifests to the `clusters/kind-flux` path in your GitHub repo.

### 4. Verify

```bash
flux get kustomizations
```

### 5. Force reconciliation (after pushing changes)

```bash
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

## Image Automation

Regenerate the `ImageUpdateAutomation` resource if needed:

```bash
flux create image update flux-system \
--git-repo-ref=flux-system \
--git-repo-path="./clusters/kind-flux" \
--checkout-branch=main \
--push-branch=main \
--author-name=fluxcdbot \
--author-email=fluxcdbot@users.noreply.github.com \
--commit-template="{{range .Updated.Images}}{{println .}}{{end}}" \
--export > ./clusters/kind-flux/flux-system-automation.yaml
```

## Testing apps via Ingress

Forward Traefik to an unprivileged local port (no sudo):

```bash
kubectl -n kube-system port-forward svc/traefik 8080:80 &
```

Add DNS and access your app:

```bash
echo "127.0.0.1 memos.local" | sudo tee -a /etc/hosts
curl http://memos.local
```

For other apps (kuma, nginx, etc.) create their Ingress + add a DNS entry the same way.
```

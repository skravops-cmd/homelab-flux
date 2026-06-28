export GITHUB_TOKEN ?= <your-token>

# Regenerate Flux component manifests (run after changing --components list)
install:
	flux install \
		--components=source-controller,kustomize-controller,helm-controller,notification-controller,image-reflector-controller,image-automation-controller \
		--export > clusters/kind-flux/flux-system/gotk-components.yaml

# Bootstrap a new cluster from scratch
bootstrap:
	flux bootstrap github \
		--token-auth \
		--owner=skravops-cmd \
		--repository=homelab-flux \
		--branch=main \
		--path=clusters/kind-flux \
		--personal

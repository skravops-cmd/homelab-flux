export GITHUB_TOKEN ?= <your-token>

# Bootstrap a new cluster from scratch
bootstrap:
	flux bootstrap github \
  		--components-extra=image-reflector-controller,image-automation-controller \
		--token-auth \
		--owner=skravops-cmd \
		--repository=homelab-flux \
		--branch=main \
		--path=clusters/dev/kind-flux \
		--personal

bootstrap-k3s:
	flux bootstrap github \
  		--components-extra=image-reflector-controller,image-automation-controller \
		--token-auth \
		--owner=skravops-cmd \
		--repository=homelab-flux \
		--branch=main \
		--path=clusters/stage/k3s-flux \
		--personal
# export GITHUB_TOKEN=<your-token>

bootstrap:
	flux bootstrap github \
  		--token-auth \
  		--owner=skravops-cmd \
  		--repository=homelab-flux \
  		--branch=main \
		--path=clusters/kind-flux \
  		--personal

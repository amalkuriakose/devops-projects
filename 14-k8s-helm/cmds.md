Add a repository

> helm repo add 

List repositories

> helm repo ls

Search a repo

> helm search repo repo-name

Install a chart

> helm install release-name repo/package

List all releases

> helm ls --all-namespaces

Check release status

> helm status release-name

Uninstall a release

> helm uninstall release-name

Upgrade a release

>  helm upgrade release-name repo/package

Rollback a revision

> helm rollback release-name revision-number

Create a chart

> helm create chart-name


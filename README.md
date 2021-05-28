# rpi-k8s nfs subdir external provisioner

This leverages tooling found in the [Kubernetes NFS Subdir External
Provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner)
repo to
 - create accounts/roles/rolebindings
 - create deployments to actually create the PV provisioner
 - etc.

I'm following the instructions in that project's README, and I'll make note of
what I've done differently

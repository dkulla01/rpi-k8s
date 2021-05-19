#!/usr/bin/bash


set -x
set -e


# set up apt-get indices
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# set up the google cloud public signing key
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# add the kubernetes apt repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list



# install docker

if [ ! -f "/usr/bin/docker" ]; then
  export VERSION='20.10.6'
  echo >&2 "installing docker, version ${VERSION}"
  curl -sSL get.docker.com | sh && sudo usermod pi -aG docker
  unset VERSION
else
  echo >&2 "docker is already installed. skipping"
fi

# install vim, httpie
echo >&2 "installing vim and httpie and other nice-to-have things"
sudo apt install -y vim
sudo apt install -y httpie
sudo apt install -y git

# turn off swap
echo >&2 "turning off swap"
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo update-rc.d dphys-swapfile remove
sudo systemctl disable dphys-swapfile.service

#enable cgroups on boot
echo >&2 "enabling cgroups"
sudo sed -i -e 's/$/ cgroup_enable=cpuset cgroup_memory=2 cgroup_enable=memory/' /boot/cmdline.txt



## let iptables see bridged traffic
if [ ! -f "/stc/modules-load.d/k8s.conf" ]; then
  cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
else
  echo >&2 "br_netfilter is already loaded"
fi

if [ ! -f "/etc/sysctl.d/k8s.conf" ]; then
  cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
  sudo sysctl --system
fi

KUBE_VERSION='1.21'
sudo apt-get install -y kubelet="$KUBE_VERSION" kubeadm="$KUBE_VERSION" kubectl="$KUBE_VERSION"
sudo apt-mark hold kubelet kubeadm kubectl

# add bashrc configuration
echo >&2 "adding alias k=kubectl to bashrc"
echo "alias k='kubectl'" >> "${HOME}/.bashrc"

echo >&2 "done installing all of the kube administrative things. reboot this machine now."

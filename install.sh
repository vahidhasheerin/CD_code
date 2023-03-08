#!/bin/bash
function install_docker_ce() {
    # installs and configures Docker CE
    echo "Installing Docker CE ..."
    cd /tmp/k8_package/docker_deb
    sudo dpkg -i *.deb
    sleep 2
    echo "Adding user to group 'docker'"
    sudo groupadd -f docker
    sudo usermod -aG docker $USER
    sleep 5
    #sg docker -c "docker version" || FATAL "Docker installation failed"
    echo "... Docker CE installation done"
    #return 0
}

function install_docker-compose() {
    cd /tmp/k8_package
    sudo cp docker-compose /usr/local/bin
    sudo chmod +x /usr/local/bin/docker-compose
    docker-compose --version
}

function load_images() {
    cd /tmp/k8_package/docker_images/
    ls -1 *.tar | xargs --no-run-if-empty -L 1 sudo docker load -i
    echo "Images loaded successfully ..."

}

function install_kube() {
    echo "Installing Kubernetes Packages ..."
    cd /tmp/k8_package/kube_deb
    sudo dpkg -i *.deb
}

function install_controlplane() {
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16
    sleep 5
    mkdir -p $HOME/.kube
    sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    kubectl taint nodes --all node-role.kubernetes.io/master-
    #export KUBECONFIG=$HOME/.kube/admin.conf
}

function install_cni() {
    cd /tmp/k8_package/kube_deb
    kubectl apply -f calico.yaml
}

function install_helm() {
    sudo dpkg -i /tmp/k8_package/helm_3.5.4-1_amd64.deb
    echo "helm installed successfully ..."
    helm version
}

install_docker_ce
install_docker-compose
load_images
install_kube
install_controlplane
install_cni
echo "Kubernetes is installed successfully ..."
kubeadm version
install_helm
echo -e "\nDONE"

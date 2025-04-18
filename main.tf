resource "aws_instance" "k8s_nodes" {
  count         = 2
  ami           = "ami-0c02fb55956c7d316" 
  instance_type = "t3.medium"
  key_name      = "devops-key" 

  subnet_id                   = element(module.vpc.public_subnets, count.index)
  associate_public_ip_address = true
  vpc_security_group_ids      = [module.vpc.default_security_group_id]

  tags = {
    Name = "${terraform.workspace}-k8s-node-${count.index}"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker

              # Kubernetes tools install
              cat <<EOT > /etc/yum.repos.d/kubernetes.repo
              [kubernetes]
              name=Kubernetes
              baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
              enabled=1
              gpgcheck=1
              repo_gpgcheck=1
              gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
              EOT

              yum install -y kubelet kubeadm kubectl
              systemctl enable --now kubelet
              EOF
}

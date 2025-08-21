# Kubernetes Cluster Setup with Terraform, Ansible, kubeadm, and CRI-O

This repository contains a complete workflow to **provision and configure a Kubernetes cluster from scratch on AWS** using:

- **Terraform** → Infrastructure as Code (EC2 instances, security groups, networking)  
- **Ansible** → Cluster configuration (installing packages, CRI-O runtime, kubeadm , kubeconfig setup)  
- **kubeadm** → Bootstrapping the Kubernetes control-plane and workers  
- **CRI-O** → Container runtime for Kubernetes

---

## 📌 Why this approach?

1. **Terraform** ensures reproducible, version-controlled cloud infrastructure.  
   - No manual EC2 provisioning.  
   - Easy comission and decomission of infrastructure resources (`terraform destroy` / `terraform apply`).  

2. **Ansible** automates cluster setup steps.  
   - No need to SSH and run commands one by one.  
   - Consistent across multiple runs.  

3. **kubeadm** provides a simple and upstream-supported way to bootstrap Kubernetes.  

4. **CRI-O** is a lightweight container runtime for Kubernetes. Other options are `Docker` and `Containerd`

---

## ⚙️ Project Setup

1. Install Terraform and Ansible on your machine
2. AWS setup  
   - Create IAM user and export the credentials on terminal  
     ```bash
     export AWS_ACCESS_KEY_ID=
     export AWS_SECRET_ACCESS_KEY=
     ```
   - Generate keypair for logging into remote machines  

3. Execute the following code to create and provision AWS resources  
     ```bash
     make up
     make provision
     ```

4. To delete the resources, execute the following  
     ```bash
     make destroy
     ```

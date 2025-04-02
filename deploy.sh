#!/bin/bash

set -e  # Exit immediately if any command fails
set -o pipefail  # Catch errors in pipes

# Default values
KEY1_PATH=""

# Parse command-line arguments
for arg in "$@"; do
  case $arg in
    -key=*)
      KEY1_PATH="$(realpath "$(eval echo "${arg#*=}")")"
      shift
      ;;
    *)
      echo "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

# Validate that the SSH key path was provided
if [[ -z "$KEY1_PATH" ]]; then
  echo "Error: Missing required argument -key=<path_to_ssh_key>"
  exit 1
fi

if [[ ! -f "$KEY1_PATH" ]]; then
  echo "Error: Private key not found at $KEY1_PATH"
  exit 1
fi


# Step 1: Initialize and Build the Packer Image
echo "Initializing Packer..."
packer init packer-configs

echo "Building Image with Packer..."
packer build packer-configs

cd terraform


# Step 2: Generate the public key from the private key
PUBLIC_KEY_PATH="./$(basename ${KEY1_PATH}).pub"
if [[ ! -f "$PUBLIC_KEY_PATH" ]]; then
  echo "Generating public key from private key..."
  ssh-keygen -y -f "$KEY1_PATH" > "$PUBLIC_KEY_PATH"
  echo "Public key generated at ${PUBLIC_KEY_PATH}"
fi


# Step 3: Deploy Infrastructure with Terraform
echo "Initializing Terraform..."
terraform init

echo "Applying Terraform..."
echo "key_path=\"${PUBLIC_KEY_PATH}\"" > terraform.tfvars
terraform apply -auto-approve

# # Step 4: Extract EC2 Private IPs from Terraform Output
# echo "Fetching EC2 Private IPs..."
# terraform output -json ec2_private_ips | jq -r '.[]' > ../ansible/hosts.txt

# Extract Bastion Host IP
echo "Fetching Bastion Host IP..."
BASTION_IP=$(terraform output -raw bastion_ip)

# Step 5: Generate Ansible Inventory
echo "Generating Ansible Inventory..."
echo "[bastion]" > ../ansible/inventory.ini
echo "bastion ansible_host=${BASTION_IP} ansible_user=ubuntu ansible_ssh_private_key_file=${KEY1_PATH}" >> ../ansible/inventory.ini

echo "[ec2_instances]" >> ../ansible/inventory.ini
terraform output -json ubuntu_private_ips | jq -r '.[] | "ec2-\(.) ansible_host=\(.) ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/bastion_key.pem"' >> ../ansible/inventory.ini
terraform output -json al_private_ips | jq -r '.[] | "ec2-\(.) ansible_host=\(.) ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/bastion_key.pem"' >> ../ansible/inventory.ini

cd ..

# Step 6: Run Ansible Playbook from Bastion
echo "Copying Ansible files to Bastion..."
scp -i "${KEY1_PATH}" -o StrictHostKeyChecking=no -r ansible ubuntu@"${BASTION_IP}":~

echo "Running Ansible Playbook from Bastion..."
ssh -i "${KEY1_PATH}" -o StrictHostKeyChecking=no ubuntu@"${BASTION_IP}" "cd ~/ansible && ansible-playbook -i inventory.ini update_docker_disk.yaml"

# Packer + Terrafrm Intro

1. Create a key-pair in aws, say key1. 
2. Create ami using packer. Replace <path-to-key> with the correct path

    ```bash
    packer build -var "ssh_public_key=$(cat <path-to-key>)" amazon-linux-docker.pkr.hcl
    ```

    Eg. 
    ```bash
    packer build -var "ssh_public_key=$(cat ~/.ssh/key1.pub)" amazon-linux-docker.pkr.hcl
    ```
    
    We should see an output like this:
    ![Screenshot Description](screenshots/packer.png)
3. Generate the aws resources using terraform. Replace <key-name> using the correct key-pair name in your aws

    ```bash
    terraform apply -var="key_name=<key-name>" -auto-approve
    ```

    Eg. 
    ```bash
    terraform apply -var="key_name=key1" -auto-approve
    ```

    ![Screenshot Description](screenshots/terraform.png)

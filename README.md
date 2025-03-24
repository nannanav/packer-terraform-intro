# Packer + Terrafrm Intro

1. Create a key-pair in aws, say key1. 
2. Create ami using packer. Replace <path-to-key> with the correct path
    packer build -var "ssh_public_key=$(cat <path-to-key>)" amazon-linux-docker.pkr.hcl
    Eg. packer build -var "ssh_public_key=$(cat ~/.ssh/key1.pub)" amazon-linux-docker.pkr.hcl
    We should see an output like this:
    PFA
3. 


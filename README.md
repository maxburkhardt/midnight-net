# midnight-net

This repo contains tools to automatically set up a practice hacking
environment. It was originally designed for educational hackathons. The goal of
the Midnight Net is to provide a challenge that is based as much as possible in
how real systems are compromised.

## Quick Start
First, you'll need [Terraform](https://www.terraform.io/downloads.html) and
[Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
Install those before proceeding. You'll also need a Python 3 runtime.

Second, create credentials in `credentials/` as per the sample files. For each
sample file, you will need to create a real version without the `.sample`
prefix. For instance, you will need to create an `aws-credentials` file with
actual, working AWS credentials.

Then, run the following sequence of commands:
```
cd terraform
terraform init
terraform apply
cd ../ansible
./apply.sh
```

Note that `terraform init` is only needed the first time you set up a midnight
net.

Once you're done with the environment, cd into the `terraform/` directory, and
run `terraform destroy`. That will clean up all midnight resources and stop
incurring AWS bills.

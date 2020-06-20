# midnight-net

This repo contains tools to automatically set up a practice hacking
environment. It was originally designed for educational hackathons.

## Quick Start
First, create credentials in `credentials/` as per the sample files. For each
sample file, you will need to create a real version without the `.sample`
prefix. For instance, you will need to create an `aws-credentials` file with
actual, working AWS credentials.

Then, run the following sequence of commands:
```
cd terraform
terraform init
terraform apply
cd ../ansible
./load_ips.py
./apply.sh
```

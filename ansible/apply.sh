#!/bin/sh
python load_ips.py
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook midnight.yml -i inventory.ini

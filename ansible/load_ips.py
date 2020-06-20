#!/usr/bin/env python

import json
import subprocess

"""
A script to load the IP addresses of generated midnight net hosts from the
terraform state file and automatically create relevant ansible infrastructure,
such as inventory.ini.
"""

def get_from_terraform():
    state_data = subprocess.check_output(
        ["terraform", "show", "-json", "terraform.tfstate"],
        cwd="../terraform"
    )
    state_parsed = json.loads(state_data)

    ips = {
        "hub_core": state_parsed["values"]["outputs"]["midnight-hub-core-ip"]["value"],
        "hub_west": state_parsed["values"]["outputs"]["midnight-hub-west-ip"]["value"],
        "hub_south": state_parsed["values"]["outputs"]["midnight-hub-south-ip"]["value"]
    }

    return ips

def write_ini_file(ips):
    fh = open("inventory.ini", "w")
    for hubname, ip in ips.items():
        fh.write(f"[{hubname}]\n{ip} ansible_ssh_private_key_file=../credentials/id_rsa\n\n")
    fh.close()

def write_hint_file(ips):
    fh = open("resources/midnight_ips.txt", "w")
    fh.write(f"Brazilian hub: {ips['hub_south']}\n")
    fh.write(f"Core??? {ips['hub_core']}\n")
    fh.close()

if __name__ == "__main__":
    print("Loading IPs from terraform state...")
    ips = get_from_terraform()
    print("Writing inventory.ini...")
    write_ini_file(ips)
    print("Writing midnight_ips.txt...")
    write_hint_file(ips)

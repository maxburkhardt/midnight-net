#!/usr/bin/env python

import json
import uuid
import subprocess
from jinja2 import Template

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
    template_source_fh = open("resources/midnight_notes_template.txt", "r")
    template_source = template_source_fh.read()
    template_source_fh.close()
    fh = open("resources/midnight_notes.txt", "w")
    fh.write(Template(template_source).render(hub_south_ip = ips["hub_south"]))
    fh.close()

def write_known_hosts(ips):
    fh = open("resources/south_known_hosts", "w")
    fh.write(
        f"{ips['hub_core']} ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdH" +
        f"AyNTYAAABBBOh52KovN3+i+TqWQuH8yx4/gxHuW+wo3aAztEI+4jPyUqVTxesQPk7GD/X/gbO3CAsReq" +
        f"B3Ms/slZVDbcAztY4=\n"
    )
    fh.close()

def write_game_key(key):
    fh = open("resources/game_key", "w")
    fh.write(f"Congratulations! Tell the Game Master that you've found the key: {key}\n")
    fh.close()

if __name__ == "__main__":
    print("Loading IPs from terraform state...")
    ips = get_from_terraform()
    print("Writing inventory.ini...")
    write_ini_file(ips)
    print("Writing midnight_notes.txt...")
    write_hint_file(ips)
    print("Writing south_known_hosts...")
    write_known_hosts(ips)
    game_key = uuid.uuid4()
    print(f"The game key for this instance will be {game_key}")
    write_game_key(game_key)

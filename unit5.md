# Unit5 - Firewalls

----
## Part 1 Procedure
Task: enable two machines with ip addresses 10.1.1.1/24 and 10.1.1.2/24 to ssh, ping, traceroute etc.


Using the virtual machine manager, enable an internal network interface.


Using ip or similar, assign an address and subnet to the internal network interface enp0s8

On the first VM:

    ip addr add 10.1.1.1/24 dev enp0s8

On the Second VM:

    ip addr add 10.1.1.2/24 dev enp0s8


If not already installed, install ssh on both machines and view the status of the service on each machine using systemctl.


    sudo apt-get install shh
    systemctl status ssh

Make sure the service is enabled on both machines.


----
## Part 2 Procedure
Task: Enable ssh from the first VM to the second VM but not from the second to the first.

On the first VM:

1. Block all incoming ssh connectivity. Append the iptables entry to the INPUT channel that DROPs any incoming ssh packet over tcp. Alternatively, REJECT the packet and return a "Connection refused" message to the source machine.

    sudo iptables -A INPUT -p tcp --dport ssh -j REJECT

2. Accept incoming ssh packets from 10.1.1.2/24 that are attempting to initiate a new connection or continuing a tcp packet stream using the -m(match) flag.

    sudo iptables -A INPUT -tcp --dport ssh -s 10.1.1.2 -m state --state NEW,ESTABLISHED -j ACCEPT

3. The only ssh packets we should be sending are to continue the existing ssh connection on default port 22.

    sudo iptables -A OUTPUT -p tcp --sport 22 -d 10.1.1.2 -m state --state ESTABLISHED -j ACCEPT

4. Test ssh connection attempts from both machines. Left:10.1.1.2 Right 10.1.1.1 OUTPUT:

![alt text](https://github.com/lu0248/ENGR3821-lu0248/blob/master/unit5-part2-screenshot.png)
% firehol-iptrap(5) FireHOL Reference | VERSION
% FireHOL Team
% Built DATE

# NAME

firehol-iptrap - dynamically put IP addresses in an ipset

<!--
contents-table:helper:iptrap:keyword-firehol-iptrap:4/6:-:Dynamically put IP addresses in an ipset.
  -->

# SYNOPSIS

{ iptrap | iptrap4 | iptrap6 } *ipset* *type* *seconds* [ timeout | counters ] [ method **method** ] [*rule-params*] [ except [*rule-params*] ]...

{ ipuntrap | ipuntrap4 | ipuntrap6 } *ipset* *type* [ timeout | counters ] [ method **method** ] [*rule-params*] [ except [*rule-params*] ]...

<!--
extra-manpage: firehol-iptrap4.5
extra-manpage: firehol-iptrap6.5
extra-manpage: firehol-ipuntrap.5
extra-manpage: firehol-ipuntrap4.5
extra-manpage: firehol-ipuntrap6.5
  -->

# DESCRIPTION


`iptrap` adds the IP addresses of the matching packets to `ipset`.

`ipuntrap` deletes the IP addresses of the matching packets from `ipset`.

Both helpers do not affect the flow of traffic. They do not `ACCEPT`,
`REJECT`, `DROP` packets or affect the firewall in any way.

`ipset` is the name of the ipset to use.

`type` selects which of the IP addresses of the matching packets will be used
(added or removed from the ipset). `type` can be `src`, `dst`, `src,dst`,
`dst,src`, etc. If type is a pair, then the ipset must be an ipset of pairs too.

`seconds` is required by `iptrap` and gives the duration in seconds of the
lifetime of each IP address that is added to `ipset`. Every matching packet
will refresh this duration for the IP address in the ipset.
The Linux kernel will automatically remove the IP from the ipset when this
time expires. The user may monitor the remaining time for each IP, by running
`ipset list NAME` (where `NAME` is the `ipset` parameter given in the `iptrap`
command).

The seconds value `default` will not set any seconds. The ipset default will be
used.

A seconds of `0` (zero), writes to the ipset permanently (this is a feature of
the ipset command, not the ipset FireHOL helper).

The keywords `timeout` and `counters` are mutually exclusive. `timeout` is the
default and means that each IP address every time is matched its timeout will
be refreshed, while `counters` means that its packets and bytes counters will
be refreshed. Unfortunately the kernel either re-add the IP in the ipset
with the new timeout - but its counters will be lost, or just the counters
will be updated, but the timeout will not be refreshed.

`method` is defines the storage method of the underlying ipset. It accepts all
the types the ipset commands accepts.

`method` and `type` should match. For example if method is `hash:ip` then
method should be either `src` or `dst`. If method is `hash:ip,ip` then
method should be either `src,dst` or `dst,src`. If method is `hash:ip,port,ip`
method should be `src,src,dst` or `src,dst,dst` or `dst,src,src` or `dst,dst,src`.
For more information check the manual page of the ipset command.

The *rule-params* define a set of rule parameters to restrict
the traffic that is matched to this helper. See
[firehol-params(5)][] for more details.

`except` *rule-params* are used to exclude traffic, i.e. traffic that normally
is matched by the first set of *rule-params*, will be excluded if matched by
the second.

`iptrap` and `ipuntrap` are hooked on PREROUTING so it is only useful for
incoming traffic.

`iptrap` and `ipuntrap` cannot setup both IPv4 and IPv6 traps with one call.
The reason is that the `ipset` can either be IPv4 or IPv6.

Both helpers will create the `ipset` specified, if that ipset is not already
created by other statements. When the ipset is created by the `iptrap` helper,
the ipset will not be reset (emptied) when the firewall is restarted.

The ipset options used when these helpers create ipsets can be controlled
with the variable IPTRAP_DEFAULT_IPSET_OPTIONS.


# EXAMPLES

~~~~
 # Example: mini-IDS
 # add to the ipset `trap` for an hour (3600 seconds) all IPs from all packets
 # coming from eth0 and going to tcp/3306 (mysql).
 iptrap4 src trap 3600 inface eth0 proto tcp dport 3306 log "TRAPPED HTTP"
 # block them
 blacklist4 full inface eth0 log "BLOCKED" src ipset:trap except src ipset:whitelist

 # Example: ipuntrap
 ipuntrap4 src trap inface eth0 src ipset:trap proto tcp dport 80 log "UNTRAPPED HTTP"

 # Example: a knock
 # The user will be able to knock at tcp/12345
 iptrap4 src knock1 30 inface eth0 proto tcp dport 12345 log "KNOCK STEP 1"
 # in 30 seconds knock at tcp/23456
 iptrap4 src knock2 60 inface eth0 proto tcp dport 23456 src ipset:knock1 log "KNOCK STEP 2"
 # in 60 seconds knock at tcp/34566
 iptrap4 src knock3 90 inface eth0 proto tcp dport 34567 src ipset:knock2 log "KNOCK STEP 3"
 #
 # and in 90 seconds ssh
 interface ...
     server ssh accept src ipset:knock3
~~~~

# SEE ALSO

* [firehol(1)][] - FireHOL program
* [firehol.conf(5)][] - FireHOL configuration
* [FireHOL Website](http://firehol.org/)
* [FireHOL Online PDF Manual](http://firehol.org/firehol-manual.pdf)
* [FireHOL Online Documentation](http://firehol.org/documentation/)

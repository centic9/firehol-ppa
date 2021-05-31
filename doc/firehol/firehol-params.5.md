% firehol-params(5) FireHOL Reference | VERSION
% FireHOL Team
% Built DATE

# NAME

firehol-params - optional rule parameters

<!--
extra-manpage: firehol-src.5
extra-manpage: firehol-src4.5
extra-manpage: firehol-src6.5
extra-manpage: firehol-dst.5
extra-manpage: firehol-dst4.5
extra-manpage: firehol-dst6.5
extra-manpage: firehol-srctype.5
extra-manpage: firehol-dsttype.5
extra-manpage: firehol-dport.5
extra-manpage: firehol-sport.5
extra-manpage: firehol-inface.5
extra-manpage: firehol-outface.5
extra-manpage: firehol-physin.5
extra-manpage: firehol-physout.5
extra-manpage: firehol-custom.5
extra-manpage: firehol-log.5
extra-manpage: firehol-loglimit.5
extra-manpage: firehol-proto.5
extra-manpage: firehol-uid.5
extra-manpage: firehol-gid.5
extra-manpage: firehol-mac-param.5
extra-manpage: firehol-mark-param.5
extra-manpage: firehol-tos-param.5
extra-manpage: firehol-dscp-param.5
extra-manpage: firehol-dport.5
extra-manpage: firehol-sport.5
-->

# SYNOPSIS

_Common_

{ src | src4 | src6 } [not] *host*

{ dst | dst4 | dst6 } [not] *host*

srctype [not] *type*

dsttype [not] *type*

proto [not] *protocol*

mac [not] *macaddr*

dscp [not] *value* *class* *classid*

mark [not] *id*

connmark [not] *id*

custommark [not] *name* *id*

rawmark [not] *id*

tos [not] *id*

custom "*iptables-options*..."

custom-in "*iptables-options*..."

custom-out "*iptables-options*..."

_Router Only_

inface [not] *interface*

outface [not] *interface*

physin [not] *interface*

physout [not] *interface*

_Interface Only_

uid [not] *user*

gid [not] *group*

_Logging_

connlog "log text"

log "log text" [level *loglevel*]

loglimit "log text" [level *loglevel*]

_Helpers Only_

sport *port*

dport *port*

state *state*

ipset [not] name flags [no-counters] [bytes-lt|bytes-eq|bytes-gt|bytes-not-eq *number*] [packets-lt|packets-eq|packets-gt|packets-not-eq *number*] [options *custom-ipset-options*]

limit *limit* *burst*

connlimit upto|above *limit* [mask *mask*] [saddr|daddr]

hashlimit *name* upto|above *amount/period* [burst *amount*] [mode *{srcip|srcport|dstip|dstport},...*] [srcmask *prefix*] [dstmask *prefix*] [htable-size *buckets*] [htable-max *entries*] [htable-expire *msec*] [htable-gcinterval *msec*]

# DESCRIPTION

Optional rule parameters are accepted by many commands to narrow the
match they make. Not all parameters are accepted by all commands so you
should check the individual commands for exclusions.

All matches are made against the REQUEST. FireHOL automatically sets up
the necessary stateful rules to deal with replies in the reverse
direction.

All matches should be true for a statement to be executed. However,
many matches support multiple values. In this case, at least one of the
values must match.

Example:

~~~
server smtp accept src 1.1.1.1 dst 2.2.2.2
~~~

In the above example all smtp requests coming in from 1.1.1.1 and
going out to smtp server 2.2.2.2 will be matched.

~~~
server smtp accept src 1.1.1.1 dst 2.2.2.2,3.3.3.3
~~~

In the above example all smtp requests coming in from 1.1.1.1 and
going out to either smtp server 2.2.2.2 or 3.3.3.3 will be matched.

Use the keyword `not` to match any value other than the one(s) specified.

The logging parameters are unusual in that they do not affect the match,
they just cause a log message to be emitted. Therefore, the logging
parameters don't support the `not` option.

FireHOL is designed so that if you specify a parameter that is also used
internally by the command then a warning will be issued (and the
internal version will be used).

# COMMON

## src, dst

Use `src` and `dst` to define the source and destination IP addresses of
the request respectively. *host* defines the IP or IPs to be matched.

*host* can also refer to an ipset, using this syntax: `ipset:NAME`,
where NAME is the name of the ipset. The ipset has to be of type `hash:ip`
for this match to work. The source IP or the destination IP will be used
for the match, depending if the ipset is given as `src` or `dst`.

IPs and ipsets can be mixed together, like this:
`src 1.1.1.1,ipset:NAME1,2.2.2.2,ipset:NAME2`

Examples:

~~~~
server4 smtp accept src not 192.0.2.1
server4 smtp accept dst 198.51.100.1
server4 smtp accept src not 192.0.2.1 dst 198.51.100.1
server6 smtp accept src not 2001:DB8:1::/64
server6 smtp accept dst 2001:DB8:2::/64
server6 smtp accept src not 2001:DB8:1::/64 dst 2001:DB8:2::/64
~~~~

When attempting to create rules for both IPv4 and IPv6 it is generally
easier to use the `src4`, `src6`, `dst4` and `dst6` pairs:

~~~~
server46 smtp accept src4 192.0.2.1 src6 2001:DB8:1::/64
server46 smtp accept dst4 198.51.100.1 dst6 2001:DB8:2::/64
server46 smtp accept dst4 $d4 dst6 $d6 src4 not $d4 src6 not $s6
~~~~

To keep the rules sane, if one of the 4/6 pair specifies `not`, then so
must the other. If you do not want to use both IPv4 and IPv6 addresses,
you must specify the rule as IPv4 or IPv6 only. It is always possible to
write a second IPv4 or IPv6 only rule.

## srctype, dsttype

Use `srctype` or `dsttype` to define the source or destination IP
address type of the request. *type* is the address type category as used
in the kernel's network stack. It can be one of:

UNSPEC
:   an unspecified address (i.e. 0.0.0.0)

UNICAST
:   a unicast address

LOCAL
:   a local address

BROADCAST
:   a broadcast address

ANYCAST
:   an anycast address

MULTICAST
:   a multicast address

BLACKHOLE
:   a blackhole address

UNREACHABLE
:   an unreachable address

PROHIBIT
:   a prohibited address

THROW; NAT; XRESOLVE
:   undocumented

See iptables(8) or run `iptables -m addrtype --help` for more
information. Examples:

    server smtp accept srctype not "UNREACHABLE PROHIBIT"
        

## proto

Use `proto` to match by protocol. The *protocol* can be any accepted by
iptables(8).

## mac

Use `mac` to match by MAC address. The *macaddr* matches to the "remote"
host. In an `interface`, "remote" always means the non-local host. In a
`router`, "remote" refers to the source of requests for `server`s. It
refers to the destination of requests for `client`s. Examples:

~~~~
 # Only allow pop3 requests to the e6 host
 client pop3 accept mac 00:01:01:00:00:e6

 # Only allow hosts other than e7/e8 to access smtp
 server smtp accept mac not "00:01:01:00:00:e7 00:01:01:00:00:e8"
~~~~
        
## dscp

Use `dscp` to match the DSCP field on packets. For details on DSCP
values and classids, see [firehol-dscp(5)][keyword-firehol-dscp-helper].

~~~~
 server smtp accept dscp not "0x20 0x30"
 server smtp accept dscp not class "BE EF"
~~~~
        

## mark

Use `mark` to match marks set on packets. For details on mark ids, see
[firehol-mark(5)][keyword-firehol-mark-helper].

    server smtp accept mark not "20 55"
        

## tos

Use `tos` to match the TOS field on packets. For details on TOS ids, see
[firehol-tos(5)][keyword-firehol-tos-helper].

    server smtp accept tos not "Maximize-Throughput 0x10"
        

## custom

Use `custom` to pass arguments directly to iptables(8). All of the
parameters must be in a single quoted string. To pass an option to
iptables(8) that itself contains a space you need to quote strings in
the usual bash(1) manner. For example:

~~~~
server smtp accept custom "--some-option some-value"
server smtp accept custom "--some-option 'some-value second-value'"
~~~~


# ROUTER ONLY

## inface, outface

Use `inface` and `outface` to define the *interface* via which a request
is received and forwarded respectively. Use the same format as 
[firehol-interface(5)][keyword-firehol-interface].
Examples:

~~~~
server smtp accept inface not eth0
server smtp accept inface not "eth0 eth1"
server smtp accept inface eth0 outface eth1
~~~~

        
## physin, physout

Use `physin` and `physout` to define the physical *interface* via which a
request is received or send in cases where the inface or outface is
known to be a virtual interface; e.g. a bridge. Use the same format as
[firehol-interface(5)][keyword-firehol-interface]. Examples:

    server smtp accept physin not eth0
        

# INTERFACE ONLY

These parameters match information related to information gathered from
the local host. They apply only to outgoing packets and are silently
ignored for incoming requests and requests that will be forwarded.

> **Note**
>
> The Linux kernel infrastructure to match PID/SID and executable names
> with `pid`, `sid` and `cmd` has been removed so these options can no
> longer be used.

## uid

Use `uid` to match the operating system user sending the traffic. The
*user* is a username, uid number or a quoted list of the two.

For example, to limit which users can access POP3 and IMAP by preventing
replies for certain users from being sent:

    client "pop3 imap" accept user not "user1 user2 user3"
        

Similarly, this will allow all requests to reach the server but prevent
replies unless the web server is running as apache:

    server http accept user apache
        
## gid

Use `gid` to match the operating system group sending the traffic. The
*group* is a group name, gid number or a quoted list of the two.


# LOGGING

## connlog

Use `connlog` to log only the first packet of a connection.

## log, loglimit

Use `log` or `loglimit` to log matching packets to syslog. Unlike
iptables(8) logging, this is not an action: FireHOL will produce
multiple iptables(8) commands to accomplish both the action for the rule
and the logging.

Logging is controlled using the FIREHOL\_LOG\_OPTIONS and
FIREHOL\_LOG\_LEVEL environment variables - see
[firehol-defaults.conf(5)][]. `loglimit`
additionally honours the FIREHOL\_LOG\_FREQUENCY and FIREHOL\_LOG\_BURST
variables.

Specifying `level` (which takes the same values as FIREHOL\_LOG\_LEVEL)
allows you to override the log level for a single rule.


# HELPERS ONLY PARAMETERS

## dport, sport

FireHOL also provides `dport`, `sport` and `limit` which are used
internally and rarely needed within configuration files.

`dport` and `sport` require an argument *port* which can be a name, number,
range (FROM:TO) or a quoted list of ports.

For `dport` *port* specifies the destination port of a request and can be
useful when matching traffic to helper commands (such as nat) where there
is no implicit port.

For `sport` *port* specifies the source port of a request and can be useful
when matching traffic to helper commands (such as nat) where there is no
implicit port.

## limit

`limit` requires the arguments *frequency* and *burst* and will limit the
matching of traffic in both directions.

## connlimit

`connlimit` matches on the number of connections per IP. It has been added
to FireHOL since v3.

*saddr* matches on source IP.
*daddr* matches on destination IP.
*mask* groups IPs with the *mask* given
*upto* matches when the number of connections is up to the given *limit*
*above* matches when the number of connections above to the given *limit*

The number of connections counted are system wide, not service specific.
For example for *saddr*, you cannot connlimit 2 connections for SSH and
4 for SMTP. If you connlimit 2 connections for SSH, then the first 2
connections of a client can be SSH. If a client has already 2 connections
to another service, the client will not be able to connect to SSH.

So, `connlimit` can safely be used:

  - with *daddr* to limit the connections a server can accept
  - with *saddr* to limit the total connections per client to all services.

## hashlimit

`hashlimit` has been added to FireHOL since v3.

`hashlimit` hashlimit uses hash buckets to express a rate limiting match
(like the limit match) for a group of connections using a single iptables
rule. Grouping can be done per-hostgroup (source and/or destination address)
and/or per-port. It gives you the ability to express "N packets per time
quantum per group" or "N bytes per seconds" (see below for some examples).

A hash limit type (`upto`, `above`) and *name* are required.

*name*
The name for the /proc/net/ipt_hashlimit/*name* entry.

`upto` *amount[/second|/minute|/hour|/day]*
Match if the rate is below or equal to amount/quantum. It is specified either
as a number, with an optional time quantum suffix (the default is 3/hour),
or as amountb/second (number of bytes per second).

`above` *amount[/second|/minute|/hour|/day]*
Match if the rate is above amount/quantum.

`burst` *amount*
Maximum initial number of packets to match: this number gets recharged by one
every time the limit specified above is not reached, up to this number; the
default is 5. When byte-based rate matching is requested, this option specifies
the amount of bytes that can exceed the given rate. This option should be used
with caution - if the entry expires, the burst value is reset too.

`mode` *{srcip|srcport|dstip|dstport},...*
A comma-separated list of objects to take into consideration. If no `mode` option
is given, *srcip,dstport* is assumed.

`srcmask` *prefix*
When --hashlimit-mode srcip is used, all source addresses encountered will be
grouped according to the given prefix length and the so-created subnet will be
subject to hashlimit. prefix must be between (inclusive) 0 and 32.
Note that `srcmask` *0* is basically doing the same thing as not specifying
srcip for `mode`, but is technically more expensive.

`dstmask` *prefix*
Like `srcmask`, but for destination addresses.

`htable-size` *buckets*
The number of buckets of the hash table

`htable-max` *entries*
Maximum entries in the hash.

`htable-expire` *msec*
After how many milliseconds do hash entries expire.

`htable-gcinterval` *msec*
How many milliseconds between garbage collection intervals.

Examples:

matching on source host: "1000 packets per second for every host in 192.168.0.0/16"

~~~~
src 192.168.0.0/16 hashlimit mylimit mode srcip upto 1000/sec
~~~~

matching on source port: "100 packets per second for every service of 192.168.1.1"

~~~~
src 192.168.1.1 hashlimit mylimit mode srcport upto 100/sec
~~~~

matching on subnet: "10000 packets per minute for every /28 subnet (groups of 8 addresses) in 10.0.0.0/8"

~~~~
src 10.0.0.8 hashlimit mylimit mask 28 upto 10000/min
~~~~

matching bytes per second: "flows exceeding 512kbyte/s"

~~~~
hashlimit mylimit mode srcip,dstip,srcport,dstport above 512kb/s
~~~~

matching bytes per second: "hosts that exceed 512kbyte/s, but permit up to 1Megabytes without matching"

~~~~
hashlimit mylimit mode dstip above 512kb/s burst 1mb
~~~~


# SEE ALSO

* [firehol(1)][] - FireHOL program
* [firehol.conf(5)][] - FireHOL configuration
* [firehol-server(5)][keyword-firehol-server] - server, route commands
* [firehol-client(5)][keyword-firehol-client] - client command
* [firehol-interface(5)][keyword-firehol-interface] - interface definition
* [firehol-router(5)][keyword-firehol-router] - router definition
* [firehol-mark(5)][keyword-firehol-mark-helper] - mark config helper
* [firehol-tos(5)][keyword-firehol-tos-helper] - tos config helper
* [firehol-dscp(5)][keyword-firehol-dscp-helper] - dscp config helper
* [firehol-defaults.conf(5)][] - control variables
* [iptables(8)](http://ipset.netfilter.org/iptables.man.html) - administration tool for IPv4 firewalls
* [ip6tables(8)](http://ipset.netfilter.org/ip6tables.man.html) - administration tool for IPv6 firewalls
* [FireHOL Website](http://firehol.org/)
* [FireHOL Online PDF Manual](http://firehol.org/firehol-manual.pdf)
* [FireHOL Online Documentation](http://firehol.org/documentation/)

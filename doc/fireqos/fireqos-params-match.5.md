% fireqos-params-match(5) FireQOS Reference | VERSION
% FireHOL Team
% Built DATE

# NAME

fireqos-params-match - optional match parameters

<!--
extra-manpage: fireqos-match-params.5
extra-manpage: fireqos-at.5
extra-manpage: fireqos-syn.5
extra-manpage: fireqos-syns.5
extra-manpage: fireqos-ack.5
extra-manpage: fireqos-acks.5
extra-manpage: fireqos-proto.5
extra-manpage: fireqos-protocol.5
extra-manpage: fireqos-tcp.5
extra-manpage: fireqos-udp.5
extra-manpage: fireqos-icmp.5
extra-manpage: fireqos-gre.5
extra-manpage: fireqos-ipv6.5
extra-manpage: fireqos-tos.5
extra-manpage: fireqos-dscp.5
extra-manpage: fireqos-priority.5
extra-manpage: fireqos-mark.5
extra-manpage: fireqos-port.5
extra-manpage: fireqos-ports.5
extra-manpage: fireqos-sport.5
extra-manpage: fireqos-sports.5
extra-manpage: fireqos-dport.5
extra-manpage: fireqos-dports.5
extra-manpage: fireqos-ip.5
extra-manpage: fireqos-net.5
extra-manpage: fireqos-host.5
extra-manpage: fireqos-src.5
extra-manpage: fireqos-dst.5
extra-manpage: fireqos-prio.5
extra-manpage: fireqos-insidegre.5
  -->

# SYNOPSIS

at { root | *name* }

class *name*

syn|syns

ack|acks

{ proto|protocol *protocol* [,*protocol*...] } |tcp|udp|icmp|gre|ipv6

{ tos | priority } *tosid* [,*tosid*...]

{ DSCP } *classname* [,*classname*...]

mark *mark* [,*mark*...]

connmark *mark* [,*mark*...]

rawmark *mark* [,*mark*...]

custommark *name* *mark* [,*mark*...]

{ port | ports } *port*[:*range*] [ ,*port*[:*range*]... ]

{ sport | sports } *port*[:*range*] [ ,*port*[:*range*]... ]

{ dport | dports } *port*[:*range*] [ ,*port*[:*range*]... ]

{ ip | net | host } *net* [,*net*...]

src *net* [,*net*...]

dst *net* [,*net*...]

{ srcmac | smac } *mac*

{ dstmac | dmac } *mac*

prio *id*

input

output

custom '*custom tc parameters*'

estimator *interval* *decay*

police *police*

insidegre

# DESCRIPTION

These options apply to `match` statements.

## input, output

On `bidirectional` interfaces, `input` and `output` will check the
current direction of the interface. If the match is `input` but the
interface is `output` the match will be reversed. The same will happen
if `output` is given at the match and the interface is `input`.

The parameters that are reversed are:

* `src` and `dst`
* `sport` and `dport`
* `srcmac` and `dstmac`

This allows a definition like this:

~~~~
  interface dsl0 world bidirectional ...
    class surfing ...
      match input sport 0:1023
~~~~

The above will match `sport 0:1023` at the `input` interface, and will
automatically reverse it to match `dport 0:1023` at the `output` interface.


## at

By default a `match` is attached to the parent of its parent class.
For example, if its parent is a class directly under the interface,
then the `match` is attached to the interface and is compared
against all traffic of the interface. For nested classes, a `match`
of a leaf, is attached to the parent class and is compared against
all traffic of this parent class.

With the `at` parameter, a `match` can be attached any class. The
*name* parameter should be a class name. The name `root` attaches the
`match` to the interface.

## class

Defines the *name* of the class that will get the packets matched by
this `match`.

By default it is the name of the class the `match` statement appears
under.

> *Note*
>
> There is also a `class` definition for traffic, see
> [fireqos-class(5)][keyword-fireqos-class-definition].

## syn, syns

Match TCP SYN packets. Note that the `tcp` parameter must be specified.

If the same match statement includes more protocols than TCP, then
this match will work for the TCP packets (it will be silently
ignored for all other protocols).

For example, syn is ignored when generating the UDP filter in the
below:

~~~~
match tcp syn
match proto tcp,udp syn
~~~~

## ack, acks

Same as `syn`, but matching small TCP packets with the ACK bit set.

## proto, protocol, tcp, udp, icmp, gre, ipv6

Match the *protocol* in the IP header.

## tos, priority

Match to TOS field of ipv4 or the priority field of ipv6. The
*tosid* can be a value/mask in any format tc(8) accepts, or one of
the following:

* min-delay, minimize-delay, minimum-delay, low-delay, interactive
* maximize-throughput, maximum-throughput, max-throughput, high-throughput,
  bulk
* maximize-reliability, maximum-reliability, max-reliability, reliable
* min-cost, minimize-cost, minimum-cost, low-cost, cheap, normal-service,
  normal

> *Note*
>
> There is also a class parameter called `priority`, see
> [fireqos-params-class(5)][keyword-fireqos-priority-class].

## dscp

Match to DSCP value in IP TOS header field. The *classname* has to be one of
the following values:

* CS1, CS2, CS3, CS4, CS5, CS6, CS7
* AF11, AF12, AF13
* AF21, AF22, AF23
* AF31, AF32, AF33
* AF41, AF42, AF43
* EF

> *Note*
>
> tc-filter only supports ToS parameters. That is why a lookaside table
> is configured within fireqos code to translate the DSCP value to their
> matching TOS value. See RFC2474 for more information.

## mark, connmark, custommark, rawmark

Match an iptables(8) MARK. This works the same way it works for
FireHOL. FireHOL and FireQOS share the same marks and their masks.

Matching iptables(8) MARKs do not work on
input interfaces. You can use them only on output. The IFB devices
that are used for shaping inbound traffic do not have any iptables
hooks to allow matching MARKs. If you try it, FireQOS will attempt
to do it, but currently you will get an error from the tc(8) command
executed or they will be silently ignored by it.

On openwrt there is a module called `act_commark` that will enable
this feature.

## ports, sports, dports

Match ports of the IP header. `ports` will create rules for matching
source and destination ports (separate rules for each). `dports`
matches destination ports, `sports` matches source ports.

## ip, net, host, src, dst

Match IPs of the IP header. `ip`, `net` and `host` will create rules
for matching source and destination IPs (separate rules for each).
`src` matches source IPs and `dst` destination IPs.

> **Note**
>
> If the class these matches appear in are IPv4, then only IPv4 IPs
> can be used. To override use `match6 ... src/dst *IPV6_IP*`
>
> Similarly, if the class is IPv6, then only IPv6 IPs can be used.
> To override use `match4 ... src/dst *IPV4_IP*`.

You can mix IPv4 and IPv6 in any way you like. FireQOS supports
inheritance, to figure out for each statement which is the
default. For example:

~~~~
interface46 eth0 lan output rate 1Gbit # ipv4 and ipv6 enabled
  class voip # ipv4 and ipv6 class, as interface is both
    match udp port 53 # ipv4 and ipv6 rule, as class is both
    match4 src 192.0.2.1 # ipv4 only rule
    match6 src 2001:db8::1 # ipv6 only rule

  class4 realtime # ipv4 only class
    match src 198.51.100.1 # ipv4 only rule, as class is ipv4-only

  class6 servers # ipv6 only class
        match src 2001:db8::2 # ipv6 only rule, as class is ipv6-only
~~~~

To convert an IPv4 interface to IPv6, just replace `interface`
with `interface6`. All the rules in that interface, will
automatically inherit the new protocol. Of course, if you use IP
addresses for matching packets, make sure they are IPv6 IPs too.

## prio (match)

> *Note*
>
> There is also a class parameter called `prio`, see
> [fireqos-params-class(5)][keyword-fireqos-prio-class].

All match statements are attached to the interface. They forward
traffic to their class, but they are actually executed for all
packets that are leaving the interface (note: input matches are
actually output matches on an IFB device).

By default, the priority they are executed, is the priority they
appear in the configuration file, i.e. the first match of the first
class is executed first, then the rest matches of the first class in
the sequence they appear, then the matches of the second class, etc.

It is sometimes necessary to control the order of matches. For
example, when you want host 192.0.2.1 to be assigned the first
class, except port tcp/1234 which should be assigned the second
class. The following will *not* work:

~~~~
interface eth0 lan output rate 1Gbit
  class high
    match host 192.0.2.1

  class low
    match host 192.0.2.1 port 1234 # Will never match
~~~~

In this case, the first match is assigned priority 10 and the second
priority 20. The second match will never match anything, since all
traffic for the host is already matched by the first one.

Setting an explicit priority allows you to change the order in which
the matches are executed. FireQOS gives priority 10 to the first
match of every interface, 20 to the second match, 30 to the third
match, etc. So the default is 10 x the sequence number. You can set
`prio` to overwrite this number.

To force executing the second match before the first, just set a
lower priority for it. For example, this will cause the desired
behaviour:

~~~~
interface eth0 lan output rate 1Gbit
  class high
    match host 192.0.2.1

  class low
    match host 192.0.2.1 port 1234 prio 1 # Matches before host-only
~~~~

## insidegre

By specifying keyword `insidegre` a GRE (Generic Routing Encapsulation)
packet can be matched on the encapsulated IP packet header information.

`insidegre` is available for the following matches:

* src
* dst
* protocol
* port
* tos
* dscp

~~~~
  interface eth0 world ...
    class surfing commit 128kbit ceil 1024kbit prio 7
      match src 10.1.128.230 dst 8.8.8.8 insidegre
      match protocol ospf insidegre
      match port 25 insidegre
      match tos 3 insidegre
      match dscp ef insidegre
~~~~

# SEE ALSO

* [fireqos(1)][] - FireQOS program
* [fireqos.conf(5)][] - FireQOS configuration file
* [fireqos-match(5)][keyword-fireqos-match] - QOS traffic match
* [FireHOL Website](http://firehol.org/)
* [FireQOS Online PDF Manual](http://firehol.org/fireqos-manual.pdf)
* [FireQOS Online Documentation](http://firehol.org/documentation/)

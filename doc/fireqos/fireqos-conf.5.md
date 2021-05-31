% fireqos.conf(5) FireQOS Reference | VERSION
% FireHOL Team
% Built DATE

# NAME

fireqos.conf - FireQOS configuration file

<!--
extra-manpage: fireqos.conf.5
  -->

# DESCRIPTION

This file defines the traffic shaping that will be applied by
[fireqos(1)][].

The default configuration file is `/etc/firehol/fireqos.conf`. It can be
overridden from the command line.

A configuration consists of a number of input and output `interface`
definitions (see [fireqos-interface(5)][keyword-fireqos-interface]).
Each `interface` can define any number of (optionally nested)
`class`es (see [fireqos-class(5)][keyword-fireqos-class-definition])
which shape the traffic which they `match`
(see [fireqos-match(5)][keyword-fireqos-match]).

# SPEED UNITS

In FireQOS, speeds can be expressed in the following units:

\#`bps`
:   \# bytes per second

\#`kbps`; \#`Kbps`
:   \# kilobytes per second

\#`mbps`; \#`Mbps`
:   \# megabytes per second

\#`gbps`; \#`Gbps`
:   \# gigabytes per second

\#`bit`
:   \# bits per second

\#`kbit`; \#`Kbit`; \#
:   \# kilobits per second (default)

\#`mbit`; \#`Mbit`
:   \# megabits per second

\#`gbit`; \#`Gbit`
:   \# gigabits per second

\#`%`
:   In a `class`, uses this percentage of the enclosing `rate`.

> **Note**
>
> The default, `kbit` is different to tc(8) which assumes bytes per
> second when no unit is specified.

# EXAMPLE

This example uses match statements.

~~~~

 # incoming traffic from my ADSL router
 interface eth2 adsl-in input rate 10500kbit adsl remote pppoe-llc
   class voip commit 100kbit pfifo
     match udp ports 5060,10000:10100 # asterisk sip and rtp
     match udp ports 16393:16402 # apple facetime

   class realtime commit 10%
     match tcp port 22,1195:1198,1753 # ssh, openvpn, pptp
     match udp port 53 # dns
     match proto GRE
     match icmp
     match tcp syn
     match tcp ack

   class clients commit 10%
     match tcp port 20,21,25,80,143,443,465,873,993 # mail, web, ftp, etc

 # unmatched traffic goes here ('default' is a special name)
   class default max 90%

 # I define torrents beneath the default class, so they slow
 # down when the default class is willing to get bandwidth
   class torrents max 90%
     match port 51414 # my torrent client

 # outgoing traffic to my ADSL router
 interface eth2 adsl-out output rate 800kbit adsl remote pppoe-llc
   class voip commit 100kbit pfifo
     match udp ports 5060,10000:10100 # asterisk sip and rtp
     match udp ports 16393:16402 # apple facetime

   class realtime commit 10%
     match tcp port 22,1195:1198,1753 # ssh, openvpn, pptp
     match udp port 53 # dns
     match proto GRE
     match icmp
     match tcp syn
     match tcp ack

   class clients commit 10%
     match tcp port 20,21,25,80,143,443,465,873,993 # mail, web, ftp, etc

 # unmatched traffic goes here ('default' is a special name)
   class default max 90%

 # I define torrents beneath the default class, so they slow
 # down when the default class is willing to get bandwidth
   class torrents max 90%
     match port 51414 # my torrent client
~~~~

This example uses server/client statements in a bidirectional interface.
Of course match statements can also be specified.
FireQOS will create 2 interfaces out of this: world-in and world-out.

~~~~
  DEVICE=dsl0
  INPUT_SPEED="12000kbit"
  OUTPUT_SPEED="800kbit"
  LINKTYPE="adsl local pppoe-llc"

  # a few service definitions
  # all the rest that are used in this example
  # are defined by FireQOS
  server_netdata_ports="tcp/19999"
  server_rtp_ports="udp/10000:10100"
  server_openvpn_ports="any/1195:1198"
  server_mytorrent_ports="any/60000"
  server_mytorrenttransfers_ports="any/60001:64999"
  server_myssh_ports="tcp/2222"

  # League Of Legends game (yes! I have kids)
  server_lol_ports="udp/5000:5500 tcp/8393:8400,2099,5223,5222,8088"
  
  interface $DEVICE world bidirectional $LINKTYPE input rate $INPUT_SPEED output rate $OUTPUT_SPEED
    
    class voip commit 100kbit pfifo
      server sip
      client sip
      server rtp
      client stun

    class interactive input commit 20% output commit 10%
      server icmp limit 50%

      server dns
      client dns

      server ssh
      client ssh

      server myssh
      client myssh

      client teamviewer
      client lol

    class chat input commit 1000kbit output commit 30%
      client facetime

      server hangouts
      client hangouts

      client gtalk
      client jabber

    class vpns input commit 20% output commit 30%
      server pptp
      server GRE
      server openvpn

    class servers
      server netdata
      server http

    # a class group to favor tcp handshake over transfers
    class group surfing prio keep commit 5%
      client surfing
      client rsync

      class synacks
        match tcp syn
        match tcp ack

    class group end

    class synacks commit 5%
      match tcp syn
      match tcp ack

    class default

    class background commit 4%
      client torrents
      server mytorrent
      server mytorrenttransfers
~~~~

      
# SEE ALSO

* [fireqos(1)][] - FireQOS program
* [fireqos-interface(5)][keyword-fireqos-interface] - QOS interface definition
* [fireqos-class(5)][keyword-fireqos-class-definition] - QOS class definition
* [fireqos-match(5)][keyword-fireqos-match] - QOS traffic match
* [FireHOL Website](http://firehol.org/)
* [FireQOS Online PDF Manual](http://firehol.org/fireqos-manual.pdf)
* [FireQOS Online Documentation](http://firehol.org/documentation/)
* [tc(8)](http://lartc.org/manpages/tc.html) - show / manipulate traffic control settings

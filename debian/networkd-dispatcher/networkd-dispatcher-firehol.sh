#!/bin/bash

#####################################################################
## Purpose
# This file is executed by ifupdown in {pre,post}-{up,down} phases
# of network interface configuration. It allows ifup(8) and ifdown(8)
# to pre-load and post-load FireHOL firewalls provided that
# START_FIREHOL is set to AUTO (or auto) in /etc/default/firehol .
#
# /etc/default/firehol is sourced by this file.
#
# This file is provided by the firehol package.

#####################################################################
# Copyright (C) 2024 Jerome Benoit <calculus@debian.org>
#
# This package is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This package is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this package. If not, see <http://www.gnu.org/licenses/>.
#
# On Debian systems, the complete text of the GNU General
# Public License version 2 can be found in "/usr/share/common-licenses/GPL-2".


DAEMON=/usr/sbin/firehol
NAME="firehol"
DESC="Firewall"

test -x $DAEMON || exit 0

if [ -n "$IF_NETWORKD_FIREHOL_MAINT_DEBUG" ]; then
	if [ -z "$STATE" ]; then
		case $(dirname "$0") in
			*/routable.d)
			    STATE=routable;
			    ;;
			*/off.d)
			    STATE=off;
			    ;;
			*)
			    STATE=unexpected;
			    ;;
		esac
	fi
	export STATE
	set -x
fi

[ "$IFACE" != "lo" ] || exit 0

set -e

START_FIREHOL=NO
export START_FIREHOL
if [ -r /etc/default/firehol ]; then
	if [ -o allexport ]; then
		source /etc/default/firehol
	else
		set -a
		source /etc/default/firehol
		set +a
	fi
fi
case "$START_FIREHOL" in
	AUTO|auto) ;;
	*) exit 0 ;;
esac

nwdd_firehol_do_forceload () {
	/usr/sbin/firehol start > /dev/null 2>&1
	}

nwdd_firehol_do_forcestop () {
	/usr/sbin/firehol stop > /dev/null 2>&1
	}

case "$STATE" in
	routable)
		nwdd_firehol_do_forceload
		;;
	off)
		if $(grep -sqm1 '#.*\<NETWORKD_COMPATIBLE_FIREHOL_CONFIG_FILE\>' /etc/firehol/firehol.conf)
		then
			nwdd_firehol_do_forceload
		else
			nwdd_firehol_do_forcestop
		fi
		;;
	*)
		echo "$0: unexpected STATE [$STATE]" >&2
		exit 1
		;;
esac

exit 0

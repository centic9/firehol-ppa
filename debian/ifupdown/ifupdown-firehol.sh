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

if [ -n "$IF_IFUPDOWN_FIREHOL_MAINT_DEBUG" ]; then
	if [ -z "$MODE" -o -z "$PHASE" ]; then
		case $(dirname "$0") in
			*/if-pre-up.d)
					PHASE=pre-up;
			    MODE=start;
			    ;;
			*/if-up.d)
					PHASE=up;
			    MODE=start;
			    ;;
			*/if-down.d)
					PHASE=down;
			    MODE=stop;
			    ;;
			*/if-post-down.d)
					PHASE=post-down;
			    MODE=stop;
			    ;;
		esac
	fi
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

ifud_firehol_do_forceload () {
	/usr/sbin/firehol start > /dev/null 2>&1
	}

ifud_firehol_do_forcestop () {
	/usr/sbin/firehol stop > /dev/null 2>&1
	}

case "$MODE" in
	start)
		ifud_firehol_do_forceload
		;;
	stop)
		if $(grep -sqm1 '#.*\<IFUPDOWN_COMPATIBLE_FIREHOL_CONFIG_FILE\>' /etc/firehol/firehol.conf)
		then
			ifud_firehol_do_forceload
		else
			ifud_firehol_do_forcestop
		fi
		;;
	*)
		echo "$0: unkexpected MODE [$MODE]" >&2
		exit 1
		;;
esac

exit 0

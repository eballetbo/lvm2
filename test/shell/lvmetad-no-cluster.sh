#!/bin/sh
# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions
# of the GNU General Public License v.2.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

SKIP_WITH_LVMLOCKD=1
SKIP_WITHOUT_CLVMD=1
SKIP_WITH_LVMPOLLD=1

. lib/inittest

aux prepare_vg 2
aux prepare_lvmetad
vgs 2>&1 | tee out
grep "WARNING: Not using lvmetad because locking_type is 3" out

vgremove -ff $vg

#!/bin/sh
# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions
# of the GNU General Public License v.2.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

# unrelated to lvm2 daemons
SKIP_WITH_LVMLOCKD=1
SKIP_WITH_LVMPOLLD=1
SKIP_WITH_CLVMD=1
SKIP_WITH_LVMETAD=1

. lib/inittest

LOOP="/dev/loop"

for i in 0 1 2 3; do
	[ -b /dev/loop${i} ] || skip "test requires /dev/loop${i}"
done;

# some constants
UUID_A="457f0e3b-dc4b-4d39-81d4-2423a8ec0fa3"
UUID_B="34e08a5b-8108-4939-b7e8-ba90b0b7d767"
TABLES_A="0 2097152 linear ${LOOP}0 0, 2097152 2097152 linear ${LOOP}1 0"
TABLES_B="0 2097152 linear ${LOOP}2 0, 2097152 2097152 linear ${LOOP}3 0"

# test create/remove a single device
dmsetup create --bootformat "test-linear-small,${UUID_A},rw,${TABLES_A}"
dmsetup remove test-linear-small

# test create/remove multiple devices
dmsetup create --bootformat "test-linear-small,${UUID_A},rw,${TABLES_A};test-linear-large,${UUID_B},rw,${TABLES_B}"
dmsetup remove test-linear-small test-linear-large

# test empty fields
dmsetup create --bootformat "test-linear-small,,,${TABLES_A}"
dmsetup remove test-linear-small

# test flags options (rw | ro | <empty>)
# flag : rw
dmsetup create --bootformat "test-linear-small,${UUID_A},rw,${TABLES_A}"
# check that READ-ONLY string is not in State line
str=`dmsetup info test-linear-small | grep 'State:'`
test "${str#*READ-ONLY}" == "$str"
dmsetup remove test-linear-small
# flag : ro
dmsetup create --bootformat "test-linear-small,${UUID_A},ro,${TABLES_A}"
# check that READ-ONLY string is in State line
str=`dmsetup info test-linear-small | grep 'State:'`
test "${str#*READ-ONLY}" != "$str"
dmsetup remove test-linear-small
# flag : <emtpy>
dmsetup create --bootformat "test-linear-small,${UUID_A},,${TABLES_A}"
# check that READ-ONLY string is in State line
str=`dmsetup info test-linear-small | grep 'State:'`
test "${str#*READ-ONLY}" != "$str"
dmsetup remove test-linear-small

# let's try some scaped names
declare -A escaped_names=(
    ["test,linear,small"]="test\,linear\,small"
    [",test,,linear,"]="\,test\,\,linear\,"
    ["test;linear;small"]="test\;linear\;small"
    [";test;;linear;"]="\;test\;\;linear\;"
    [";test,linear;small,"]="\;test\,linear\;small\,"
)

for name in "${!escaped_names[@]}"
do
    dmsetup create --bootformat "${escaped_names[$name]},,ro,${TABLES_A}"
    dmsetup remove "${name}"
done

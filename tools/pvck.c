/*
 * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 * Copyright (C) 2007 Red Hat, Inc. All rights reserved.
 *
 * This file is part of LVM2.
 *
 * This copyrighted material is made available to anyone wishing to use,
 * modify, copy, or redistribute it subject to the terms and conditions
 * of the GNU Lesser General Public License v.2.1.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#include "tools.h"

int pvck(struct cmd_context *cmd, int argc, char **argv)
{
	int i;
	int ret_max = ECMD_PROCESSED;

	/* FIXME: validate cmdline options */
	/* FIXME: what does the cmdline look like? */

	/*
	 * Use what's on the cmdline directly, and avoid calling into
	 * some of the other infrastructure functions, so as to avoid
	 * hitting some of the lvmcache behavior, scanning other devices,
	 * etc.
	 */
	for (i = 0; i < argc; i++) {
		/* FIXME: warning and/or check if in use? */
		log_verbose("Scanning %s", argv[i]);

		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
		if (!pv_analyze(cmd, argv[i],
				arg_uint64_value(cmd, labelsector_ARG, UINT64_C(0)))) {
			stack;
			ret_max = ECMD_FAILED;
		}
	}

	return ret_max;
}

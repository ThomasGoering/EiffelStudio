/*
	description: "Routines for runtime initialization."
	date:		"$Date$"
	revision:	"$Revision$"
	copyright:	"Copyright (c) 1985-2006, Eiffel Software."
	license:	"GPL version 2 see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options:	"Commercial license is available at http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Runtime.
			
			Eiffel Software's Runtime is free software; you can
			redistribute it and/or modify it under the terms of the
			GNU General Public License as published by the Free
			Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).
			
			Eiffel Software's Runtime is distributed in the hope
			that it will be useful,	but WITHOUT ANY WARRANTY;
			without even the implied warranty of MERCHANTABILITY
			or FITNESS FOR A PARTICULAR PURPOSE.
			See the	GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Runtime; if not,
			write to the Free Software Foundation, Inc.,
			51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA
		]"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"
*/

#ifndef _rt_main_h_
#define _rt_main_h_
#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include "eif_main.h"
#include "rt_threads.h"

#ifdef __cplusplus
extern "C" {
#endif

#if defined(WORKBENCH) || defined (EIF_THREADS)
extern BODY_INDEX * EIF_once_indexes; /* Code indexes of registered once routines */
#endif

#ifdef EIF_THREADS
extern BODY_INDEX * EIF_process_once_indexes; /* Code indexes of registered process-relative once routines */
#endif

extern void once_init (void);		/* Initialization and creation of once keys */
extern char dinterrupt(void);
extern void dserver(void);
extern void dnotify(int, rt_uint_ptr, rt_uint_ptr);
extern int eif_no_reclaim;		/* Call reclaim ion termination? */
extern int cc_for_speed;		/* Optimized for speed or for memory */
extern char *starting_working_directory;

extern int debug_mode;
extern int catcall_detection_mode;
extern unsigned TIMEOUT;		/* Time out on reads */

#ifdef EIF_WINDOWS
/* Console management for Windows */
extern void eif_console_cleanup (EIF_BOOLEAN);
extern void eif_show_console (void);					/* Show the DOS console if needed */
#ifdef EIF_THREADS
extern EIF_CS_TYPE *eif_console_mutex;
#endif
#endif

extern void dexit(int);

#ifdef __cplusplus
}
#endif

#endif

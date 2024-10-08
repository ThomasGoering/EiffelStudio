/*
	description: "Private data structures and functions used by debugger."
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

#ifndef _rt_debug_h_
#define _rt_debug_h_
#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#include "eif_debug.h"

#ifdef __cplusplus
extern "C" {
#endif

#ifdef WORKBENCH
#ifndef EIF_THREADS
extern struct pgcontext d_cxt;		/* Program context */
extern struct dbstack db_stack;		/* Calling context stack */
#else
extern void dnotify_create_thread(EIF_THR_TYPE); 					/* Notify the debuggeR a new Eiffel thread was created */
extern void dnotify_exit_thread(EIF_THR_TYPE); 						/* Notify the debuggeR an Eiffel thread exited */
extern void dnotify_register_scoop_processor(EIF_THR_TYPE,uint32);  /* Notify the debuggeR a SCOOP processor was registered on thread id */

extern EIF_THR_TYPE dbg_thread_id;		/* Current Thread identifier for debugging session. */
#define REGISTER_DBG_THREAD_ID(t)	dbg_thread_id = t
#define IS_REGISTERED_DBG_THREAD_ID(t)	(dbg_thread_id == 0 || dbg_thread_id == t)
#endif
extern void dcatcall(int a_arg_position, EIF_TYPE a_expected_dftype, EIF_TYPE a_actual_dftype);
#endif

extern uint32 critical_stack_depth;
extern int already_warned;
extern char *dview(EIF_REFERENCE root);
extern void set_breakpoint_count(int num);

extern void debug_initialize(void);
extern void dbreak_free_table(void);
extern void dbreak(int why, int wait);		/* Program execution stopped */
extern void safe_dbreak(int why);	/* Program execution stopped. Before calling this method, you should get the DBGMTX_LOCK*/

/* Notification event types */
#define THR_CREATED				1		/* thread created */
#define THR_EXITED				2		/* thread exited  */
#define SCP_PROC_REGISTERED		4		/* SCOOP Processor registered */

#define clocnum exvect->ex_locnum
#define cargnum exvect->ex_argnum
#define cresult eif_c_opstack_i_th(&cop_stack, start + clocnum + cargnum + 1)
#define cloc(x) eif_c_opstack_i_th(&cop_stack, start + clocnum - (x))
#define carg(x) eif_c_opstack_i_th(&cop_stack, start + clocnum + cargnum + 1 - (x))
#define ccurrent eif_c_opstack_i_th(&cop_stack, start + clocnum)

#ifdef __cplusplus
}
#endif

#endif

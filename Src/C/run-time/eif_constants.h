/*
	description: "Constants used in global variable definitions."
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

#ifndef _eif_constants_h_
#define _eif_constants_h_
#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

#ifdef __cplusplus
extern "C" {
#endif

	/*---------*/
	/* sig.c */
	/*---------*/
/* Make sure EIF_NSIG is defined. If not, set it to 32 (cross your fingers)--RAM */
#ifndef NSIG
#ifdef EIF_WINDOWS
#define EIF_NSIG 23
#else	/* EIF_WINDOWS */
#define EIF_NSIG 32		/* Number of signals (access from 1 to EIF_NSIG-1) */
#endif /* EIF_WINDOWS */
#else	/* !NSIG */

#ifdef EIF_LINUXTHREADS
#define EIF_NSIG	32	/* In MT-mode, it is better not to deal 
						 * with signals above 32. */
#else	/* EIF_THREADS */
#define	EIF_NSIG	NSIG	/* EIF_NSIG is NSIG in a single threaded runtime. */
#endif	/* EIF_THREADS */

#endif	/* !NSIG */

#define SIGSTACK	200		/* Size of FIFO stack for signal buffering */

	/*------------*/
	/*  except.h  */
	/*------------*/
#define EN_NEX		31			/* Number of internal exceptions */

	/*-------------*/
 	/*  pattern.c  */
	/*-------------*/
#define ASIZE 256     /* The alphabet's size */


	/*---------*/
	/*  out.c  */
	/*---------*/
#define TAG_SIZE 512  /* Maximum size for a single tagged expression */

	/*------------*/
	/*  string.c  */
	/*------------*/
#define	MAX_NUM_LEN	256	/* Maximum length for an ASCII number. */


#ifdef __cplusplus
}
#endif

#endif	/* _eif_constants_h_ */

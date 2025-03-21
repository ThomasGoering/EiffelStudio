/*
indexing
	description: "Comparer using ReferenceEquals. Mostly used for having a set of objects using the .NET Hashtable."
	date: "$Date$"
	revision: "$Revision$"
	copyright:	"Copyright (c) 1984-2006, Eiffel Software"
	license:	"GPL version 2 see http://www.eiffel.com/licensing/gpl.txt"
	licensing_options:	"http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Eiffel Development Environment.
			
			Eiffel Software's Eiffel Development Environment is free
			software; you can redistribute it and/or modify it under
			the terms of the GNU General Public License as published
			by the Free Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).
			
			Eiffel Software's Eiffel Development Environment is
			distributed in the hope that it will be useful,	but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the	GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA
		]"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"

*/
	
using System;
using System.Collections;
using System.Runtime.CompilerServices;

namespace EiffelSoftware.Runtime {

[System.Runtime.InteropServices.ComVisibleAttribute (false)]
public class RT_REFERENCE_COMPARER : IEqualityComparer {
/*
feature -- Comparison
*/
	public new bool Equals (object a, object b) { 
		return a == b;
	}

	public int GetHashCode(object obj)
		// Provide the default implementation of GetHashCode for all objects
		// to avoid there is no side effects of calling `GetHashCode'. See eweasel
		// test#store001 where such as side effect of marking objects would trigger
		// the `hash_code' computation of the STRING class.
	{
		return RuntimeHelpers.GetHashCode(obj);
	}

}

}


/*
indexing
	description: "Attribute to record a class type mark in the metadata."
	date: "$Date$"
	revision: "$Revision$"
	copyright:	"Copyright (c) 2007, Eiffel Software"
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
using EiffelSoftware.Runtime.Enums;

namespace EiffelSoftware.Runtime.CA
{

[AttributeUsage (AttributeTargets.Class, AllowMultiple = false, Inherited = false)]
[Serializable]
public class EIFFEL_CLASS_TYPE_MARK_ATTRIBUTE : Attribute
{
/*
feature -- Initialization
*/
	public EIFFEL_CLASS_TYPE_MARK_ATTRIBUTE (CLASS_TYPE_MARK_ENUM value)
	{
		mark = value;
	}

/*
feature -- Access
*/
	internal CLASS_TYPE_MARK_ENUM mark;
		// Mark of the class type.

}

} // class EIFFEL_CLASS_TYPE_MARK_ATTRIBUTE

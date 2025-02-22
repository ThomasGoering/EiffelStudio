note
	description: ".NET formal generic type"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

frozen class
	CONSUMED_FORMAL_GENERIC_TYPE

inherit
	CONSUMED_REFERENCED_TYPE
		rename
			make as referenced_type_make
		redefine
			has_generic
		end

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING; id: INTEGER; t: like formal_type_name; p: like formal_position)
			-- Initialize Current with type name `a_name' defined in assembly `id'
			-- where original formal type name was `t`.
		require
			name_not_void: a_name /= Void
			name_not_empty: not a_name.is_empty
			id_positive: id > 0
		do
			referenced_type_make (a_name, id)
			ftn := t
			fpos := p
		ensure
			name_set: name = a_name
			id_set: assembly_id = id
		end

feature -- Access

	formal_type_name: STRING_32
		do
			Result := ftn
		end

	formal_position: INTEGER
			-- Position of the formal type in generic method declaration
			-- Warning: this is 0-based index
		do
			Result := fpos
		end

	has_generic: BOOLEAN = True

feature {NONE} -- Access

	ftn: like formal_type_name
			-- Internal data for `formal_type_name'.

	fpos: like formal_position
			-- Internal data for `formal_position`.

invariant
	formal_type_name_set: formal_type_name /= Void

note
	copyright:	"Copyright (c) 1984-2006, Eiffel Software"
	license:	"GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
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


end -- class CONSUMED_ARRAY_TYPE

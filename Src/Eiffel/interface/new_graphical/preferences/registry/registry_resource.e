note
	description: "Objects used as translator between WEL and bench formats for a resource."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "Christophe Bonnard"
	date: "$Date$"
	revision: "$Revision$"

class
	REGISTRY_RESOURCE

create
	make, make_from_resource

feature -- Initialization
	
	make (s: STRING; root_resource: WEL_REGISTRY_KEY_VALUE)
			-- initialization
		require
			not_void: root_resource /= Void
		local
		do
			name := s
			key_value := root_resource
			update_value
		end

	make_from_resource (r: RESOURCE)
			-- initialization
		require
			not_void: r /= Void
		local
		do
			value := r
			name := r.name
			update_key_value
		end

feature -- Access

	value: RESOURCE
		-- Value of the variable.

	key_value: WEL_REGISTRY_KEY_VALUE
		-- WEL representation of the resource

	name: STRING
		-- Name of the variable.

feature -- Implementation

	update_value
			-- Gets the appropriate resource from `key_value'
			-- if the type is unknown, it is assumed to be a string.
		local
			s: STRING
			type: INTEGER
			b: BOOLEAN
			sprefix: STRING
		do
				--| For backward compatibilities, everything is now stored through STRINGs.
			if key_value.type = key_value.Reg_dword then
				type := integer_type
				create {INTEGER_RESOURCE} value.make (name, key_value.dword_value)
			else
				s := key_value.string_value
				type := string_type
				if name.count > 7 then
					sprefix := name.substring (1, 7)
					if equal (sprefix, "EIFBOL_") then
						type := boolean_type
						name := name.substring (8, name.count)
					elseif equal (sprefix, "EIFINT_") then
						type := integer_type
						name := name.substring (8, name.count)
					elseif equal (sprefix, "EIFCOL_") then
						type := color_type
						name := name.substring (8, name.count)
					elseif equal (sprefix, "EIFFON_") then
						type := font_type
						name := name.substring (8, name.count)
					elseif equal (sprefix, "EIFARR_") then
						type := array_type
						name := name.substring (8, name.count)
					elseif equal (sprefix, "EIFSTR_") then
						type := string_type
						name := name.substring (8, name.count)
					else
						check
							error: False
						end
					end

					if type = string_type then
						create {STRING_RESOURCE} value.make (name, s)
					elseif type = color_type then
						create {COLOR_RESOURCE} value.make (name, s)
					elseif type = integer_type then
						create {INTEGER_RESOURCE} value.make (name, s.to_integer)
					elseif type = font_type then
						create {FONT_RESOURCE} value.make (name, s)
					elseif type = boolean_type then
						s.to_upper
						b := s.is_equal ("TRUE")
						create {BOOLEAN_RESOURCE} value.make (name, b)
					elseif type = array_type then
						create {ARRAY_RESOURCE} value.make_from_string (name, s)
					else
						check
							error: False
						end
					end
				else
					check
						Error: False
					end
				end
			end
		end

	update_key_value
			-- Gets the appropriate resource from `key_value'
			-- if the type is unknown, it is assumed to be a string.
		do
			create key_value.make ((create {WEL_REGISTRY_KEY_VALUE_TYPE}).Reg_sz, value.value)
		end

feature {NONE} -- Constants

	string_type, color_type, integer_type,
	font_type, boolean_type, array_type: INTEGER = unique

feature -- Implementation

	external_name: STRING
		-- Name for the outside world of Current.

invariant
	REGISTRY_RESOURCE_contains_something: value /= Void or key_value /= Void
	REGISTRY_RESOURCE_consistency: name /= Void and not name.is_empty

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

end -- class REGISTRY_RESOURCE

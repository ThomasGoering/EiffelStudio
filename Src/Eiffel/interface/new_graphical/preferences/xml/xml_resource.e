note
	description: "Class which describes the features for one resource."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "Pascal Freund and Christophe Bonnard"
	date: "$Date$"
	revision: "$Revision$"

class
	XML_RESOURCE

create
	make

feature -- Initialization
	
	make (root_resource: XML_ELEMENT)
			-- initialization from `root_resource'
		require
			not_void: root_resource /= Void
		local
			cursor: DS_BILINKED_LIST_CURSOR [XML_NODE]
			node: XML_ELEMENT
			txt: XML_TEXT
			att: XML_ATTRIBUTE
			att_table: XML_ATTRIBUTE_TABLE
			val: STRING
		do
			create name.make (20)
			att_table := root_resource.attributes
			if att_table.has ("DESCRIPTION") then
				att := att_table.item ("DESCRIPTION")
				if att /= Void then
					description := att.value
				end
			end
			if att_table.has ("IMMEDIATE_EFFECT") then
				att := att_table.item ("IMMEDIATE_EFFECT")
				if att /= Void then
					val := clone (att.value)
					val.to_lower
					effect_is_delayed := val.is_equal ("no")
				end
			end
			cursor := root_resource.new_cursor
			from
				cursor.start
			until
				cursor.after
			loop
				txt ?= cursor.item
				if txt /= Void then
					name.append (txt.string)
				else
					node ?= cursor.item
					if node /= Void then
						process_unit_specific (node)
					end
				end
				cursor.forth
			end
		end

feature -- Implementation

	process_unit_specific (node: XML_ELEMENT)
			-- Gets the appropriate resource from `node'
			-- if the type is unknown, it is assumed to be a string.
		local
			s: STRING
			type: INTEGER
			b: BOOLEAN
			txt: XML_TEXT
		do
			if node.name.is_equal ("STRING") then
				type := string_type
			elseif node.name.is_equal ("COLOR") then
				type := color_type
			elseif node.name.is_equal ("INTEGER") then
				type := integer_type
			elseif node.name.is_equal ("FONT") then
				type := font_type
			elseif node.name.is_equal ("BOOLEAN") then
				type := boolean_type
			elseif node.name.is_equal ("LIST_STRING") then
				type := array_type
			elseif node.name.is_equal ("A") then
				txt ?= node.first
				s := clone (txt.string)
				if not s.is_empty then
					s.prune_all ('%R')
					s.prune_all ('%T')
					name.append (s)
				end
			end
			if not node.is_empty then
				txt ?= node.first
			end
			if txt /= Void then
				s := txt.string
				s.prune_all ('%R')
				s.prune_all ('%T')
			end
			if type = string_type then
				if s = Void then
					s := ""
				end
				create {STRING_RESOURCE} value.make (name, s)
			elseif type = color_type then
				create {COLOR_RESOURCE} value.make (name, s)
			elseif type = integer_type and then s.is_integer then
				create {INTEGER_RESOURCE} value.make (name, s.to_integer)
			elseif type = font_type then
				create {FONT_RESOURCE} value.make (name, s)
			elseif type = boolean_type then
				s.to_upper
				b := s.is_equal ("TRUE")
				create {BOOLEAN_RESOURCE} value.make (name, b)
			elseif type = array_type then
				if s = Void then
					s := ""
				end
				create {ARRAY_RESOURCE} value.make_from_string (name, s)
			else
				if s = Void then
					s := ""
				end
				create {STRING_RESOURCE} value.make (name, s)
			end
			if description /= Void then
				value.set_description (description)
			end
			value.set_effect_is_delayed (effect_is_delayed)
		end

feature {NONE} -- Constants

	string_type, color_type, integer_type,
	font_type, boolean_type, array_type: INTEGER = unique

feature -- Implementation

	name: STRING
		-- Name of the variable.

	description: STRING
		-- Description of the variable.

	value: RESOURCE
		-- Value of the variable.

	external_name: STRING
		-- Name for the outside world of Current.

	effect_is_delayed: BOOLEAN
		-- Is a change in the resource reflected in the application
		-- immediately ?

invariant
	XML_RESOURCE_exists: name /= Void and value /= Void
	XML_RESOURCE_consistency: not name.is_empty

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

end -- class XML_RESOURCE

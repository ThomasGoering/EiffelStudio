﻿note
	description: "[
		A code token to represent a replacable code identifier.
	]"
	legal: "See notice at end of class."
	status: "See notice at end of class.";
	date: "$Date$";
	revision: "$Revision$"

class
	CODE_TOKEN_ID

inherit
	CODE_TOKEN_TEXT
		rename
			make as make_token
		redefine
			is_editable,
			printable_text,
			process,
			out
		end

create
	make

feature {NONE} -- Initialization

	make (a_text: READABLE_STRING_GENERAL)
			-- Initializes the code token using a text representation, as taken from a code template text source.
			--
			-- `a_text': A string representation of the token.
		require
			a_text_attached: attached a_text
			a_text_is_valid_text: is_valid_text (a_text)
		do
			is_editable := True
			make_token (a_text)
		ensure
			text_set: text.same_string_general (a_text)
			is_editable: is_editable
		end

feature -- Access

	printable_text: like text
			-- <Precursor>
		do
			if attached internal_printable_text as l_result then
				Result := l_result
			else
				create Result.make_empty
				internal_printable_text := Result
			end
		end

feature -- Status report

	is_editable: BOOLEAN assign set_is_editable
			-- <Precursor>

feature -- Status setting

	set_is_editable (a_editable: like is_editable)
			-- Set's editable state of the token.
			--
			-- `a_editable': True to make the token editable; False otherwise.
		do
			is_editable := a_editable
		ensure
			is_editable_set: is_editable = a_editable
		end

feature -- Basic operations

	evaluate (a_table: CODE_SYMBOL_TABLE)
			-- Evalutes the current token to determine it's printable value.
			--
			-- `a_table': A code symbol table to take evaluated values from.
		require
			a_table_attached: attached a_table
		local
			l_id: STRING_32
		do
			l_id := text
			if a_table.has_id (l_id) then
					-- Fetch value from the symbol table
				internal_printable_text := a_table.item (l_id).value
			else
					-- Use the ID
				internal_printable_text := l_id
			end
		end

feature -- Visitor

	process (a_visitor: CODE_TOKEN_VISITOR_I)
			-- <Precursor>
		do
			a_visitor.process_code_token_id (Current)
		end

feature -- Output

	out: STRING
			-- <Precursor>
		do
			create Result.make (10)
			Result.append ("${")
			if attached {READABLE_STRING} text as t then
				Result.append (t)
			else
				Result.append ({UTF_CONVERTER}.string_32_to_utf_8_string_8 (text))
			end
			Result.append_character ('}')
		end

feature {NONE} -- Internal implementation cache

	internal_printable_text: detachable like printable_text
			-- Mutable version of `printable_text'.	

;note
	copyright:	"Copyright (c) 1984-2023, Eiffel Software"
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
			distributed in the hope that it will be useful, but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
		]"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"

end

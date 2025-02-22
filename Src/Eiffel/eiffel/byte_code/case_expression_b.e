﻿note
	description: "Byte code for 'when...then' construct in multi-branch expression."

class CASE_EXPRESSION_B

inherit
	ABSTRACT_CASE_B [EXPR_B]
		redefine
			enlarge_tree
		end

create
	make

feature -- Visitor

	process (v: BYTE_NODE_VISITOR)
			-- Process current element.
		do
			v.process_case_expression_b (Current)
		end

feature -- Status Report

	has_content: BOOLEAN = True
			-- <Precursor>


feature -- Code generation: C

	used (r: REGISTRABLE): BOOLEAN
			-- <Precursor>
		do
			Result := content.used (r)
		end

	generate_for_attachment (target_register: REGISTRABLE; target_type: TYPE_A)
			-- <Precursor>
		local
			buf: GENERATION_BUFFER
		do
			generate_frozen_debugger_hook
			generate_line_info
			interval.generate
			buf := buffer
			buf.indent
			if attached content as c then
				c.generate_for_attachment (target_register, target_type)
			end
			buf.put_new_line
			buf.put_string ("break;")
			buf.exdent
		end

	enlarge_tree
			-- <Precursor>
		do
			interval := interval.enlarged
			content := content.enlarged
		end

note
	date: "$Date$"
	revision: "$Revision$"
	author: "Alexander Kogtenkov"
	copyright:	"Copyright (c) 1984-2020, Eiffel Software"
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

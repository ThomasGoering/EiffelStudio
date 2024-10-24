﻿note
	description: "Dummy debug value, named but no more information"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	DUMMY_MESSAGE_DEBUG_VALUE

inherit
	ABSTRACT_DEBUG_VALUE
		redefine
			debug_value_type_id
		end

create {DBG_EVALUATOR, RECV_VALUE, ATTR_REQUEST, CALL_STACK_ELEMENT, DEBUG_VALUE_EXPORTER, APPLICATION_EXECUTION}
	make_with_name,
	make_with_details

feature {NONE} -- Initialization

	make_with_name (a_name: READABLE_STRING_GENERAL)
			-- Create current
		do
			name := a_name.to_string_32
			display_kind := kind
		end

	make_with_details (a_name: READABLE_STRING_GENERAL; a_message: like message; a_kind: like display_kind)
			-- Create current
		do
			make_with_name (a_name)
			if a_kind > 0 then
				set_display_kind (a_kind)
			end
			if a_message /= Void then
				set_message (a_message)
			end
		end

feature -- change

	set_message (a_msg: like message)
		do
			message := a_msg
		end

	set_display_kind (a_kind: like display_kind)
		do
			display_kind := a_kind
		end

feature -- Access

	message: STRING_GENERAL
			-- Information message to display in object tool

	display_message: STRING_32
			-- Computed information message to display in object tool
		do
			if message /= Void then
				Result := message.as_string_32
			else
				Result := "Unavailable value"
			end
		end

	dynamic_class: CLASS_C
			-- Find corresponding CLASS_C to type represented by `value'.
		do
			Result := Eiffel_system.any_class.compiled_class
		end

	dump_value: DUMP_VALUE
			-- Dump_value corresponding to `Current'.
		local
			s: STRING_GENERAL
		do
			s := display_message
			if s /= Void then
				Result := Debugger_manager.Dump_value_factory.new_manifest_string_value
					({UTF_CONVERTER}.string_32_to_utf_8_string_8 (display_message), dynamic_class)
				Result.invalidate_value
			end
		end

feature {NONE} -- Output

	output_value: STRING_32
			-- A STRING representation of the value of `Current'.
		do
			if attached address as add then
				Result := add.output
			end
		end

	type_and_value: STRING_32
			-- Return a string representing `Current'.
		do
			Result := display_message
		end

feature -- Output

	expandable: BOOLEAN = False
			-- Does `Current' have sub-items? (Is it a non void reference, a special object, ...)

	children: DEBUG_VALUE_LIST
			-- List of all sub-items of `Current'.
			-- May be void if there are no children.
			-- Generated on demand.
			-- (sorted by name)
		do
		end

	display_kind: like kind

	kind: INTEGER
			-- Actual type of `Current'. cf possible codes underneath.
			-- Used to display the corresponding icon.
		once
			Result := Error_message_value
		end

feature {DEBUGGER_TEXT_FORMATTER_VISITOR} -- Debug value type id

	debug_value_type_id: INTEGER
		do
			Result := dummy_message_debug_value_id
		end

note
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


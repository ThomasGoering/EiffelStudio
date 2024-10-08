﻿note
	description: ".NET consumer interface."

deferred class
	CONSUMER

feature -- Status report

	is_available: BOOLEAN
			-- Does the implementation exist?
		deferred
		end

	is_initialized: BOOLEAN
			-- Is consumer initialized?
		deferred
		end

feature -- Access

	last_error_message: detachable READABLE_STRING_32
			-- Error message from the last operation.
		deferred
		end

feature -- Disposal

	release
			-- Release all used resources.
		deferred
		end

feature -- Basic operations

	consume_assembly_from_path (a_assembly_paths: ITERABLE [READABLE_STRING_32]; a_info_only: BOOLEAN; a_references: detachable ITERABLE [READABLE_STRING_32])
			-- Consume local assemblies `a_assembly_paths` and all of its dependencies `a_references`.
			-- note: `a_assembly_paths` is a semi-colon separated value.
		require
			is_available
			is_initialized
			attached a_assembly_paths
		deferred
		end

	consume_assembly (a_name, a_version, a_culture, a_key: READABLE_STRING_GENERAL; a_info_only: BOOLEAN)
			-- Consume an assembly from the assembly defined by
			-- the name `a_name`, version `a_version`, culture `a_culture`, and public key token `a_key`.
		require
			is_available
			is_initialized
			attached a_name
			attached a_version
			attached a_culture
			attached a_key
			not a_name.is_empty
			not a_version.is_empty
			not a_culture.is_empty
			not a_key.is_empty
		deferred
		end

note
	date: "$Date$"
	revision: "$Revision$"
	copyright: "Copyright (c) 2022, Eiffel Software"
	license: "GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options: "http://www.eiffel.com/licensing"
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

note
	description: "Setup environment variables for Visual Studio C compiler."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	VS_SETUP

inherit
	EIFFEL_LAYOUT
		export
			{NONE} all
		end

	ENV_CONSTANTS
		export
			{NONE} all
		end

	ANY

create
	make

feature -- Initialization

	make (a_preferred_config: detachable STRING; a_compatible_config: detachable STRING; a_force_32bit_generation: BOOLEAN)
			-- Create and setup environment variables for currently installed
			-- version of Visual Studio using `a_preferred_config' if present, otherwise
			-- use the most recent version of Visual Studio compatible with `a_compatible_config' if present.
		require
			a_preferred_config_valid: a_preferred_config /= Void implies not a_preferred_config.is_empty
			a_compatible_config_valid: a_compatible_config /= Void implies not a_compatible_config.is_empty
			choices_exclusive: (a_preferred_config = Void) or (a_compatible_config = Void)
		local
			l_man: C_CONFIG_MANAGER
			l_config: detachable C_CONFIG
		do
			create l_man.make (a_force_32bit_generation)
			if a_preferred_config /= Void and then l_man.is_config_code_valid (a_preferred_config) then
					-- `a_preferred_config' is not empty per precondition
				l_config := l_man.config_from_code (a_preferred_config, True)
			end
			if l_config = Void and then (a_compatible_config = Void or else l_man.is_config_code_valid (a_compatible_config)) then
					-- Find a configuration compatible with `a_compatible_config', or any configuration if not set.
				l_config := l_man.best_configuration (a_compatible_config)
			end
			if l_config /= Void then
				synchronize_variable (path_var_name, l_config.path_var)
				synchronize_variable (include_var_name, l_config.include_var)
				synchronize_variable (lib_var_name, l_config.lib_var)
				found_config := l_config
			end
		end

feature -- Status report

	successful: BOOLEAN
			-- Indicates if a version of Visual Studio was found and the environment configured
		do
			Result := found_config /= Void
		end

	found_config: detachable C_CONFIG
			-- Found C configuration if any.

feature -- Implementation

	synchronize_variable (a_name: READABLE_STRING_32; a_values: READABLE_STRING_32)
			-- Merges the process environment variable `a_name' values with `a_values', removing duplicates in the process.
		require
			a_name_attached: a_name /= Void
			not_a_name_is_empty: not a_name.is_empty
		local
			l_process_values: detachable LIST [STRING_32]
			l_values: LIST [STRING_32]
			l_process_var: detachable STRING_32
			l_merged: STRING_32
			l_name, l_new_values: WEL_STRING
			l_success: BOOLEAN
		do
			if not a_values.is_empty then
				create l_name.make (a_name)

				l_values := a_values.to_string_32.split (';')
				if not l_values.is_empty then
					l_values.compare_objects

						-- Retrieve existing variable
					l_process_var := eiffel_layout.get_environment_32 (a_name)
					if l_process_var /= Void then
						l_process_values := l_process_var.split (';')
						l_process_values.compare_objects
					end

					if l_process_values /= Void and then not l_process_values.is_empty then
						from l_process_values.start until l_process_values.after loop
							if not l_values.has (l_process_values.item) then
								l_values.extend (l_process_values.item)
							end
							l_process_values.forth
						end

								-- Rebuild variable value string list
						create l_merged.make (300)
						from l_values.start until l_values.after loop
							l_merged.append (l_values.item + {STRING_32} ";")
							l_values.forth
						end
						create l_new_values.make (l_merged)
					else
							-- No process values
						create l_new_values.make (a_values)
					end
					l_success := set_environment_variable (l_name.item, l_new_values.item)
					check l_success: l_success end
				end
			end
		end

feature {NONE} -- Externals

	set_environment_variable (name, value: POINTER): BOOLEAN
			-- Set environment variable `name' with value `value'.
			-- Return True if successful.
		external
			"C macro signature (LPCTSTR, LPCTSTR): EIF_BOOLEAN use <windows.h>"
		alias
			"SetEnvironmentVariable"
		end

note
	copyright:	"Copyright (c) 1984-2016, Eiffel Software"
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

end -- class VS_SETUP

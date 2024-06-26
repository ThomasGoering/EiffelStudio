note
	description: "Global cache settings"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	CACHE_SETTINGS

inherit
	CACHE_CONSTANTS

feature -- Access

	cache_lock_id: SYSTEM_STRING
			-- id used to lock cache.
			-- Note: This has to be unique per user since accessing a Mutex created by
			-- a different user causes a security exception. This means that concurrent
			-- cache access by different users is not supported.
		local
			r: STRING_32
		once
			create r.make_from_string ((create {CACHE_READER}).eiffel_assembly_cache_path.name)
			r.replace_substring_all ({STRING_32} ":", {STRING_32} "!")
			r.replace_substring_all ({STRING_32} "\", {STRING_32} "!")
			Result := r.to_cil
		ensure
			result_attached: Result /= Void
			not_result_is_empty: Result.length > 0
		end

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


end -- class CACHE_SETTINGS

﻿note
	description: "Object that represents an No operation on another argument criterion"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	QL_ARGUMENT_NOT_CRITERION

inherit
	QL_ARGUMENT_CRITERION
		undefine
			set_used_in_domain_generator,
			is_atomic,
			set_source_domain,
			has_inclusive_intrinsic_domain,
			has_exclusive_intrinsic_domain,
			process
		redefine
			intrinsic_domain
		end

	QL_NOT_CRITERION
		undefine
			require_compiled
		redefine
			wrapped_criterion
		end

create
	make

feature -- Evaluate

	is_satisfied_by (a_item: QL_ARGUMENT): BOOLEAN
			-- Evaluate `a_item'.
		do
			Result := not wrapped_criterion.is_satisfied_by (a_item)
		end

feature -- Access

	wrapped_criterion: QL_ARGUMENT_CRITERION
			-- Criterion to which NOT operation is applied		

	intrinsic_domain: QL_ARGUMENT_DOMAIN
			-- Intrinsic_domain which can be inferred from current criterion
		do
			Result := wrapped_criterion.intrinsic_domain
		end

note
	copyright: "Copyright (c) 1984-2018, Eiffel Software"
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

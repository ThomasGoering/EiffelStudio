note

	description: "[
		Values that may be hashed into an integer index, 
		for use as keys in hash tables
		]"

	status: "See notice at end of class"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	HASHABLE

feature -- Access

	hash_code: INTEGER
			-- Hash code value
		deferred
		ensure
			good_hash_value: Result >= 0
		end

feature -- Status report

	is_hashable: BOOLEAN
			-- May current object be hashed?
			-- (True if it is not its type's default.)
		do
			Result := (Current /= default)
		ensure
			ok_if_not_default: Result implies (Current /= default)
		end

note

	library: "[
			EiffelBase: Library of reusable components for Eiffel.
			]"

	status: "[
--| Copyright (c) 1993-2006 University of Southern California and contributors.
			For ISE customers the original versions are an ISE product
			covered by the ISE Eiffel license and support agreements.
			]"

	license: "[
			EiffelBase may now be used by anyone as FREE SOFTWARE to
			develop any product, public-domain or commercial, without
			payment to ISE, under the terms of the ISE Free Eiffel Library
			License (IFELL) at http://eiffel.com/products/base/license.html.
			]"

	source: "[
			Interactive Software Engineering Inc.
			ISE Building
			360 Storke Road, Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Electronic mail <info@eiffel.com>
			Customer support http://support.eiffel.com
			]"

	info: "[
			For latest info see award-winning pages: http://eiffel.com
			]"

end -- class HASHABLE




﻿note
	description: "Copy file using RAW_FILE."
	legal: "See notice at end of class."
	status: "See notice at end of class."

class
	EW_COPY_BIN_INST

inherit
	EW_COPY_INST
		redefine
			copy_file
		end

feature -- Properties

	substitute: BOOLEAN = True
			-- Do not substitute lines of copied files

feature {NONE} -- Implementation

	copy_file (src: like new_file; env: EW_TEST_ENVIRONMENT; dest: like new_file)
			-- Append lines of file `src', with environment
			-- variables substituted according to `env' (but
			-- only if `substitute' is true) to
			-- file `dest'.
		do
			dest.open_write
			src.open_read
			src.copy_to (dest)
			src.close
			dest.close
		end

	new_file (a_file_name: READABLE_STRING_32): RAW_FILE
		do
			create Result.make_with_name (a_file_name)
		end

note
	date: "$Date$"
	revision: "$Revision$"
	copyright: "[
			Copyright (c) 1984-2018, University of Southern California, Eiffel Software and contributors.
			All rights reserved.
		]"
	license:   "Your use of this work is governed under the terms of the GNU General Public License version 2"
	copying: "[
			This file is part of the EiffelWeasel Eiffel Regression Tester.

			The EiffelWeasel Eiffel Regression Tester is free
			software; you can redistribute it and/or modify it under
			the terms of the GNU General Public License version 2 as published
			by the Free Software Foundation.

			The EiffelWeasel Eiffel Regression Tester is
			distributed in the hope that it will be useful, but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the GNU General Public License version 2 for more details.

			You should have received a copy of the GNU General Public
			License version 2 along with the EiffelWeasel Eiffel Regression Tester
			if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA
		]"







end

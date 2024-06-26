note
	description: "Summary description for ENVIRONMENT_ARGUMENTS."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ENVIRONMENT_ARGUMENTS

feature -- Access

	argument (i: INTEGER): STRING
			-- `i'-th argument of command that started system execution
			-- (the command name if `i' = 0)
		require
			index_large_enough: i >= 0
			index_small_enough: i <= argument_count
		do
			if i <= base_arguments.argument_count then
				Result := base_arguments.argument (i)
			else
				Result := environment_argument_item (i)
			end
		ensure
			argument_not_void: Result /= Void
		end

feature -- Status report

	index_of_word_option (opt: STRING): INTEGER
			-- Does command line specify word option `opt' and, if so,
			-- at what position?
			-- If one of the arguments in list of space-separated arguments
			-- is `Xopt', where `X' is the current `option_sign',
			-- then index of this argument in list;
			-- else 0.
		require
			opt_non_void: opt /= Void
			opt_meaningful: not opt.is_empty
		local
			i, n: INTEGER
		do
			Result := base_arguments.index_of_word_option (opt)
			if Result = 0 then
				n := argument_count
				from
					i := base_arguments.argument_count + 1
				until
					i > n or else option_word_equal (environment_argument_item (i), opt)
				loop
					i := i + 1
				end
				if i <= n then
					Result := i
				end
			end
		end

	option_sign: CHARACTER_REF
			-- The character used to signal options on the command line.
			-- This can be '%U' if no sign is necesary for the argument
			-- to be an option
			-- Default is '-'
		once
			Result := base_arguments.option_sign
		end

feature -- Status setting

	set_option_sign (c: CHARACTER)
			-- Make `c' the option sign.
			-- Use'%U' if no sign is necesary for the argument to
			-- be an option
		do
			base_arguments.set_option_sign (c)
		end

feature -- Measurement

	argument_count: INTEGER
			-- Number of arguments given to command that started
			-- system execution (command name does not count)
		do
			Result := base_arguments.argument_count + environment_arguments.count
		ensure
			argument_count_positive: Result >= 0
		end

feature {NONE} -- Implementation

	arguments_environment_name: STRING
			-- Environment variable's name used to extend the command line
		deferred
		ensure
			attached_result: Result /= Void
		end

	option_word_equal (arg, w: STRING): BOOLEAN
			-- Is `arg' equal to the word option `w'?
			--| Check `ARGUMENTS.option_word_equal (..)'
		require
			arg_not_void: arg /= Void
			w_not_void: w /= Void
		do
			if option_sign.item = '%U' then
				Result := arg ~ w
			elseif not arg.is_empty and then arg.item (1) = option_sign.item then
				Result := arg.substring (2, arg.count) ~ w
			end
		end

	environment_argument_item (i: INTEGER): STRING
			-- `i'-th argument of environment option
		require
			index_large_enough: i > base_arguments.argument_count
			index_small_enough: i <= argument_count
		do
			Result := environment_arguments.item (i)
		ensure
			argument_not_void: Result /= Void
		end

	environment_arguments: ARRAY [STRING]
			-- Arguments array extracted from environment
		local
			i,n,r: INTEGER
			c: CHARACTER
			l_flags: detachable STRING
			s: STRING
			exec: EXECUTION_ENVIRONMENT
			l_in_quote: BOOLEAN
			utf: UTF_CONVERTER
		once
			create exec
			if attached exec.item (arguments_environment_name) as l_unicode_flags then
					-- For this obsolete library, let's use UTF-8 to convert to STRING_8.
				l_flags := utf.string_32_to_utf_8_string_8 (l_unicode_flags)
			end
			if l_flags /= Void then
				l_flags.right_adjust --| To exclude flag with only whitespace
			end
			if l_flags /= Void and then not l_flags.is_empty then
				from
					r := base_arguments.argument_count
					i := 1
					n := l_flags.count
					create s.make_empty
					create Result.make_filled (s.string, r + 1, r + 6)
				until
					i > n
				loop
					c := l_flags.item (i)
					if l_in_quote then
						if c = '%"' then
							l_in_quote := False
						else
							s.extend (c)
						end
					else
						inspect c
						when '%"' then
							l_in_quote := True
						when ' ', '%T' then
							if not s.is_empty then
								r := r + 1
								Result.force (s.string, r)
								s.wipe_out
							end
						else
							s.extend (c)
						end
					end
					i := i + 1
				end
				if l_in_quote then
						-- Quote was not terminated, we simply ignore everything after
						-- the last non-closed quote.
					Result := Result.subarray (Result.lower, r)
				elseif not s.is_empty then
					r := r + 1
					Result.force (s.string, r)
					Result := Result.subarray (Result.lower, r)
				end
			else
				create Result.make_empty
			end
		end

	base_arguments: ARGUMENTS
			-- Standard command line arguments
		once
			create Result
		end

invariant
	environment_arguments_valid: not environment_arguments.is_empty implies (
			argument_count > base_arguments.argument_count and
			environment_arguments.lower = base_arguments.argument_count + 1 and
			environment_arguments.upper = argument_count
		)

note
	copyright: "Copyright (c) 1984-2017, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
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

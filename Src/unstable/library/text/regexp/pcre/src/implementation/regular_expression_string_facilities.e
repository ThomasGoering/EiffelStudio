note
	description: "Regular expression String Facilities"
	copyright: "Copyright (c) 2001-2017, Eric Bezault, Eiffel Software and others"
	license: "MIT License"

deferred class
	REGULAR_EXPRESSION_STRING_FACILITIES

inherit
	PATTERN_MATCHER

feature -- Replacement

	replacement (a_replacement: READABLE_STRING_8): STRING
			-- Copy of `a_replacement' where all occurrences of \n\ have
			-- been replaced by the corresponding n-th captured substrings
			-- if any
		require
			is_matching: is_matching
		do
			create Result.make (a_replacement.count)
			append_replacement_to_string (Result, a_replacement)
		ensure
			replacement_not_void: Result /= Void
		end

	append_replacement_to_string (a_string: STRING; a_replacement: READABLE_STRING_8)
			-- Append to `a_string' a copy of `a_replacement' where all occurrences
			-- of \n\ have been replaced by the corresponding n-th captured substrings
			-- if any.
		require
			is_matching: is_matching
			a_string_not_void: a_string /= Void
			a_replacement_not_void: a_replacement /= Void
		local
			i, j, nb, ref: NATURAL
			c: NATURAL_32
		do
			nb := a_replacement.count.as_natural_32
			from
				i := 1
			until
				i > nb
			loop
				c := a_replacement.code (i.as_integer_32)
				if c = {ASCII}.Backslash.as_natural_32 then
					from
						i := i + 1
						j := i
						ref := 0
					until
						i > nb or else (a_replacement.code (i.as_integer_32) < {ASCII}.Zero.as_natural_32 or a_replacement.code (i.as_integer_32) > {ASCII}.Nine.as_natural_32)
					loop
						c := a_replacement.code (i.as_integer_32)
						ref := ref * 10 + (c - {ASCII}.Zero.as_natural_32)
						i := i + 1
					end
					if i <= nb then
						c := a_replacement.code (i.as_integer_32)
						if c = {ASCII}.Backslash.as_natural_32 then
							if i > j then
									-- Minimal one digit readed,
								if ref < match_count then
									append_captured_substring_to_string (a_string, ref)
								end
							else
									-- Double backslash means one \\ => \.
								a_string.append_code (c)
							end
							i := i + 1
						else
								-- Backslash followed by optional digits without the final backslash
								-- put the backslash in and process the following characters by the
								-- normal way.
							a_string.append_character ('\')
							i := j
						end
					else
							-- Backslash followed by options digit fill the rest of line, we put the
							-- backslash in an processes the may following characters on the normal way.
						a_string.append_character ('\')
						i := j
					end
				else
						-- Simply put the character in.
					a_string.append_code (c)
					i := i + 1
				end
			end
		end

	replace (a_replacement: READABLE_STRING_8): STRING
			-- Substring of `subject' between `subject_start' and `subject_end'
			-- where the whole matched string has been replaced by `a_replacement';
			-- All occurrences of \n\ in `a_replacement' will have been replaced
			-- by the corresponding n-th captured substrings if any
		require
			is_matching: is_matching
			a_replacement_not_void: a_replacement /= Void
		do
			create Result.make ((subject_end - subject_start).as_integer_32)
			append_replace_to_string (Result, a_replacement)
		ensure
			replace_not_void: Result /= Void
			same_type: Result.same_type (subject)
		end

	append_replace_to_string (a_string: STRING a_replacement: READABLE_STRING_8)
			-- Append to `a_string' a substring of `subject' between `subject_start'
			-- and `subject_end' where the whole matched string has been replaced by
			-- `a_replacement'. All occurrences of \n\ in `a_replacement' will have
			-- been replaced by the corresponding n-th captured substrings if any.
		require
			is_matching: is_matching
			a_string_not_void: a_string /= Void
			a_replacement_not_void: a_replacement /= Void
		do
			if match_count > 0 then
				a_string.append_string (subject.substring (subject_start.as_integer_32, (captured_start_position (0) - 1).as_integer_32))
				append_replacement_to_string (a_string, a_replacement)
				a_string.append_string (subject.substring (captured_end_position (0) + 1, subject_end.as_integer_32))
			else
				a_string.append_string (subject.substring (subject_start.as_integer_32, subject_end.as_integer_32))
			end
		end

	replace_all (a_replacement: READABLE_STRING_8): STRING
			-- Substring of `subject' between `subject_start' and `subject_end'
			-- where the whole matched string has been repeatedly replaced by
			-- `a_replacement'; All occurrences of \n\ in `a_replacement' will
			-- have been replaced by the corresponding n-th captured substrings
			-- if any
		require
			is_matching: is_matching
			a_replacement_not_void: a_replacement /= Void
		do
			create Result.make ((subject_end - subject_start + 1).as_integer_32)
			append_replace_all_to_string (Result, a_replacement)
		ensure
			all_matched: not has_matched
			replace_not_void: Result /= Void
		end

	append_replace_all_to_string (a_string: STRING a_replacement: READABLE_STRING_8)
			-- Append to `a_string' a substring of `subject' between `subject_start'
			-- and `subject_end' where the whole matched string has been repeatedly
			-- replaced by `a_replacement'. All occurrences of \n\ in `a_replacement'
			-- will have been replaced by the corresponding n-th captured substrings
			-- if any.
		require
			is_matching: is_matching
			a_string_not_void: a_string /= Void
			a_replacement_not_void: a_replacement /= Void
		local
			old_subject_start: NATURAL
			l_captured_start_position: NATURAL
			l_captured_end_position: INTEGER
			l_next_start: NATURAL
		do
			old_subject_start := subject_start
			from
			until
				not has_matched
			loop
				l_captured_start_position := captured_start_position (0)
				l_captured_end_position := captured_end_position (0)
				a_string.append_string (subject.substring (subject_start.as_integer_32, (l_captured_start_position - 1).as_integer_32))
				append_replacement_to_string (a_string, a_replacement)
				if l_captured_start_position.as_integer_32 > l_captured_end_position then
						-- Make sure that we move to the next character, even
						-- when an empty string was matched.
					if l_captured_start_position <= subject_end then
						a_string.append_character (subject.item (l_captured_start_position.as_integer_32))
						l_next_start := l_captured_start_position + 1
						match_unbounded_substring (subject, l_next_start, subject_end)
					else
							-- We already went past the end of the subject.
							-- There is nothing to be matched anymore.
						match_count := 0
						subject_start := subject_end + 1
					end
				else
					l_next_start := (l_captured_end_position + 1).as_natural_32
					match_unbounded_substring (subject, l_next_start, subject_end)
				end
			end
			a_string.append_string (subject.substring (subject_start.as_integer_32, subject_end.as_integer_32))
			subject_start := old_subject_start
		ensure
			all_matched: not has_matched
		end

feature -- Splitting

	split: ARRAY [STRING]
			-- Parts of `subject' between `subject_start' and `subject_end'
			-- which do not match the pattern.
		require
			is_matching: is_matching
		do
			create Result.make_empty
			append_split_to_array (Result)
		ensure
			all_matched: not has_matched
			split_not_void: Result /= Void
		end

	append_split_to_array (an_array: ARRAY [STRING])
			-- Append to `an_array' the parts of `subject' between `subject_start'
			-- and `subject_end' which do not match the pattern.
		require
			is_matching: is_matching
			an_array_not_void: an_array /= Void
		local
			i, j: NATURAL
			k, nb: INTEGER
			l_last_char_matched: NATURAL
			old_subject_start: NATURAL
		do
			i := subject_start
			l_last_char_matched := i - 1
			old_subject_start := i
			nb := an_array.upper
			from
			until
				not has_matched
			loop
				j := captured_start_position (0)
				k := captured_end_position (0)
				if j.as_integer_32 > k then
						-- We matched an empty string, so we have to
						-- move to the next character, otherwise we
						-- will enter an infinite loop.
					if i <= j and j <= subject_end then
						nb := nb + 1
						an_array.force (subject.substring (i.as_integer_32, j.as_integer_32), nb)
					end
					i := (k + 2).as_natural_32
					if i <= subject_end then
						match_unbounded_substring (subject, i, subject_end)
					else
							-- We reached the end of the subject.
							-- Stop searching for matching substring,
							-- otherwise it would always match since
							-- the current regexp can match the empty
							-- string, resulting in an infinite loop.
						i := subject_end + 2
						match_count := 0
						check
							not_has_matched: not has_matched
						end
					end
				else
					if i < j then
						nb := nb + 1
						an_array.force (subject.substring (i.as_integer_32, (j - 1).as_integer_32), nb)
					elseif i = j and (l_last_char_matched = i - 1) then
							-- If the string between two consecutive matches is
							-- empty, then the previous character (at position
							-- i-1) should be the last character matched in the
							-- previous iteration). If it's not, then it means
							-- that at the previous iteration we matched the
							-- empty string. Therefore we cannot add to `an_array'
							-- a string (i.e. the empty string) which itself can
							-- be matched by the current regexp.
						nb := nb + 1
						an_array.force (create {STRING_8}.make (nb), nb)
					end
					l_last_char_matched := k.as_natural_32
					i := (k + 1).as_natural_32
					match_unbounded_substring (subject, i, subject_end)
				end
			end
			if i <= subject_end + 1 then
				nb := nb + 1
				an_array.force (subject.substring (i.as_integer_32, subject_end.as_integer_32), nb)
			end
			subject_start := old_subject_start
		ensure
			all_matched: not has_matched
		end

end

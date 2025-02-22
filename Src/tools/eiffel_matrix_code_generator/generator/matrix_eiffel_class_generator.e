﻿note
	description: "A generator for creating Eiffel classes from a matrix INI file."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	MATRIX_EIFFEL_CLASS_GENERATOR

inherit
	MATRIX_FILE_GENERATOR
		redefine
			reset,
			process_property,
			validate_properties
		end

	ERROR_SHARED_ERROR_MANAGER
		export
			{NONE} all
		end

create
	make

feature -- Access

	generated_file_name: detachable PATH
			-- Location of generated file

feature {NONE} -- Access

	class_name: detachable READABLE_STRING_32
			-- Class name specified in matrix file

	animation_pixmaps: HASH_TABLE [attached ARRAYED_LIST [attached STRING], attached STRING]
			-- Table of pixmap animations

feature -- Basic Operations

	generate (a_doc: INI_DOCUMENT; a_frame: STRING; a_class_name: detachable READABLE_STRING_32; a_output: detachable PATH)
			-- Generates a matrix file.
		require
			not_a_class_name_is_empty: a_class_name /= Void implies not a_class_name.is_empty
			not_a_output_is_empty: a_output /= Void implies not a_output.is_empty
		local
			l_props: LIST [INI_PROPERTY]
			l_prop: INI_PROPERTY
			l_cursor: CURSOR
			l_of: PATH
			l_buffer: STRING
			l_temp_buffer: STRING
			l_buffers: like internal_buffers
			l_fragment: STRING
			l_anim_pixmaps: like animation_pixmaps
			l_animations: like animation_pixmaps.item_for_iteration
			l_name: like animation_pixmaps.key_for_iteration
			l_iname: STRING
			l_ibname: STRING
			l_args: ARGUMENTS_32
			u: UTF_CONVERTER
		do
			reset

			class_name := a_class_name
			if is_successful then
					-- If successful
				create l_buffer.make (1024) -- 1mb should be big enough
				l_buffer.append (a_frame)

				process (a_doc, agent
					do
						if class_name = Void then
							class_name := default_class_name
						end
					end, Void)

				if is_successful then
					check
						class_name_attached: attached class_name as l_class_name
					then
							-- Replace optional tokens.
						l_buffer.replace_substring_all (token_variable (class_name_property), u.string_32_to_utf_8_string_8 (l_class_name))
						l_buffer.replace_substring_all (token_variable (pixel_border_property), pixel_border.out)
						create l_args
						l_buffer.replace_substring_all (token_variable (command_line_property), u.string_32_to_utf_8_string_8 (l_args.command_line))

							-- Replace aux tokens based on other properties in the configuration file
						l_props := a_doc.named_properties
						if not l_props.is_empty then
							l_cursor := l_props.cursor
							from l_props.start until l_props.after loop
								l_prop := l_props.item
								if attached l_prop.name as n and then not n.is_empty then
									l_buffer.replace_substring_all (token_variable (n), if l_prop.has_value then l_prop.value else "" end)
								end
								l_props.forth
							end
							l_props.go_to (l_cursor)
						end

							-- Generate any animations
						l_anim_pixmaps := animation_pixmaps
						if not l_anim_pixmaps.is_empty then
							from l_anim_pixmaps.start until l_anim_pixmaps.after loop
								l_animations := l_anim_pixmaps.item_for_iteration
								if l_animations.count > 1 then
										-- More than one entry, so it must be an animation
									l_name := l_anim_pixmaps.key_for_iteration
										-- Create feature names
									create l_iname.make_from_string (l_name)
									l_iname.append (icon_animation_suffix)
									l_iname := format_eiffel_name (l_iname)

									create l_ibname.make_from_string (l_name)
									l_ibname.append (icon_buffer_suffix)
									l_ibname.append (icon_animation_suffix)
									l_ibname := format_eiffel_name (l_ibname)

										-- Pixmap icons animations
									create l_temp_buffer.make (400)
									from l_animations.start until l_animations.after loop
										l_temp_buffer.append (string_formatter.format (icon_animation_registration_template , [l_animations.item, l_animations.index]))
										l_animations.forth
									end
									if not l_temp_buffer.is_empty and then l_temp_buffer.item (l_temp_buffer.count) = '%N' then
										l_temp_buffer.keep_head (l_temp_buffer.count - 1)
									end
									if not l_temp_buffer.is_empty and then l_temp_buffer.item (l_temp_buffer.count) = ',' then
										l_temp_buffer.keep_head (l_temp_buffer.count - 1)
									end
									buffer (animations_token).append (string_formatter.format (icon_animation_template, [l_iname, l_name, l_animations.count, l_temp_buffer]))

										-- Pixel buffer icon animations
									l_temp_buffer.wipe_out
									from l_animations.start until l_animations.after loop
										l_temp_buffer.append (string_formatter.format (icon_buffer_animation_registration_template , [l_animations.item, l_animations.index]))
										l_animations.forth
									end
									if not l_temp_buffer.is_empty and then l_temp_buffer.item (l_temp_buffer.count) = '%N' then
										l_temp_buffer.keep_head (l_temp_buffer.count - 1)
									end
									if not l_temp_buffer.is_empty and then l_temp_buffer.item (l_temp_buffer.count) = ',' then
										l_temp_buffer.keep_head (l_temp_buffer.count - 1)
									end
									buffer (animations_token).append (string_formatter.format (icon_buffer_animation_template, [l_ibname, l_name, l_animations.count, l_temp_buffer]))
								end
								l_anim_pixmaps.forth
							end
						end

						if buffer (animations_token).is_empty then
							buffer (animations_token).append ("%T-- No animation frames detected.")
						end

							-- Remove extra whitespace from animation features buffer
						l_temp_buffer := buffer (animations_token)
						if not l_temp_buffer.is_empty and then l_temp_buffer.item (l_temp_buffer.count) = '%N' then
							l_temp_buffer.keep_head (l_temp_buffer.count - 1)
						end

							-- Remove extra whitespace from icon features buffer
						l_temp_buffer := buffer (icons_token)
						if not l_temp_buffer.is_empty and then l_temp_buffer.item (l_temp_buffer.count) = '%N' then
							l_temp_buffer.keep_head (l_temp_buffer.count - 1)
						end

							-- Replace the used buffers
						l_buffers := internal_buffers
						if not l_buffers.is_empty then
							from l_buffers.start until l_buffers.after loop
								l_fragment := l_buffers.item_for_iteration
								if not l_fragment.is_empty and then l_fragment.item (l_fragment.count) = '%N' then
									l_fragment.keep_head (l_fragment.count - 1)
								end
								l_buffer.replace_substring_all (token_variable (l_buffers.key_for_iteration), l_fragment)
								l_buffers.forth
							end
						end

						l_of :=
							if attached a_output then
								a_output
							else
								(create {PATH}.make_from_string (l_class_name.as_lower)).appended_with_extension ("e")
							end
						generate_output_file (l_of, l_buffer)
						generated_file_name := l_of
					end
				end
			end
		ensure
			generated_file_name_attached: is_successful implies generated_file_name /= Void
		end

feature {NONE} -- Basic Operations

	reset
			-- Resets generator
		do
			class_name := Void
			create internal_buffers.make (4)
			create animation_pixmaps.make (13)
			Precursor {MATRIX_FILE_GENERATOR}
		ensure then
			class_name_reset: class_name = Void
			internal_buffers_reset: internal_buffers.is_empty
			animation_pixmaps_reset: animation_pixmaps.is_empty
		end

	generate_output_file (a_file_name: PATH; a_content: STRING)
			-- Generates output file `a_file_name' containing `a_content'
		require
			a_file_name_attached: a_file_name /= Void
			not_a_file_name_is_empty: not a_file_name.is_empty
			a_content_attached: a_content /= Void
			not_a_content_is_empty: not a_content.is_empty
		local
			l_file: PLAIN_TEXT_FILE
			retried: BOOLEAN
		do
			if not retried then
				create l_file.make_with_path (a_file_name)
				if l_file.exists then
					l_file.delete
				end
				l_file.open_write
				l_file.put_string (a_content)
			else
				error_manager.set_last_error (create {ERROR_CREATING_FILE}.make ([a_file_name]), False)
			end
			if l_file /= Void and then not l_file.is_closed then
				l_file.close
			end
		rescue
			retried := True
			retry
		end

feature {NONE} -- Processing

	process_property (a_property: INI_PROPERTY): BOOLEAN
			-- Process document properties
		local
			l_name: STRING
			l_value: STRING
		do
			Result := Precursor {MATRIX_FILE_GENERATOR} (a_property)
			if
				not Result and then
				attached a_property.name as n
			then
				l_name := n.as_lower
				l_value := a_property.value
				if
					l_name.is_equal (class_name_property) and then
					class_name = Void
				then
					class_name := format_eiffel_name (l_value)
				end
			end
		end

	process_literal_item (a_item: INI_LITERAL; a_x: NATURAL_32; a_y: NATURAL_32)
			-- Processes a literal from an INI matrix file.
		local
			l_base: attached STRING
			l_prefix: attached STRING
			l_isuffix: attached like icon_suffix
			l_ibsuffix: attached like icon_buffer_suffix
			l_csuffix: attached like name_suffix
			l_iname: attached STRING
			l_ibname: attached STRING
			l_cname: attached STRING
			l_aname: attached STRING
			l_animations: attached ARRAYED_LIST [attached STRING]
			l_anim_regex: attached like animation_regex
			l_anim_pixmaps: attached like animation_pixmaps
			l_cvalue: attached STRING
		do
				-- Create feature prefix
			l_prefix := icon_prefix (a_item)
			if attached a_item.name as l_name then
				l_name.to_lower

					-- Name constants
				l_csuffix := name_suffix
				create l_cname.make (l_name.count + l_prefix.count + l_csuffix.count)
				l_cname.append (l_prefix)
				l_cname.append (l_name)
				l_cname.append (l_csuffix)
				l_cname := format_eiffel_name (l_cname)
				create l_cvalue.make (25)
				if attached {INI_SECTION} a_item.container as l_section then
					l_cvalue.append (section_label (l_section))
					l_cvalue.append_character (' ')
				end
				l_cvalue.append (l_name)
				buffer (icon_names_token).append (string_formatter.format (icon_name_constant_template, [l_cname, l_cvalue]))

					-- Coordinates
				buffer (coordinates_token).append (string_formatter.format (icon_name_registration_template, [a_x, a_y, l_cname]))

				create l_base.make (l_prefix.count + l_name.count)
				l_base.append (l_prefix)
				l_base.append (l_name)

					-- Icon
				l_isuffix := icon_suffix
				create l_iname.make (l_base.count + l_isuffix.count)
				l_iname.append (l_base)
				l_iname.append (l_isuffix)
				l_iname := format_eiffel_name (l_iname)
				buffer (icons_token).append (string_formatter.format (icon_template, [l_iname, a_item.name, l_cname]))

					-- Icon buffer
				l_ibsuffix := icon_buffer_suffix
				create l_ibname.make (l_iname.count + l_ibsuffix.count)
				l_ibname.append (l_iname)
				l_ibname.append (l_ibsuffix)
				l_ibname := format_eiffel_name (l_ibname)
				buffer (icons_token).append (string_formatter.format (icon_buffer_template, [l_ibname, a_item.name, l_cname]))

					-- Check animation items
				l_anim_regex := animation_regex
				l_anim_regex.match (l_name)
				if l_anim_regex.has_matched then
					create l_aname.make (l_prefix.count + l_name.count)
					l_aname.append (l_prefix)
					l_aname.append (l_anim_regex.captured_substring (1))
					l_aname := format_eiffel_name (l_aname)

						-- Add item to the animation list
					l_anim_pixmaps := animation_pixmaps
					if attached l_anim_pixmaps.item (l_aname) as l_anim_pixmaps_item then
							-- An animation list already exists
						l_animations := l_anim_pixmaps_item
					else
							-- Create a new list
						create l_animations.make (1)
						l_anim_pixmaps.force (l_animations, l_aname)
					end
					l_animations.extend (l_cname)
				end
			else
				check False end
			end
		end

feature {NONE} -- Validation

	validate_properties (a_doc: INI_DOCUMENT)
			-- Validates properties examined in `generate' or those that are in `a_doc' that have not been examined from some reason.
		do
			Precursor {MATRIX_FILE_GENERATOR} (a_doc)
			if a_doc.property_of_name (icons_token, True) /= Void then
				add_error (create {ERROR_MISSING_INI_RESERVED_PROPERTY}.make ([icons_token]), False)
			end
			if a_doc.property_of_name (animations_token, True) /= Void then
				add_error (create {ERROR_MISSING_INI_RESERVED_PROPERTY}.make ([animations_token]), False)
			end
			if a_doc.property_of_name (icon_names_token, True) /= Void then
				add_error (create {ERROR_MISSING_INI_RESERVED_PROPERTY}.make ([icon_names_token]), False)
			end
			if a_doc.property_of_name (coordinates_token, True) /= Void then
				add_error (create {ERROR_MISSING_INI_RESERVED_PROPERTY}.make ([coordinates_token]), False)
			end
		end

feature {NONE} -- Query

	buffer (a_name: attached STRING): attached STRING
			-- Retrieves a text buffer given a name.
			--
			-- 'a_name':
			-- 'Result':
		require
			not_a_name_is_empty: not a_name.is_empty
		do
			Result := internal_buffers.item (a_name)
			if not attached Result then
				create Result.make (1024)
				internal_buffers.put (Result, a_name)
			end
		ensure
			internal_buffers_has_a_name: internal_buffers.has (a_name)
			result_consistent: Result = buffer (a_name)
		end

	token_variable (a_name: STRING): attached STRING
			-- Returns a token varaible for token name `a_name'
		require
			a_name_attached: a_name /= Void
			not_a_name_is_empty: not a_name.is_empty
		do
			create Result.make (a_name.count + 23)
			Result.append ("${")
			Result.append (a_name.as_upper)
			Result.append_character ('}')
		ensure
			not_result_is_empty: not Result.is_empty
		end

feature {NONE} -- Helpers

	frozen string_formatter: STRING_FORMATTER
			-- Access to string formatter
		once
			create Result
		end

feature {NONE} -- Regular expressions

	animation_regex: attached RX_PCRE_MATCHER
			-- Regular expression to match animation items
		once
			create Result.make
			Result.set_caseless (True)
			Result.compile ("^([a-z][ \t]*[a-z0-9_]*)[ \t]*([0-9]+)$")
		ensure
			result_is_compiled: Result.is_compiled
		end

feature {NONE} -- Constants: Defaults

	icon_buffer_suffix: STRING = "_buffer"
	icon_animation_suffix: STRING = "_anim"
	name_suffix: STRING = "_name"
	default_class_name: STRING = "ICON_MATRIX"
	default_nan: STRING = "NaN"

feature {NONE} -- Constants: Token names

	icons_token: STRING = "ICONS"
	animations_token: STRING = "ANIMATIONS"
	icon_names_token: STRING = "ICON_NAMES"
	coordinates_token: STRING = "COORDINATES"

feature {NONE} -- Constants: Templates

	icon_name_constant_template: STRING = "%T{1}: STRING = %"{2}%"%N"
			-- Template for icon name constants

	icon_name_registration_template: STRING = "%T%T%Ta_table.put ([{{NATURAL_8}} {1}, {{NATURAL_8}} {2}], {3})%N"
			-- Template for icon name constants

	icon_animation_registration_template: STRING = "%T%T%T%Tnamed_icon ({1}),%N"
			-- Template for icon animation indexes

	icon_buffer_animation_registration_template: STRING = "%T%T%T%Tnamed_icon_buffer ({1}),%N"
			-- Template for icon buffer animation indexes

	icon_template: STRING =
			-- Template used for access features
			"[
	frozen {1}: EV_PIXMAP
			-- Access to '{2}' pixmap.
		require
			has_named_icon: has_named_icon ({3})
		once
			Result := named_icon ({3})
		ensure
			{1}_attached: Result /= Void
		end


	]"

	icon_buffer_template: STRING =
			-- Template used for access pixel buffer features
			"[
	frozen {1}: EV_PIXEL_BUFFER
			-- Access to '{2}' pixmap pixel buffer.
		require
			has_named_icon: has_named_icon ({3})
		once
			Result := named_icon_buffer ({3})
		ensure
			{1}_attached: Result /= Void
		end


	]"

	icon_animation_template: STRING =
			-- Template used for access pixel buffer features
		"[
			frozen {1}: ARRAY [EV_PIXMAP]
					-- Access to '{2}' pixmap animation items.
				once
					Result := <<
		{4}
					>>
				ensure
					{1}_attached: Result /= Void
				end
		
		
		]"

	icon_buffer_animation_template: STRING =
			-- Template used for access pixel buffer features
		"[
			frozen {1}: ARRAY [EV_PIXEL_BUFFER]
					-- Access to '{2}' pixel buffer animation items.
				once
					Result := <<
		{4}
					>>
				ensure
					{1}_attached: Result /= Void
				end
		
		
		]"

feature {NONE} -- Implementation: Internal cache

	internal_buffers: attached HASH_TABLE [attached STRING, attached STRING]
			-- Table of cached buffers
			--
			-- Key: The name of the buffer
			-- Value: The actual text buffer

invariant
	generated_file_name_not_empty: attached generated_file_name as n implies not n.is_empty
	class_name_not_empty: attached class_name as n implies not n.is_empty

note
	copyright:	"Copyright (c) 1984-2018, Eiffel Software"
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

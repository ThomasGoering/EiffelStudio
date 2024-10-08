note
	description: "[
		Associated with a class, can modify certain elements of that class text.

		In order to add a feature with the wizard, call `new_feature'.
		`new_query' does the same but no procedure can be created with the wizard.

		Call `prepare_for_modification' first, which ensures that the
		text is be managed which is a precondition for the other features.

		Now check the flag `valid_syntax'. If it is `False' we cannot do
		a modification because the syntax for the class is currently invalid.

		When done modifying, call `commit_modification'.
	]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	CLASS_TEXT_MODIFIER

obsolete
	"Use ES_CLASS_TEXT_MODIFIER instead."

inherit
	ANY
		redefine
			default_create
		end

	INTERNAL_COMPILER_STRING_EXPORTER
		export
			{NONE} all
		undefine
			default_create
		end

	EB_CLASS_TEXT_MANAGER
		export
			{NONE} all
		undefine
			default_create
		end

	SHARED_ERROR_HANDLER
		export
			{NONE} all
		undefine
			default_create
		end

	EB_SHARED_PREFERENCES
		export
			{NONE} all
		undefine
			default_create
		end

	EB_CONSTANTS
		export
			{NONE} all
		undefine
			default_create
		end

	EV_SHARED_APPLICATION
		export
			{NONE} all
		undefine
			default_create
		end

	EB_SHARED_MANAGERS
		export
			{NONE} all
		undefine
			default_create
		end

	FEATURE_CLAUSE_NAMES
		undefine
			default_create
		end

	SHARED_INST_CONTEXT
		undefine
			default_create
		end

	SHARED_NAMES_HEAP
		export
			{NONE} all
		undefine
			default_create
		end

	ES_SHARED_OUTPUTS
		export
			{NONE} all
		undefine
			default_create
		end

	SHARED_LOCALE
		export
			{NONE} all
		undefine
			default_create
		end

create
	make_with_tool,
	make

feature {NONE} -- Initialization

	default_create
			-- Create an CLASS_TEXT_MODIFIER.
		do
			create {ARRAYED_LIST [TUPLE [STRING_8, INTEGER]]} last_added_code.make (10)
			create {ARRAYED_LIST [TUPLE [STRING_8, INTEGER]]} last_removed_code.make (10)
		end

	make (a_class: CLASS_I)
			--
		require
			a_class_not_void: a_class /= Void
		do
			default_create
			class_i := a_class
			reset_date
		ensure
			set: class_i = a_class
		end

	make_with_tool (a_class: CLASS_I; a_tool: like context_editor)
			-- Make for `a_class'.
		require
			a_class_not_void: a_class /= Void
			a_tool_not_void: a_tool /= Void
		do
			default_create
			class_i := a_class
			context_editor := a_tool
			reset_date
		ensure
			a_class_assigned: a_class = class_i
			a_tool_assigned: a_tool = context_editor
		end

feature -- Access

	last_feature_as: FEATURE_AS
			-- AST of last added feature.

	last_removed_code: ARRAYED_LIST [TUPLE [str: STRING_8; pos: INTEGER]]
			-- List of code and positions that has been removed.

	last_added_code: ARRAYED_LIST [TUPLE [str: STRING_8; pos: INTEGER]]
			-- List of added code and position.

	class_as: CLASS_AS
			-- Current class AST.

feature -- Status report

	valid_syntax: BOOLEAN
			-- Was syntax valid when the class was parsed last time?
		do
			Result := class_as /= Void
		end

	is_modified: BOOLEAN
			-- Has `class_text' been modified since it was parsed last time?

	text_managed: BOOLEAN
			-- Is `text' loaded or retrieved from editor?
		do
			Result := text /= Void
		end

	extend_from_diagram_successful: BOOLEAN
			-- Was last call to `extend_feature_from_diagram_with_wizard' successful?

	new_parent_non_conforming: BOOLEAN
			-- Did last call to `new_parent_from_diagram' create a non-conforming relationship?

	class_modified_outside_diagram: BOOLEAN

feature -- Status setting

	prepare_for_modification
			-- Retrieve `class_text' from file or from an editor if
			-- the class is open.
			-- Callers should check `valid_syntax' afterwards to see if
		local
			l_text_32: STRING_32
		do
			if text = Void then
				l_text_32 := class_text (class_i)

				text := ec_encoding_converter.utf32_to_utf8 (l_text_32)

					-- Ensured that there is some text in the class we are loading
					-- so that we can properly find out if we are using a Unix text
					-- file format.
				if not text.is_empty and then text.item (text.count) = '%N' then
					is_unix_file := (text.count = 1) or else (text.item (text.count - 1) /= '%R')
				else
						-- Text is messed up, we use the platform default
					is_unix_file := {PLATFORM}.is_unix
				end
				text.prune_all ('%R')
			end
			reparse
			last_removed_code.wipe_out
			last_added_code.wipe_out
			class_modified_outside_diagram := False
		ensure
			text_managed: text_managed
			syntax_still_valid: old valid_syntax implies valid_syntax
			modified_flag_cleared: not is_modified
			last_removed_code_empty: last_removed_code.is_empty
			last_added_code_empty: last_added_code.is_empty
		end

	commit_modification
			-- Save `class_text' to file when not opened in an editor
			-- or display changes in editors, and reset `date'.
		require
			text_managed: text_managed
		do
				-- Set UTF8 Text back to UTF32 and set back in the editor.
			set_class_text (class_i, ec_encoding_converter.utf8_to_utf32 (text))
			reset_date
			text := Void
			class_as := Void
		ensure
			text_unreferenced: not text_managed
		end

	reset_date
			-- A modifying session is about to begin.
			-- Update `date'.
		local
			class_file: PLAIN_TEXT_FILE
			l_prev_date: like date
		do
			l_prev_date := date
			create class_file.make_with_path (class_i.file_name)
			if class_file.exists then
				date := class_file.date
			end
			if date /= l_prev_date then
					-- If the file modification date has changed then we must reset 'text' as it is now in an invalid state.
				text := Void
			end
		end

feature -- Element change

	insert_code (a_text: STRING_32)
			-- Insert in `class_text' on `insertion_position', `a_text'.
		require
			text_managed: text_managed
		local
			l_utf8_text: STRING_8
		do
			l_utf8_text := ec_encoding_converter.utf32_to_utf8 (a_text)
			last_added_code.extend ([l_utf8_text, insertion_position])
			text.insert_string (l_utf8_text, insertion_position)
			insertion_position := insertion_position + l_utf8_text.count
			is_modified := True
		ensure
			is_modified: is_modified
		end

	remove_code (start_pos, end_pos: INTEGER)
			-- Remove code between `start_pos' and `end_pos'.
		require
			start_pos_smaller_than_end_pos: start_pos <= end_pos
			text_managed: text_managed
		do
			last_removed_code.put_front ([text.substring (start_pos, end_pos), start_pos])
			text.replace_substring ("", start_pos, end_pos)
			is_modified := True
		ensure
			is_modified: is_modified
		end

	code (start_pos, end_pos: INTEGER): STRING_8
			-- Code between `start_pos' and `end_pos'.
		require
			start_pos_smaller_than_end_pos: start_pos <= end_pos
			text_managed: text_managed
		do
			Result := text.substring (start_pos, end_pos)
		end

	index_of (c: CHARACTER_8; start: INTEGER): INTEGER
			-- Position of first occurrence of `c' at or after `start';
			-- 0 if none.
		require
			start_large_enough: start >= 1
		do
			if start <= text.count + 1 then
				Result := text.index_of (c, start)
			end
		end

feature -- Modification (Add/Remove feature)

	new_feature
			-- Complete steps for adding a feature to a class.
			-- If class text is ready for code generation (no
			-- syntax errors), pops up the Feature Composition Wizard (FCW)
			-- If user clicks OK and entered data is correct,
			-- generates the feature.
			-- Sets `last_feature_as' if everything was successful.
		local
			l_error: ES_ERROR_PROMPT
		do
			last_feature_as := Void
			prepare_for_modification
			if valid_syntax then
				execute_wizard (create {EB_FEATURE_COMPOSITION_WIZARD}.make)
			else
				create l_error.make_standard (Warning_messages.w_Class_syntax_error)
				l_error.show_on_active_window
			end
		end

	remove_ancestor (a_name: STRING_8; is_non_conforming: BOOLEAN)
			-- Remove `a_name' from the parent list of `class_as'.
		require
			a_name_not_void: a_name /= Void
		local
			p: PARENT_AS
			class_file: PLAIN_TEXT_FILE
		do
			create class_file.make_with_path (class_i.file_name)
			check class_file.exists end
			if class_file.date /= date then
				put_class_modified_outside_diagram_warning
				date := class_file.date
				class_modified_outside_diagram := True
			end
			prepare_for_modification
			if valid_syntax then
				if not is_non_conforming then
					p := class_as.conforming_parent_with_name (a_name)
				else
					p := class_as.non_conforming_parent_with_name (a_name)
				end

				if p /= Void then
					if not is_non_conforming then
						if class_as.conforming_parents.count = 1 then
								-- There is only one class in the conforming inheritance clause so we remove all of the clause
							remove_code (
								position_before_inherit (False),
								class_as.conforming_inherit_clause_insert_position - 1)
						else
								-- Remove the inherited parent declaration
							remove_code (p.complete_start_position (match_list), p.complete_end_position (match_list))
						end
					else
						if class_as.non_conforming_parents.count = 1 then
								-- There is only one class in the non-conforming inheritance clause so we remove all of the clause
							remove_code (
								position_before_inherit (True),
								class_as.non_conforming_inherit_clause_insert_position - 1)
						else
								-- Remove the inherited parent declaration.
							remove_code (p.complete_start_position (match_list), p.complete_end_position (match_list))
						end
					end
					commit_modification
				end
			end
		end

	add_ancestor (a_name: STRING_8; is_non_conforming: BOOLEAN)
			-- Reinclude `code' to inheritance clause.
		require
			a_name /= Void
		local
			class_file: PLAIN_TEXT_FILE
		do
			create class_file.make_with_path (class_i.file_name)
			check class_file.exists end
			if class_file.date /= date then
				put_class_modified_outside_diagram_warning
				date := class_file.date
				class_modified_outside_diagram := True
			end
			prepare_for_modification
			if valid_syntax then
				if not is_non_conforming then
						-- Conforming inheritance
					if class_as.conforming_parents = Void then
						if class_as.non_conforming_parents /= Void then
								-- We need to find the position before non-conforming inheritance clause.
							insertion_position := position_before_inherit (False)
						else
							insertion_position := class_as.conforming_inherit_clause_insert_position
						end
						insert_code ({STRING_32} "inherit%N")
					else
						insertion_position := class_as.conforming_inherit_clause_insert_position
					end
				else
						-- Non conforming inheritance
					insertion_position := class_as.non_conforming_inherit_clause_insert_position
					if class_as.non_conforming_parents = Void then
						insert_code ({STRING_32} "inherit {NONE}%N")
					end
				end
				insert_code ({STRING_32} "%T" + a_name + "%N%N")
				commit_modification
			end
		end

	remove_features (data: LIST [FEATURE_AS])
			-- Remove features in `data', store removed.
		require
			data_not_void: data /= Void
		local
			class_file: PLAIN_TEXT_FILE
			actual_feature_as: FEATURE_AS
			l_item: FEATURE_AS
			feat_code: STRING_8
			f_name: FEATURE_NAME
			names: EIFFEL_LIST [FEATURE_NAME]
			name_index, name_start_position, name_end_position, tmp: INTEGER
		do
			create class_file.make_with_path (class_i.file_name)
			check class_file.exists end
			if class_file.date /= date then
				put_class_modified_outside_diagram_warning
				date := class_file.date
				class_modified_outside_diagram := True
			end
			prepare_for_modification
			if valid_syntax then
				from
					data.start
				until
					data.after
				loop
					l_item := data.item
					actual_feature_as := class_as.feature_with_name (l_item.feature_name.name_id)
					if actual_feature_as /= Void then
						if actual_feature_as.feature_names.count = 1 then
							feat_code := code (actual_feature_as.start_position, actual_feature_as.end_position)

								--| FIXME We assume here that features are indented in a standard way.
							if feat_code.item (feat_code.count) = '%T' then
								feat_code.remove (feat_code.count)
							end
							remove_feature_with_ast (actual_feature_as)
						else
							feat_code := code (actual_feature_as.start_position, actual_feature_as.end_position)
							f_name := Void
							names := actual_feature_as.feature_names
							name_index := 1
							from
								names.start
							until
								f_name /= Void or else names.after
							loop
								if names.item.feature_name.is_equal (l_item.feature_name) then
									f_name := names.item
								else
									name_index := name_index + 1
									names.forth
								end
							end

							check f_name /= Void end
							if name_index = names.count then
									-- `f_name' is last.
								name_start_position := actual_feature_as.start_position +
									feat_code.last_index_of (',', feat_code.count) - 1
								name_end_position := actual_feature_as.start_position +
									feat_code.index_of (':', 1) - 1
								feat_code := code (name_start_position, name_end_position - 1)
								remove_code (name_start_position, name_end_position - 1)
								reparse
							else
								tmp := feat_code.substring_index (l_item.feature_name.name_8, 1)
								name_start_position := actual_feature_as.start_position + tmp
								name_end_position := actual_feature_as.start_position +
									feat_code.index_of (',', tmp) + 1
								feat_code := code (name_start_position, name_end_position)
								remove_code (name_start_position, name_end_position)
								reparse
							end
						end
					end
					data.forth
				end
				commit_modification
			end
		end

	undelete_code (data: LIST [TUPLE [str: STRING_8; pos: INTEGER]])
			-- Reinclude code in `data'.
		require
			data_not_void: data /= Void
		local
			class_file: PLAIN_TEXT_FILE
			l_item: TUPLE [str: STRING_8; pos: INTEGER]
			str: STRING_8
		do
			create class_file.make_with_path (class_i.file_name)
			check class_file.exists end
			if class_file.date /= date then
				put_class_modified_outside_diagram_warning
				date := class_file.date
				class_modified_outside_diagram := True
			end
			prepare_for_modification
			if valid_syntax then
				from
					data.start
				until
					data.after
				loop
					l_item := data.item
					str := l_item.str
					insertion_position := l_item.pos
					check
						insertion_position <= text.count
					end
					insert_code (str)
					data.forth
				end
				commit_modification
			end
		end

	delete_code (data: LIST [TUPLE [str: STRING_8; pos: INTEGER]])
			--
		local
			class_file: PLAIN_TEXT_FILE
			l_item: TUPLE [str: STRING_8; pos: INTEGER]
			str: STRING_8
			pos: INTEGER
		do
			create class_file.make_with_path (class_i.file_name)
			check class_file.exists end
			if class_file.date /= date then
				put_class_modified_outside_diagram_warning
				date := class_file.date
				class_modified_outside_diagram := True
			end
			prepare_for_modification
			if valid_syntax then
				from
					data.finish
				until
					data.before
				loop
					l_item := data.item
					str := l_item.str
					pos := l_item.pos
					check
						text.has_substring (str)
					end
					check
						text.substring (pos, pos + str.count - 1).is_equal (str)
					end
					remove_code (pos, pos + str.count - 1)
					data.back
				end
				commit_modification
			end
		end

	new_parent_from_diagram (child_type, parent_type: ES_CLASS; x_pos, y_pos, screen_w, screen_h: INTEGER)
		local
			l_inh_dlg: EB_INHERITANCE_DIALOG
			l_error: ES_ERROR_PROMPT
			x, y: INTEGER
		do
			context_editor.develop_window.window.set_pointer_style (context_editor.default_pixmaps.Wait_cursor)
			last_feature_as := Void
			prepare_for_modification
			if valid_syntax then
				create l_inh_dlg.make

				l_inh_dlg.set_child_type (child_type)
				l_inh_dlg.set_parent_type (parent_type)
				if x_pos + l_inh_dlg.width > screen_w then
					x := screen_w - l_inh_dlg.width - 150
				else
					x := (x_pos - 150).max (0)
				end
				if y_pos + l_inh_dlg.height > screen_h then
					y := screen_h - l_inh_dlg.height - 180
				else
					y := (y_pos - 150).max (0)
				end
				l_inh_dlg.set_position (x, y)
				context_editor.develop_window.window.set_pointer_style (context_editor.default_pixmaps.Standard_cursor)
				l_inh_dlg.show_modal_to_window (context_editor.develop_window.window)
				if l_inh_dlg.ok_clicked then
					extend_from_diagram_successful := True
					new_parent_non_conforming := l_inh_dlg.is_non_conforming
					add_ancestor (l_inh_dlg.type, new_parent_non_conforming)
				else
					extend_from_diagram_successful := False
					new_parent_non_conforming := False
				end
			else
				create l_error.make_standard (Warning_messages.w_Class_syntax_error_before_generation (class_i.name))
				l_error.show_on_active_window
				extend_from_diagram_successful := False
				new_parent_non_conforming := False
				invalidate_text
				context_editor.develop_window.window.set_pointer_style (context_editor.default_pixmaps.Standard_cursor)
			end
		end

	new_feature_from_diagram (client_type, supplier_type: ES_CLASS; x_pos, y_pos, screen_w, screen_h: INTEGER; query_only: BOOLEAN)
			-- Complete steps for adding a supplier of `supplier_type' to `client_type'.
		require
			supplier_type_not_void: supplier_type /= Void
		local
			l_error: ES_ERROR_PROMPT
			qcw: EB_FEATURE_COMPOSITION_WIZARD
			x, y: INTEGER
		do
			context_editor.develop_window.window.set_pointer_style (context_editor.default_pixmaps.Wait_cursor)
			last_feature_as := Void
			prepare_for_modification
			if valid_syntax then
				if query_only then
					create {EB_QUERY_COMPOSITION_WIZARD} qcw.make
				else
					create qcw.make
				end

				qcw.set_client_type (client_type)
				qcw.set_supplier_type (supplier_type)

				qcw.set_name_number (context_editor.graph.next_feature_name_number)
				if x_pos + qcw.width > screen_w then
					x := screen_w - qcw.width - 150
				else
					x := (x_pos - 150).max (0)
				end
				if y_pos + qcw.height > screen_h then
					y := screen_h - qcw.height - 180
				else
					y := (y_pos - 150).max (0)
				end
				qcw.set_position (x, y)
				context_editor.develop_window.window.set_pointer_style (context_editor.default_pixmaps.Standard_cursor)
				execute_wizard_from_diagram (qcw)
			else
				create l_error.make_standard (Warning_messages.w_Class_syntax_error_before_generation (class_i.name))
				l_error.show_on_active_window
				extend_from_diagram_successful := False
				invalidate_text
				context_editor.develop_window.window.set_pointer_style (context_editor.default_pixmaps.Standard_cursor)
			end
		end

	extend_feature_with_wizard (fcw: EB_FEATURE_COMPOSITION_WIZARD)
			-- Add feature described in `fcw' to the class.
		require
			wizard_not_void: fcw /= Void
		local
			l_error: ES_ERROR_PROMPT
			inv: STRING_32
			retried: BOOLEAN
		do
			if not retried then
				prepare_for_modification
				if valid_syntax then
					if fcw.generate_setter_procedure then
						set_position_by_feature_clause ("", fc_Element_change)
						insert_code (setter_procedure (
							fcw.feature_name,
							fcw.setter_name,
							fcw.feature_arguments,
							fcw.feature_type,
							fcw.precondition
							))
						reparse
					end
					if valid_syntax then
						inv := fcw.invariant_part
						if inv /= Void then
							extend_invariant (inv)
							reparse
						end
						set_position_by_feature_clause (fcw.clause_export, fcw.clause_comment)
						insert_code (fcw.code)
						if valid_syntax then
							commit_modification
						else
							create l_error.make_standard (Warning_messages.w_New_feature_syntax_error)
							l_error.show_on_active_window
							invalidate_text
						end
					else
						create l_error.make_standard (Warning_messages.w_New_feature_syntax_error)
						l_error.show_on_active_window
						invalidate_text
					end
				else
					create l_error.make_standard (Warning_messages.w_Class_syntax_error_before_generation (class_i.name))
					l_error.show_on_active_window
					invalidate_text
				end
			end
		end

feature -- Modification (Change class name)

	set_class_name_declaration (a_name, a_generics: STRING_32)
			-- Set `a_name' `a_generics' as new class header.
		require
			a_name_not_void: a_name /= Void
			a_generics_not_void: a_generics /= Void
			text_managed: text_managed
			valid_syntax: valid_syntax
			not_modified: not is_modified
		local
			click_ast: CLICK_AST
			sp, ep: INTEGER
		do
			click_ast := class_as.click_ast
			sp := click_ast.start_position
			if class_as.generics_end_position > 0 then
				ep := class_as.generics_end_position
			else
				ep := click_ast.end_position
			end

			remove_code (sp, ep)
			insertion_position := sp
			insert_code (a_name)
			if not a_generics.is_empty then
				insert_code ({STRING_32} " " + a_generics)
			end
		end

feature {NONE} -- Implementation

	text: STRING_8
			-- Current class text in UTF8 Format.

	is_unix_file: BOOLEAN
			-- is current file a Unix file ?
			-- (i.e. is "%N" line separator ?)	

	insertion_position: INTEGER
			-- Current place to insert code at.

	match_list: LEAF_AS_LIST
			-- Match list from `reparse'

	parser: EIFFEL_PARSER
			-- Eiffel parser
		once
			create Result.make_with_factory (create {AST_ROUNDTRIP_COMPILER_FACTORY})
		end

	reparse
			-- Parse `class_text' and assign AST to `class_as'.
		require
			text_managed: text_managed
		local
			retried: BOOLEAN
			l_class_c: CLASS_C
			l_wrapper: EIFFEL_PARSER_WRAPPER
		do
			if not retried then
				if class_i.is_compiled then
					l_class_c := class_i.compiled_class
				end
				inst_context.set_group (class_i.group)
				create l_wrapper
					-- Text is in UTF8 so we parse as such to get the correct utf8 positions to match up with the AST.
				l_wrapper.parse_with_option (parser, text, class_i.options, True, l_class_c)
				if attached {CLASS_AS} l_wrapper.ast_node as l_class_as and then attached l_wrapper.ast_match_list then
					class_as := l_class_as
					match_list := l_wrapper.ast_match_list
				end
				is_modified := False
			else
				class_as := Void
			end
		rescue
			retried := True
			Error_handler.error_list.wipe_out
			retry
		end

	ec_encoding_converter: EC_ENCODING_CONVERTER
			-- Access to the encoding coverter for unicode conversions.
		once
			create Result.make
		ensure
			result_attached: attached Result
		end

	remove_feature_with_ast (f: FEATURE_AS)
			-- Remove `f' from the class.
		require
			text_managed: text_managed
			valid_syntax: valid_syntax
			not_modified: not is_modified
		do
			if f /= Void then
				remove_code (f.start_position, f.end_position)
				reparse
			end
		end

	execute_wizard (fcw: EB_FEATURE_COMPOSITION_WIZARD)
			-- Show `fcw' and generate code if requested.
		require
			valid_syntax: valid_syntax
			unmodified: not is_modified
		do
			fcw.show_modal_to_window (Window_manager.last_focused_development_window.window)
			if fcw.ok_clicked then
				extend_feature_with_wizard (fcw)
			end
		end

	set_last_feature_as (a_name: STRING)
			-- Assign `last_feature_as'.
		do
			last_feature_as := Void
			reparse
			if class_as /= Void then
				last_feature_as := class_as.feature_with_name (names_heap.id_of (a_name))
			end
		end

	setter_procedure (a_name, a_setter_name, a_arguments, a_type, a_pc: STRING_32): STRING_32
			-- Add in "Element change" for `a_name'.
			-- If `a_pc' not Void, add as precondition.
		require
			a_name_not_void: a_name /= Void
			a_type_not_void: a_type /= Void
		local
			s: STRING_32
			first_character: CHARACTER_32
			preposition: STRING_32
		do
			create s.make (60)
			first_character := a_name.item (1)
			if first_character = 'a' or first_character = 'e' or first_character = 'i' or
				first_character = 'o' or first_character = 'u' then
				preposition := "an_"
			else
				preposition := "a_"
			end
			s.append ({STRING_32} "%T" + a_setter_name + " (" + preposition + a_name + ": like " + a_name)
			if a_arguments /= Void then
				s.append ({STRING_32} "; " + a_arguments)
			end
			s.append_string_general (")%N")
			s.append ({STRING_32} "%T%T%T-- Assign `" + a_name + "' with `" + preposition + a_name + "'.%N")
			if a_pc /= Void and then a_arguments = Void then
				s.append_string_general ("%T%Trequire%N")
				s.append ({STRING_32} "%T%T%T" + a_pc + "%N")
			end
			s.append_string_general ("%T%Tdo%N")
			if a_arguments = Void then
				s.append ({STRING_32} "%T%T%T" + a_name + " := " + preposition + a_name + "%N")
			else
				s.append ({STRING_32} "%T%T%T--| Assigner code%N")
			end

			if a_arguments = Void then
				s.append_string_general ("%T%Tensure%N")
				s.append ({STRING_32} "%T%T%T" + a_name + "_assigned: " + a_name + " = " + preposition + a_name + "%N")
			end
			s.append_string_general ("%T%Tend%N")
			s.append_string_general ("%N")
			Result := s
		end

	feature_insert_position (f: FEATURE_CLAUSE_AS): INTEGER
			-- Insertion position for `f'.
		do
			Result := f.feature_keyword.final_position
			Result := index_of ('%N', Result) + 1
			Result := index_of ('%N', Result) + 1
		end

	set_position_by_feature_clause (a_export, a_comment: STRING_32)
			-- Go to `insertion_position' at feature clause with `a_export' and `a_comment'.
			-- If it does not exist, add it to the class in the right place.
			-- `a_comment' will be compared case sensitive.
		require
			a_export_not_void: a_export /= Void
			a_comment_not_void: a_comment /= Void
			a_comment_clean: not a_comment.has ('%R')
			text_managed: text_managed
			valid_syntax: valid_syntax
			not_modified: not is_modified
		local
			l: EIFFEL_LIST [FEATURE_CLAUSE_AS]
			exp, s: STRING_32
			c: STRING_32
			lcs: like leading_clauses
			l_match_list: LEAF_AS_LIST
			l_comments: EIFFEL_COMMENTS
		do
			l_match_list := match_list
			exp := a_export.as_lower
			insertion_position := 0

				-- Check if specified clause is present.
			l := class_as.features
			if l /= Void then
				from l.start until insertion_position > 0 or else l.after loop
					if l.item.clients /= Void then
						s := l.item.clients.dump
					else
						s := ""
					end
					l_comments := l.item.comment (l_match_list)
					if l_comments = Void or else l_comments.is_empty then
						c := ""
					else
						c := l_comments.first.content_32
						if not c.is_equal (" ") then
							string_general_left_adjust (c)
						end
					end
					c.prune_all_trailing ('%R')
					if s.is_equal (exp) and c.is_equal (a_comment) then
						insertion_position := feature_insert_position (l.item)
					end
					l.forth
				end
			end

				-- If no insert position set, feature clause is not
				-- present. Find position based on feature clause order.
			if insertion_position = 0 then
				lcs := leading_clauses (a_comment)

				l := class_as.features
				if l /= Void then
					from
						l.start
					until
						insertion_position > 0 or else l.after
					loop
						l_comments := l.item.comment (l_match_list)
						if l_comments = Void or else l_comments.is_empty then
							c := ""
						else
							c := l_comments.first.content_32
							if not c.is_equal (" ") then
								string_general_left_adjust (c)
							end
						end
						c.prune_all_trailing ('%R')
						if not lcs.has (c) then
							insertion_position := l.item.feature_keyword.position
						end
						l.forth
					end
				end
				if insertion_position = 0 then
					insertion_position := class_as.feature_clause_insert_position
				end

				insert_feature_clause (a_export, a_comment)
			end
		end

	insert_feature_clause (a_export, a_comment: STRING_32)
			-- Insert in `insertion_position' a new empty feature clause with
			-- `a_export' and `a_comment'.
		require
			a_export_not_void: a_export /= Void
			a_comment_not_void: a_comment /= Void
			text_managed: text_managed
		local
			s, up: STRING_32
		do
			create s.make (20)
			s.append_string_general ("feature")
			if not a_export.is_empty then
				s.append_string_general (" {")
				up := a_export.as_upper
				s.append (up)
				s.extend ('}')
			end
			if not a_comment.is_empty then
				s.append_string_general (" -- ")
				s.append (a_comment)
			end
			s.append_string_general ("%N%N")
			insert_code (s)
		end

	leading_clauses (a_clause: STRING_32): ARRAYED_LIST [STRING_32]
			-- Subset of `feature_clause_order' that should appear before `c' in the class text.
		require
			a_clause_not_void: a_clause /= Void
		do
			create Result.make (20)
			Result.fill (preferences.flat_short_data.feature_clause_order)
			Result.compare_objects
			if not Result.is_empty then
				Result.start
				Result.search (a_clause)
				if Result.exhausted then
					Result.start
					Result.search (fc_Other)
					if Result.exhausted then
						Result.wipe_out
					end
				end
				from
				until
					Result.off
				loop
					Result.remove
				end
				Result.prune_all (fc_Other)
			end
		end

	position_before_inherit (is_non_conforming: BOOLEAN): INTEGER
			-- Position in `text' before inherit keyword.
		local
			i: INTEGER
			l_inherit_string: STRING
			l_end_pos: INTEGER
		do
			from
				if not is_non_conforming then
					l_end_pos := class_as.conforming_inherit_clause_insert_position
				else
					l_end_pos := class_as.non_conforming_inherit_clause_insert_position
				end
				i := l_end_pos - 1
				l_inherit_string := "inherit"
			until
				Result > 0 and then Result < l_end_pos
			loop
				Result := text.substring_index (l_inherit_string, i)
				i := i - 1
			end
		end

	class_i: CLASS_I
			-- Subject for modification.

	date: INTEGER
			-- Date of last modification on `class_i' by `Current'.

	context_editor: ES_DIAGRAM_TOOL_PANEL
			--

	invalidate_text
			-- Errors were found during last parsing.
			-- Class text will have to be reloaded.
		do
			text := Void
		end

	execute_wizard_from_diagram (fcw: EB_FEATURE_COMPOSITION_WIZARD)
			-- Show `fcw' and generate code if requested.
			-- Add any graphical items.
		require
			valid_syntax: valid_syntax
			unmodified: not is_modified
		do
			fcw.show_modal_to_window (context_editor.develop_window.window)
			if fcw.ok_clicked then
				extend_from_diagram_successful := True
				extend_feature_on_diagram_with_wizard (fcw)
			else
				extend_from_diagram_successful := False
			end
		end

	extend_feature_on_diagram_with_wizard (fcw: EB_FEATURE_COMPOSITION_WIZARD) --; supplier_data: CASE_SUPPLIER) is
			-- Add feature described in `fcw' to the class.
		require
			wizard_not_void: fcw /= Void
		local
			l_error: ES_ERROR_PROMPT
			class_file: PLAIN_TEXT_FILE
			inv: STRING_32
			editor: EB_SMART_EDITOR
			new_code: STRING_32
		do
			editor := context_editor.develop_window.editors_manager.current_editor
			if editor /= Void and then not editor.is_empty then
					-- Wait for the editor to read class text.
				from
				until
					editor.text_is_fully_loaded
				loop
					ev_application.process_events
				end
			end

			create class_file.make_with_path (class_i.file_name)
			check class_file.exists end
			if class_file.date /= date then
				put_class_modified_outside_diagram_warning
				date := class_file.date
				class_modified_outside_diagram := True
			end

			prepare_for_modification
			if valid_syntax then
				if fcw.generate_setter_procedure then
					set_position_by_feature_clause ("", fc_Element_change)
					new_code := setter_procedure (
						fcw.feature_name,
						fcw.setter_name,
						fcw.feature_arguments,
						fcw.feature_type,
						fcw.precondition
						)
					insert_code (new_code)
					reparse
				end
				if valid_syntax then
					set_position_by_feature_clause (fcw.clause_export, fcw.clause_comment)
					new_code := fcw.code
					insert_code (new_code)
					set_last_feature_as (fcw.feature_name)
					if valid_syntax then
						inv := fcw.invariant_part
						if inv /= Void then
							extend_invariant (inv)
							reparse
						end
						if valid_syntax then
							commit_modification
						else
							create l_error.make_standard (Warning_messages.w_New_feature_syntax_error)
							l_error.show_on_active_window
							extend_from_diagram_successful := False
							invalidate_text
						end
					else
						create l_error.make_standard (Warning_messages.w_New_feature_syntax_error)
						l_error.show_on_active_window
						extend_from_diagram_successful := False
						invalidate_text
					end
				else
					create l_error.make_standard (Warning_messages.w_New_feature_syntax_error)
					l_error.show_on_active_window
					extend_from_diagram_successful := False
					invalidate_text
				end
			else
				create l_error.make_standard (Warning_messages.w_Class_syntax_error_before_generation (class_i.name))
				l_error.show_on_active_window
				extend_from_diagram_successful := False
				invalidate_text
			end
		end

	extend_invariant (a_inv: STRING_32)
			-- Add `a_inv' to end of invariant.
		require
			a_inv_not_void: a_inv /= Void
			text_managed: text_managed
			valid_syntax: valid_syntax
			not_modified: not is_modified
		do
			insertion_position := class_as.invariant_insertion_position
			if class_as.invariant_part = Void and not class_as.has_empty_invariant then
				insert_code ("invariant%N%T")
				insert_code (a_inv)
				insert_code ("%N%N")
			else
				insert_code ("%N%T")
				insert_code (a_inv)
			end
		end

	put_class_modified_outside_diagram_warning
			-- Inform user, that class was modified outside diagram.
		do
			if not context_editor.history.is_empty then
				general_formatter.add_multiline_string (warning_messages.w_class_modified_outside_diagram, 0)
				general_formatter.add_new_line
				context_editor.reset_history
			end
		end

note
	copyright:	"Copyright (c) 1984-2013, Eiffel Software"
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

end -- class CLASS_TEXT_MODIFIER

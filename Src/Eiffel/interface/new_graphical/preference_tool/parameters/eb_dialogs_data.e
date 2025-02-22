note
	description: "All shared attributes specific to dialogs."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EB_DIALOGS_DATA

inherit
	ES_SHARED_FONTS_AND_COLORS

create
	make

feature {EB_PREFERENCES} -- Initialization

	make (a_preferences: PREFERENCES)
			-- Create
		require
			preferences_not_void: a_preferences /= Void
		do
			preferences := a_preferences
			initialize_preferences
		ensure
			preferences_not_void: preferences /= Void
		end

feature {EB_SHARED_PREFERENCES} -- Value

	confirm_terminate_freezing: BOOLEAN
			-- Should running freezing be terminated?
		do
			Result := confirm_on_terminate_freezing_preference.value
		end

	confirm_terminate_finalizing: BOOLEAN
			-- Should running finalizing be terminated?
		do
			Result := confirm_on_terminate_finalizing_preference.value
		end

	confirm_terminate_process: BOOLEAN
			-- Should running c compilation and external command (if any) be terminated?
		do
			Result := confirm_on_terminate_process_preference.value
		end

	confirm_terminate_external_command: BOOLEAN
			-- Should running external command be terminated before closing a development window?
		do
			Result := confirm_on_terminate_external_command_preference.value
		end

	confirm_freeze: BOOLEAN
			-- About the freezing dialog (Freezing implies some C compilation.
			-- ..do you want to proceed? Yes/No): should we display it or
			-- assume that the user has choosen "Yes"
		do
			Result := confirm_freeze_preference.value
		end

	confirm_finalize: BOOLEAN
			-- About the finalizing dialog (Finalizing implies some C compilation.
			-- ..do you want to proceed? Yes/No): should we display it or
			-- assume that the user has choosen "Yes"
		do
			Result := confirm_finalize_preference.value
		end

	confirm_finalize_assertions: BOOLEAN
			-- Should assertions be automatically discarded when finalizing?
		do
			Result := confirm_finalize_assertions_preference.value
		end

	confirm_finalize_precompile: BOOLEAN
			-- Should .NET precompile projects be finalize?
		do
			Result := confirm_finalize_precompile_preference.value
		end

	confirm_save_before_compile: BOOLEAN
			-- Should all files be saved before compiling without displaying
			-- a dialog?
		do
			Result := confirm_save_before_compile_preference.value
		end

	confirm_save_before_reloading: BOOLEAN
			-- Should file be saved before reloading without displaying
			-- a dialog?
		do
			Result := confirm_save_before_reloading_preference.value
		end

	confirm_save_before_prettifying: BOOLEAN
			-- Should a file be saved before prettifying without displaying
			-- a dialog?
		do
			Result := confirm_save_before_prettifying_preference.value
		end

	confirm_on_exit: BOOLEAN
			-- Should we display a dialog to confirm an exit command?
		do
			Result := confirm_on_exit_preference.value
		end

	confirm_clear_breakpoints: BOOLEAN
			-- Should we display a dialog when clearing all breakpoints?
		do
			Result := confirm_clear_breakpoints_preference.value
		end

	confirm_ignore_all_breakpoints: BOOLEAN
			-- Should we display a dialog when clicking on "Run application without
			-- stopping at breakpoints"?
		do
			Result := confirm_ignore_all_breakpoints_preference.value
		end

	confirm_ignore_contract_violation: BOOLEAN
			-- Should we display a dialog when debuggee just stopped at a contract violation ?
		do
			Result := confirm_ignore_contract_violation_preference.value
		end

	confirm_always_compile_before_executing: BOOLEAN
			-- Should we display a dialog when asked for execution ?
		do
			Result := confirm_always_compile_before_executing_preference.value
		end

	confirm_always_compile_before_prettifying: BOOLEAN
			-- Should we display a dialog when asked for prettifying?
		do
			Result := confirm_always_compile_before_prettifying_preference.value
		end

	confirm_convert_project: BOOLEAN
			-- Should we display a dialog before converting an old project?
		do
			Result := confirm_convert_project_preference.value
		end

	confirm_build_precompile: BOOLEAN
			-- Should we display a dialog before building a needed precompile?
		do
			Result := confirm_build_precompile_preference.value
		end

	confirm_iron_packages_installation: BOOLEAN
			-- Should we display a dialog before installing missing iron packages?
		do
			Result := confirm_iron_packages_installation_preference.value
		end

	confirm_delete_eis_entries: BOOLEAN
			-- Should we display a dialog before deleting EIS entries?
		do
			Result := confirm_delete_eis_entries_preference.value
		end

	confirm_acknowledge_eis_affected_items: BOOLEAN
			-- Show we display a dialog before acknowledge affected items in EIS?
		do
			Result := confirm_acknowledge_eis_affected_items_preference.value
		end

	acknowledge_not_loaded: BOOLEAN
			-- Should we display a dialog warning that text is not editable
			-- before it is completely loaded?
		do
			Result := acknowledge_not_loaded_preference.value
		end

	show_first_launching_dialog: BOOLEAN
			--
		do
			Result := show_first_launching_dialog_preference.value
		end

	show_update_manager_dialog: BOOLEAN
			-- Should we display available release update?
		do
			Result := show_update_manager_dialog_preference.value
		end

	show_starting_dialog: BOOLEAN
			--
		do
			Result := show_starting_dialog_preference.value
		end

	confirm_change_resource_need_restart: BOOLEAN
			--
		do
			Result := confirm_change_resource_need_restart_preference.value
		end

	generate_homonyms: BOOLEAN
			--
		do
			Result := generate_homonyms_preference.value
		end

	stop_execution_when_compiling: BOOLEAN
			--
		do
			Result := stop_execution_when_compiling_preference.value
		end

	already_editing_class: BOOLEAN
			--
		do
			Result := already_editing_class_preference.value
		end

	executing_command: BOOLEAN
			--
		do
			Result := executing_command_preference.value
		end

	project_settings_width: INTEGER
		do
			Result := project_settings_width_preference.value
		end

	project_settings_height: INTEGER
		do
			Result := project_settings_height_preference.value
		end

	project_settings_position_x: INTEGER
		do
			Result := project_settings_position_x_preference.value
		end

	project_settings_position_y: INTEGER
		do
			Result := project_settings_position_y_preference.value
		end

	project_settings_split_position: INTEGER
		do
			Result := project_settings_split_position_preference.value
		end

	starting_dialog_width: INTEGER
		do
			Result := starting_dialog_width_preference.value
		end

	starting_dialog_height: INTEGER
		do
			Result := starting_dialog_height_preference.value
		end

	open_project_dialog_width: INTEGER
		do
			Result := open_project_dialog_width_preference.value
		end

	open_project_dialog_height: INTEGER
		do
			Result := open_project_dialog_height_preference.value
		end

	last_saved_basic_project_directory: detachable PATH
			-- Last projects location used during in the create new basic project wizard,
			-- if users decided to remember it.
		do
			Result := last_saved_basic_project_directory_preference.value
			if Result.is_empty then
				Result := Void
			end
		end

	set_last_saved_basic_project_directory (p: detachable PATH)
			-- Remember `p` as the last projects location for the create new basic project wizard.
		do
			if p = Void then
				last_saved_basic_project_directory_preference.set_value (create {PATH}.make_empty)
			else
				last_saved_basic_project_directory_preference.set_value (p)
			end
		end

feature {EB_SHARED_PREFERENCES} -- Notification/Value

	notification_autoclose_delay_ms: INTEGER
		do
			Result := notification_autoclose_delay_ms_preference.value
		end

	notification_title_font: EV_FONT
		do
			Result := notification_title_font_preference.value
		end

	notification_text_font: EV_FONT
		do
			Result := notification_text_font_preference.value
		end

	notification_title_background_color: EV_COLOR
		do
			Result := notification_title_background_color_preference.value
		end

	notification_title_foreground_color: EV_COLOR
		do
			Result := notification_title_foreground_color_preference.value
		end

	notification_text_background_color: EV_COLOR
		do
			Result := notification_text_background_color_preference.value
		end

	notification_text_foreground_color: EV_COLOR
		do
			Result := notification_text_foreground_color_preference.value
		end

feature {EB_SHARED_PREFERENCES, EB_TOOL} -- Preference

	confirm_on_terminate_freezing_preference: BOOLEAN_PREFERENCE
			-- Should a running freezing be terminated before any new Eiffel compilation?

	confirm_on_terminate_finalizing_preference: BOOLEAN_PREFERENCE
			-- Should a running finalizing be terminated before any new Eiffel compilation?

	confirm_on_terminate_process_preference: BOOLEAN_PREFERENCE
			-- Should running c compilation or external command be terminated before we exit EiffelStduio?

	confirm_on_terminate_external_command_preference: BOOLEAN_PREFERENCE
			-- Confirm running external command termination before closing a development window.

	confirm_freeze_preference: BOOLEAN_PREFERENCE
			-- About the freezing dialog (Freezing implies some C compilation.
			-- ..do you want to proceed? Yes/No): should we display it or
			-- assume that the user has choosen "Yes"

	confirm_finalize_preference: BOOLEAN_PREFERENCE
			-- About the finalizing dialog (Finalizing implies some C compilation.
			-- ..do you want to proceed? Yes/No): should we display it or
			-- assume that the user has choosen "Yes"

	confirm_finalize_assertions_preference: BOOLEAN_PREFERENCE
			-- Should assertions be automatically discarded when finalizing?

	confirm_finalize_precompile_preference: BOOLEAN_PREFERENCE
			-- Should .NET precompile projects be finalize?

	confirm_save_before_compile_preference: BOOLEAN_PREFERENCE
			-- Should all files be saved before compiling without displaying
			-- a dialog?

	confirm_save_before_reloading_preference: BOOLEAN_PREFERENCE
			-- Should a file be saved before reloading without displaying
			-- a dialog?

	confirm_save_before_prettifying_preference: BOOLEAN_PREFERENCE
			-- Should a file be saved before prettifying without displaying
			-- a dialog?

	confirm_on_exit_preference: BOOLEAN_PREFERENCE
			-- Should we display a dialog to confirm an exit command?

	confirm_clear_breakpoints_preference: BOOLEAN_PREFERENCE
			-- Should we display a dialog when clearing all breakpoints?

	confirm_ignore_all_breakpoints_preference: BOOLEAN_PREFERENCE
			-- Should we display a dialog when clicking on "Run application without
			-- stopping at breakpoints"?

	confirm_ignore_contract_violation_preference: BOOLEAN_PREFERENCE
			-- Should we display a dialog when debuggee just stopped at a contract violation ?

	confirm_always_apply_debugger_profiles_before_closing_preference: BOOLEAN_PREFERENCE
			-- Should we always apply execution profile changes when closing the related dialog ?

	confirm_always_compile_before_executing_preference: BOOLEAN_PREFERENCE
			-- Should we display a dialog when asked for execution ?

	confirm_always_compile_before_prettifying_preference: BOOLEAN_PREFERENCE
			-- Should we display a dialog when asked for prettifying?

	confirm_convert_project_preference: BOOLEAN_PREFERENCE
			-- Should we display a dialog before converting an old project?

	confirm_build_precompile_preference: BOOLEAN_PREFERENCE
			-- Should we display a dialog before building a needed precompile?

	confirm_iron_packages_installation_preference: BOOLEAN_PREFERENCE
			-- Should we display a dialog before installing iron missing packages?			

	confirm_delete_eis_entries_preference: BOOLEAN_PREFERENCE
			-- Should we display a dialog before deleting EIS entries?

	confirm_acknowledge_eis_affected_items_preference: BOOLEAN_PREFERENCE
			-- Should we display a dialog before acknowledge affected items in EIS tool?

	confirm_replace_all_preference: BOOLEAN_PREFERENCE
			-- Should we display a dialog before replacing all?

	confirm_remove_metric_preference: BOOLEAN_PREFERENCE
			-- Should we remove requested metric?

	confirm_save_metric_preference: BOOLEAN_PREFERENCE
			-- Should we save requested metric?

	open_class_on_fix_preference: BOOLEAN_PREFERENCE
			-- A preference to open an editor for a class to be fixed.

	confirm_fix_without_undo_preference: BOOLEAN_PREFERENCE
			-- A preference to discard a fix undo warning.

	acknowledge_not_loaded_preference: BOOLEAN_PREFERENCE
			-- Should we display a dialog warning that text is not editable
			-- before it is completely loaded?

	show_starting_dialog_preference: BOOLEAN_PREFERENCE
	show_first_launching_dialog_preference: BOOLEAN_PREFERENCE
	confirm_change_resource_need_restart_preference: BOOLEAN_PREFERENCE
	generate_homonyms_preference: BOOLEAN_PREFERENCE
	stop_execution_when_compiling_preference: BOOLEAN_PREFERENCE
	confirm_kill_preference: BOOLEAN_PREFERENCE
	confirm_kill_and_restart_preference: BOOLEAN_PREFERENCE
	dbg_confirm_detach_preference: BOOLEAN_PREFERENCE
	confirm_reload_execution_profile_preference: BOOLEAN_PREFERENCE
	already_editing_class_preference: BOOLEAN_PREFERENCE
	executing_command_preference: BOOLEAN_PREFERENCE
	show_update_manager_dialog_preference: BOOLEAN_PREFERENCE

	last_opened_project_directory_preference: PATH_PREFERENCE
	last_opened_dynamic_lib_directory_preference: PATH_PREFERENCE
--	last_opened_file_directory_preference: STRING_PREFERENCE
	last_opened_metric_browse_archive_directory_preference: PATH_PREFERENCE
	last_imported_metric_definition_directory_preference: PATH_PREFERENCE

	last_saved_dynamic_lib_directory_preference: PATH_PREFERENCE
	last_saved_call_stack_directory_preference: PATH_PREFERENCE
	last_saved_debugger_exception_directory_preference: STRING_PREFERENCE
	last_saved_diagram_postscript_directory_preference: PATH_PREFERENCE
	last_saved_exception_directory_preference: PATH_PREFERENCE
	last_saved_save_file_as_directory_preference: PATH_PREFERENCE
	last_saved_profile_result_directory_preference: PATH_PREFERENCE
	file_open_and_save_dialogs_remember_last_directory: BOOLEAN_PREFERENCE

	project_settings_width_preference: INTEGER_PREFERENCE
	project_settings_height_preference: INTEGER_PREFERENCE
	project_settings_position_x_preference: INTEGER_PREFERENCE
	project_settings_position_y_preference: INTEGER_PREFERENCE
	project_settings_split_position_preference: INTEGER_PREFERENCE

	starting_dialog_width_preference: INTEGER_PREFERENCE
	starting_dialog_height_preference: INTEGER_PREFERENCE
	open_project_dialog_width_preference: INTEGER_PREFERENCE
	open_project_dialog_height_preference: INTEGER_PREFERENCE
	discard_target_scope_customized_formatter_preference: BOOLEAN_PREFERENCE

	last_saved_basic_project_directory_preference: PATH_PREFERENCE

	notification_autoclose_delay_ms_preference: INTEGER_PREFERENCE
	notification_title_font_preference: FONT_PREFERENCE
	notification_text_font_preference: FONT_PREFERENCE
	notification_title_background_color_preference: COLOR_PREFERENCE
	notification_title_foreground_color_preference: COLOR_PREFERENCE
	notification_text_background_color_preference: COLOR_PREFERENCE
	notification_text_foreground_color_preference: COLOR_PREFERENCE

feature -- Preference strings

	confirm_on_terminate_freezing_string: STRING = "interface.dialogs.confirm_on_terminate_freezing"
	confirm_on_terminate_finalizing_string: STRING = "interface.dialogs.confirm_on_terminate_finalizing"
	confirm_on_terminate_process_string: STRING = "interface.dialogs.confirm_on_terminate_process"
	confirm_on_terminate_external_command_string: STRING = "interface.dialogs.confirm_on_terminate_external_command"

	confirm_on_exit_string: STRING = "interface.dialogs.confirm_on_exit"
	confirm_finalize_string: STRING = "interface.dialogs.confirm_finalize"
	confirm_freeze_string: STRING = "interface.dialogs.confirm_freeze"
	confirm_save_before_compile_string: STRING = "interface.dialogs.confirm_save_before_compile"
	confirm_save_before_reloading_string: STRING = "interface.dialogs.confirm_save_before_reloading"
	confirm_save_before_prettifying_string: STRING = "interface.dialogs.confirm_save_before_prettifying"
	confirm_finalize_assertions_string: STRING = "interface.dialogs.confirm_finalize_assertions"
	confirm_clear_breakpoints_string: STRING = "interface.dialogs.confirm_clear_breakpoints"
	confirm_ignore_all_breakpoints_string: STRING = "interface.dialogs.confirm_ignore_all_breakpoints"
	confirm_ignore_contract_violation_string: STRING = "interface.dialogs.confirm_ignore_contract_violation"
	confirm_always_apply_debugger_profiles_before_closing_string: STRING = "interface.dialogs.confirm_always_apply_debugger_profiles_before_closing"
	confirm_always_compile_before_executing_string: STRING = "interface.dialogs.confirm_always_compile_before_executing"
	confirm_always_compile_before_prettifying_string: STRING = "interface.dialogs.confirm_always_compile_before_prettifying"
	confirm_convert_project_string: STRING = "interface.dialogs.confirm_convert_project"
	confirm_build_precompile_string: STRING = "interface.dialogs.confirm_build_precompile"
	confirm_iron_packages_installation_string: STRING = "interface.dialogs.confirm_iron_package_installation"
	confirm_delete_eis_entries_string: STRING = "interface.dialogs.confirm_delete_eis_entries"
	confirm_acknowledge_eis_affected_items_string: STRING = "interface.dialogs.confirm_acknowledge_eis_affected_items"
	confirm_replace_all_string: STRING = "interface.dialogs.confirm_replace_all"
	confirm_remove_metric_string: STRING = "interface.dialogs.confirm_remove_metric"
	confirm_save_metric_string: STRING = "interface.dialogs.confirm_save_metric"
	open_class_on_fix_string: STRING = "interface.dialogs.open_class_on_fix"
	confirm_fix_without_undo_string: STRING = "interface.dialogs.confirm_fix_without_undo"
	acknowledge_not_loaded_string: STRING = "interface.dialogs.acknowledge_not_loaded"
	confirm_finalize_precompile_string: STRING = "interface.dialogs.confirm_finalize_precompile"
	show_starting_dialog_string: STRING = "interface.dialogs.show_starting_dialog"
	show_first_launching_dialog_string: STRING = "interface.dialogs.show_first_launching_dialog"
	show_update_manager_dialog_string: STRING = "interface.dialogs.show_update_manager_dialog"
	confirm_change_resource_need_restart_string: STRING = "interface.dialogs.confirm_resource_change_needs_restart"
	generate_homonyms_string: STRING = "interface.dialogs.generate_homonyms"
	stop_execution_when_compiling_string: STRING = "interface.dialogs.stop_execution_when_compiling"
	confirm_kill_string: STRING = "interface.dialogs.confirm_kill"
	confirm_kill_and_restart_string: STRING = "interface.dialogs.confirm_kill_and_restart"
	dbg_confirm_detach_string: STRING = "interface.dialogs.dbg_confirm_detach"
	confirm_reload_execution_profile_string: STRING = "interface.dialogs.confirm_reload_execution_profile"
	already_editing_class_string: STRING = "interface.dialogs.already_editing_class"
	executing_command_string: STRING = "interface.dialogs.executing_command"
	file_open_and_save_dialogs_remember_last_directory_string: STRING = "interface.dialogs.file_open_and_save_dialogs_remember_last_directory"

	last_opened_project_directory_string: STRING = "interface.dialogs.last_opened_project_directory"
	last_opened_dynamic_lib_directory_string: STRING = "interface.dialogs.last_opened_dynamic_lib_directory"
--	last_opened_file_directory_preference_string: STRING is "interface.dialogs.last_opened_file_directory"
	last_opened_metric_browse_archive_directory_preference_string: STRING = "interface.dialogs.last_opened_metric_browse_archive_directory"
	last_imported_metric_definition_directory_preference_string: STRING = "interface.dialogs.last_imported_metric_definition_directory"

	last_saved_dynamic_lib_directory_preference_string: STRING = "interface.dialogs.last_saved_dynamic_lib_directory"
	last_saved_call_stack_directory_preference_string: STRING = "interface.dialogs.last_saved_call_stack_directory"
	last_saved_debugger_exception_directory_preference_string: STRING = "interface.dialogs.last_saved_debugger_exception_directory"
	last_saved_diagram_postscript_directory_preference_string: STRING = "interface.dialogs.last_saved_diagram_postscript_directory"
	last_saved_exception_directory_preference_string: STRING = "interface.dialogs.last_saved_exception_directory"
	last_saved_save_file_as_directory_preference_string: STRING = "interface.dialogs.last_saved_save_file_as_directory"
	last_saved_profile_result_directory_preference_string: STRING = "interface.dialogs.last_saved_profile_result_directory"

	project_settings_width_preference_string: STRING = "interface.dialogs.project_settings_width"
	project_settings_height_preference_string: STRING = "interface.dialogs.project_settings_height"
	project_settings_position_x_preference_string: STRING = "interface.dialogs.project_settings_position_x"
	project_settings_position_y_preference_string: STRING = "interface.dialogs.project_settings_position_y"
	project_settings_split_position_preference_string: STRING = "interface.dialogs.project_settings_split_position"

	starting_dialog_width_preference_string: STRING = "interface.dialogs.starting_dialog_width"
	starting_dialog_height_preference_string: STRING = "interface.dialogs.starting_dialog_height"
	open_project_dialog_width_preference_string: STRING = "interface.dialogs.open_project_dialog_width"
	open_project_dialog_height_preference_string: STRING = "interface.dialogs.open_project_dialog_height"
	discard_target_scope_customized_formatter_string: STRING = "interface.dialogs.discard_target_scope_customized_formatter"

	last_saved_basic_project_directory_string: STRING = "interface.dialogs.last_saved_basic_project_directory"

	notification_autoclose_delay_ms_string: STRING = "interface.dialogs.notification_autoclose_delay_ms"
	notification_title_font_string: STRING = "interface.dialogs.notification_title_font"
	notification_text_font_string: STRING = "interface.dialogs.notification_text_font"
	notification_title_background_color_string: STRING = "interface.dialogs.notification_title_background_color"
	notification_title_foreground_color_string: STRING = "interface.dialogs.notification_title_foreground_color"
	notification_text_background_color_string: STRING = "interface.dialogs.notification_text_background_color"
	notification_text_foreground_color_string: STRING = "interface.dialogs.notification_text_foreground_color"

feature {NONE} -- Implementation

	initialize_preferences
			-- Initialize preference values.
		local
			l_manager: EB_PREFERENCE_MANAGER
		do
			create l_manager.make (preferences, "dialogs")
			confirm_on_terminate_external_command_preference := l_manager.new_boolean_preference_value (l_manager, confirm_on_terminate_external_command_string, True)
			confirm_on_terminate_freezing_preference := l_manager.new_boolean_preference_value (l_manager, confirm_on_terminate_freezing_string, True)
			confirm_on_terminate_finalizing_preference := l_manager.new_boolean_preference_value (l_manager, confirm_on_terminate_finalizing_string, True)
			confirm_on_terminate_process_preference := l_manager.new_boolean_preference_value (l_manager, confirm_on_terminate_process_string, True)
			confirm_on_exit_preference := l_manager.new_boolean_preference_value (l_manager, confirm_on_exit_string, True)
			confirm_finalize_preference := l_manager.new_boolean_preference_value (l_manager, confirm_finalize_string, True)
			confirm_freeze_preference := l_manager.new_boolean_preference_value (l_manager, confirm_freeze_string, True)
			confirm_save_before_compile_preference := l_manager.new_boolean_preference_value (l_manager, confirm_save_before_compile_string,True)
			confirm_save_before_reloading_preference := l_manager.new_boolean_preference_value (l_manager, confirm_save_before_reloading_string,True)
			confirm_save_before_prettifying_preference := l_manager.new_boolean_preference_value (l_manager, confirm_save_before_prettifying_string, True)
			confirm_finalize_assertions_preference := l_manager.new_boolean_preference_value (l_manager, confirm_finalize_assertions_string, True)
			confirm_clear_breakpoints_preference := l_manager.new_boolean_preference_value (l_manager, confirm_clear_breakpoints_string, True)
			confirm_ignore_all_breakpoints_preference := l_manager.new_boolean_preference_value (l_manager, confirm_ignore_all_breakpoints_string, True)
			confirm_ignore_contract_violation_preference := l_manager.new_boolean_preference_value (l_manager, confirm_ignore_contract_violation_string, True)
			confirm_always_apply_debugger_profiles_before_closing_preference := l_manager.new_boolean_preference_value (l_manager, confirm_always_apply_debugger_profiles_before_closing_string, True)
			confirm_always_compile_before_executing_preference := l_manager.new_boolean_preference_value (l_manager, confirm_always_compile_before_executing_string, True)
			confirm_convert_project_preference := l_manager.new_boolean_preference_value (l_manager, confirm_convert_project_string, True)
			confirm_build_precompile_preference := l_manager.new_boolean_preference_value (l_manager, confirm_build_precompile_string, True)
			confirm_iron_packages_installation_preference := l_manager.new_boolean_preference_value (l_manager, confirm_iron_packages_installation_string, True)
			confirm_delete_eis_entries_preference := l_manager.new_boolean_preference_value (l_manager, confirm_delete_eis_entries_string, True)
			confirm_acknowledge_eis_affected_items_preference := l_manager.new_boolean_preference_value (l_manager, confirm_acknowledge_eis_affected_items_string, True)
			confirm_remove_metric_preference := l_manager.new_boolean_preference_value (l_manager, confirm_remove_metric_string, True)
			confirm_save_metric_preference := l_manager.new_boolean_preference_value (l_manager, confirm_save_metric_string, True)
			open_class_on_fix_preference :=  l_manager.new_boolean_preference_value (l_manager, open_class_on_fix_string, True)
			confirm_fix_without_undo_preference := l_manager.new_boolean_preference_value (l_manager, confirm_fix_without_undo_string, True)
			acknowledge_not_loaded_preference := l_manager.new_boolean_preference_value (l_manager, acknowledge_not_loaded_string, True)
			confirm_finalize_precompile_preference := l_manager.new_boolean_preference_value (l_manager, confirm_finalize_precompile_string, True)
			show_starting_dialog_preference := l_manager.new_boolean_preference_value (l_manager, show_starting_dialog_string, True)
			show_first_launching_dialog_preference := l_manager.new_boolean_preference_value (l_manager, show_first_launching_dialog_string, True)
			show_first_launching_dialog_preference.set_hidden (True)
			show_update_manager_dialog_preference := l_manager.new_boolean_preference_value (l_manager, show_update_manager_dialog_string, True)
			show_update_manager_dialog_preference.set_hidden (True)
			confirm_change_resource_need_restart_preference := l_manager.new_boolean_preference_value (l_manager, confirm_change_resource_need_restart_string, True)
			generate_homonyms_preference := l_manager.new_boolean_preference_value (l_manager, generate_homonyms_string, True)
			stop_execution_when_compiling_preference := l_manager.new_boolean_preference_value (l_manager, stop_execution_when_compiling_string, True)
			confirm_kill_preference := l_manager.new_boolean_preference_value (l_manager, confirm_kill_string, True)
			confirm_kill_and_restart_preference := l_manager.new_boolean_preference_value (l_manager, confirm_kill_and_restart_string, True)
			dbg_confirm_detach_preference := l_manager.new_boolean_preference_value (l_manager, dbg_confirm_detach_string, True)
			confirm_reload_execution_profile_preference := l_manager.new_boolean_preference_value (l_manager, confirm_reload_execution_profile_string, True)
			already_editing_class_preference := l_manager.new_boolean_preference_value (l_manager, already_editing_class_string, True)
			executing_command_preference := l_manager.new_boolean_preference_value (l_manager, executing_command_string, True)
			confirm_replace_all_preference := l_manager.new_boolean_preference_value (l_manager, confirm_replace_all_string, True)
			file_open_and_save_dialogs_remember_last_directory := l_manager.new_boolean_preference_value (l_manager, file_open_and_save_dialogs_remember_last_directory_string, True)
			last_opened_project_directory_preference := l_manager.new_path_preference_value (l_manager, last_opened_project_directory_string, create {PATH}.make_empty)
			last_opened_dynamic_lib_directory_preference := l_manager.new_path_preference_value (l_manager, last_opened_dynamic_lib_directory_string, create {PATH}.make_empty)
--			last_opened_file_directory_preference := l_manager.new_string_preference_value (l_manager, last_opened_file_directory_preference_string, "")
			last_opened_metric_browse_archive_directory_preference := l_manager.new_path_preference_value (l_manager, last_opened_metric_browse_archive_directory_preference_string, create {PATH}.make_empty)
			last_imported_metric_definition_directory_preference := l_manager.new_path_preference_value (l_manager, last_imported_metric_definition_directory_preference_string, create {PATH}.make_empty)
			last_saved_dynamic_lib_directory_preference := l_manager.new_path_preference_value (l_manager, last_saved_dynamic_lib_directory_preference_string, create {PATH}.make_empty)
			last_saved_call_stack_directory_preference := l_manager.new_path_preference_value (l_manager, last_saved_call_stack_directory_preference_string, create {PATH}.make_empty)
			last_saved_debugger_exception_directory_preference := l_manager.new_string_preference_value (l_manager, last_saved_debugger_exception_directory_preference_string, "")
			last_saved_diagram_postscript_directory_preference := l_manager.new_path_preference_value (l_manager, last_saved_diagram_postscript_directory_preference_string, create {PATH}.make_empty)
			last_saved_exception_directory_preference := l_manager.new_path_preference_value (l_manager, last_saved_exception_directory_preference_string, create {PATH}.make_empty)
			last_saved_save_file_as_directory_preference := l_manager.new_path_preference_value (l_manager, last_saved_save_file_as_directory_preference_string, create {PATH}.make_empty)
			last_saved_profile_result_directory_preference := l_manager.new_path_preference_value (l_manager, last_saved_profile_result_directory_preference_string, create {PATH}.make_empty)

			project_settings_width_preference := l_manager.new_integer_preference_value (l_manager, project_settings_width_preference_string, 700)
			project_settings_height_preference := l_manager.new_integer_preference_value (l_manager, project_settings_height_preference_string, 600)
			project_settings_position_x_preference := l_manager.new_integer_preference_value (l_manager, project_settings_position_x_preference_string, 100)
			project_settings_position_y_preference := l_manager.new_integer_preference_value (l_manager, project_settings_position_y_preference_string, 100)
			project_settings_split_position_preference := l_manager.new_integer_preference_value (l_manager, project_settings_split_position_preference_string, 300)

			starting_dialog_width_preference := l_manager.new_integer_preference_value (l_manager, starting_dialog_width_preference_string, 500)
			starting_dialog_height_preference := l_manager.new_integer_preference_value (l_manager, starting_dialog_height_preference_string, 500)
			open_project_dialog_width_preference := l_manager.new_integer_preference_value (l_manager, open_project_dialog_width_preference_string, 500)
			open_project_dialog_height_preference := l_manager.new_integer_preference_value (l_manager, open_project_dialog_height_preference_string, 300)
			discard_target_scope_customized_formatter_preference := l_manager.new_boolean_preference_value (l_manager, discard_target_scope_customized_formatter_string, True)

			last_saved_basic_project_directory_preference := l_manager.new_path_preference_value (l_manager, last_saved_basic_project_directory_string, create {PATH}.make_empty)


			notification_autoclose_delay_ms_preference := l_manager.new_integer_preference_value (l_manager, notification_autoclose_delay_ms_string, 45_000) -- 45 seconds
			notification_title_font_preference := l_manager.new_font_preference_value (l_manager, notification_title_font_string, fonts.highlighted_label_font)
			notification_text_font_preference := l_manager.new_font_preference_value (l_manager, notification_text_font_string, fonts.standard_label_font)
			notification_title_background_color_preference := l_manager.new_color_preference_value (l_manager, notification_title_background_color_string, colors.stock_colors.color_dialog)
			notification_title_foreground_color_preference := l_manager.new_color_preference_value (l_manager, notification_title_foreground_color_string, colors.stock_colors.default_foreground_color)
			notification_text_background_color_preference := l_manager.new_color_preference_value (l_manager, notification_text_background_color_string, colors.stock_colors.default_background_color)
			notification_text_foreground_color_preference := l_manager.new_color_preference_value (l_manager, notification_text_foreground_color_string, colors.stock_colors.default_foreground_color)
		end

	preferences: PREFERENCES
			-- Preferences

invariant
	preferences_not_void: preferences /= Void
	confirm_on_exit_preference_not_void: confirm_on_exit_preference /= Void
	confirm_finalize_preference_not_void: confirm_finalize_preference /= Void
	confirm_freeze_preference_not_void: confirm_freeze_preference /= Void
	confirm_save_before_compile_preference_not_void: confirm_save_before_compile_preference /= Void
	confirm_save_before_reloading_preference_not_void: confirm_save_before_reloading_preference /= Void
	confirm_save_before_prettifying_preference_not_void: confirm_save_before_prettifying_preference /= Void
	confirm_finalize_assertions_preference_not_void: confirm_finalize_assertions_preference /= Void
	confirm_clear_breakpoints_preference_not_void: confirm_clear_breakpoints_preference /= Void
	confirm_ignore_all_breakpoints_preference_not_void: confirm_ignore_all_breakpoints_preference /= Void
	confirm_ignore_contract_violation_preference_not_void: confirm_ignore_contract_violation_preference /= Void
	confirm_always_apply_debugger_profiles_before_closing_preference_not_void: confirm_always_apply_debugger_profiles_before_closing_preference /= Void


	confirm_always_compile_before_executing_preference_not_void: confirm_always_compile_before_executing_preference /= Void
	confirm_convert_project_preference_not_void: confirm_convert_project_preference /= Void
	confirm_build_precompile_preference_not_void: confirm_build_precompile_preference /= Void
	confirm_iron_packages_installation_preference_not_void: confirm_iron_packages_installation_preference /= Void
	confirm_delete_eis_entries_preference_not_void: confirm_delete_eis_entries_preference /= Void
	confirm_fix_open_preference_attached: attached open_class_on_fix_preference
	confirm_fix_undo_preference_attached: attached confirm_fix_without_undo_preference
	acknowledge_not_loaded_preference_not_void: acknowledge_not_loaded_preference /= Void
	confirm_finalize_precompile_preference_not_void: confirm_finalize_precompile_preference /= Void
	show_starting_dialog_preference_not_void: show_starting_dialog_preference /= Void
	show_first_launching_dialog_preference_not_void: show_first_launching_dialog_preference /= Void
	show_update_manager_dialog_preference_not_void: show_update_manager_dialog_preference /= Void
	confirm_change_resource_need_restart_preference_not_void: confirm_change_resource_need_restart_preference /= Void
	generate_homonyms_preference_not_void: generate_homonyms_preference /= Void
	stop_execution_when_compiling_preference_not_void: stop_execution_when_compiling_preference /= Void
	confirm_kill_preference_not_void: confirm_kill_preference /= Void
	dbg_confirm_detach_preference_not_void: dbg_confirm_detach_preference /= Void
	already_editing_class_preference_not_void: already_editing_class_preference /= Void
	executing_command_preference_not_void:  executing_command_preference /= Void
	project_settings_width_preference_not_void: project_settings_width_preference /= Void
	project_settings_height_preference_not_void: project_settings_height_preference /= Void
	project_settings_position_x_preference_not_void: project_settings_position_x_preference /= Void
	project_settings_position_y_preference_not_void: project_settings_position_y_preference /= Void
	project_settings_split_position_preference_not_void: project_settings_split_position_preference /= Void
	starting_dialog_width_preference_not_void: starting_dialog_width_preference /= Void
	starting_dialog_height_preference_not_void: starting_dialog_height_preference /= Void
	open_project_dialog_width_preference_not_void: open_project_dialog_width_preference /= Void
	open_project_dialog_height_preference_not_void: open_project_dialog_height_preference /= Void

	last_saved_basic_project_directory_preference_not_void: last_saved_basic_project_directory_preference /= Void

	notification_autoclose_delay_ms_preference_not_void: notification_autoclose_delay_ms_preference /= Void
	notification_title_font_preference_not_void: notification_title_font_preference /= Void
	notification_text_font_preference_not_void: notification_text_font_preference /= Void
	notification_title_background_color_preference_not_void: notification_title_background_color_preference /= Void
	notification_title_foreground_color_preference_not_void: notification_title_foreground_color_preference /= Void
	notification_text_background_color_preference_not_void: notification_text_background_color_preference /= Void
	notification_text_foreground_color_preference_not_void: notification_text_foreground_color_preference /= Void

note
	copyright: "Copyright (c) 1984-2019, Eiffel Software"
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

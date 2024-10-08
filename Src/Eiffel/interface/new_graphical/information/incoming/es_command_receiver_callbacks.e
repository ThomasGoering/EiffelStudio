﻿note
	description: "Callbacks for EiffelStudio command receiver"
	status: "See notice at end of class."
	legal: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	ES_COMMAND_RECEIVER_CALLBACKS

inherit
	ANY

	EB_SHARED_MANAGERS
		export
			{NONE} all
		end

	EB_CONSTANTS
		export
			{NONE} all
		end

	ES_SHARED_PROMPT_PROVIDER
		export
			{NONE} all
		end

	SHARED_EIFFEL_PROJECT
		export
			{NONE} all
		end

	SHARED_WORKBENCH
		export
			{NONE} all
		end

	EV_SHARED_APPLICATION
		export
			{NONE} all
		end

	EB_SHARED_PREFERENCES
		export
			{NONE} all
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization
		do
			reset
			eiffel_project.manager.load_agents.extend (agent on_project_openned)
		end

feature -- Callbacks

	on_condition_found (a_condition_module, a_condition: attached STRING_32)
			-- A condition found in the processing command
		do
			condition_found := True
			condition_module := a_condition_module
			condition := a_condition
		ensure
			condition_found: condition_found
			condition_module_not_void: condition_module /= Void
		end

	on_action_found (a_action_module, a_action: attached STRING_32)
			-- A action has been found
		do
			action_found := True
			action_module := a_action_module
			action := a_action
		ensure
			action_found: action_found
			action_module_not_void: action_module /= Void
		end

	on_command_finished
			-- Called when command detection finished
		do
					-- Start to analyse action
			if action_found then
					-- EIS incoming module
				if action_module.is_case_insensitive_equal ({COMMAND_PROTOCOL_NAMES}.eis_incoming_module) then
					if attached action.twin as lt_action then
						if lt_action.starts_with ({COMMAND_PROTOCOL_NAMES}.eiffel_protocol) then
							lt_action.remove_head ({COMMAND_PROTOCOL_NAMES}.eiffel_protocol.count)
								-- Remove the trailing '/' if any.
							if lt_action.item (lt_action.count) = '/' then
								lt_action.remove_tail (1)
							end
								-- Example: system=base.6D7FF712-BBA5-4AC0-AABF-2D9880493A01&target=base&cluster=ise&class=exception&feature=raise
							extract_eis_attributes (lt_action)

								-- Start
							if not has_error then
								eis_prepare_action
							end
						else
							-- Unknown protocol
							has_error := True
							show_error (interface_names.l_unknown_protocol_name (lt_action))
						end
					end
				else
					-- Unknown action module
					has_error := True
				end
			else
				-- No action found
				has_error := True
			end
		end

feature -- Element Change

	reset
			-- Reset current for new command.
		do
			has_error := False
			command_accepted := False
			condition_found := False
			action_found := False
			condition_module := Void
			condition := Void
			action_module := Void
			action := Void
			create eis_component_found_table.make (5)
		end

	set_starting_dialog (a_dialog: like starting_dialog)
			-- Set `starting_dialog' with `a_dialog'
		do
			starting_dialog := a_dialog
		ensure
			starting_dialog_set: starting_dialog = a_dialog
		end

feature {NONE} -- EIS implementation

	extract_eis_attributes (a_string: attached STRING)
			-- Extract attributes from the reference.
		require
			eiffel_protocol_removed: not a_string.starts_with ({COMMAND_PROTOCOL_NAMES}.eiffel_protocol)
		local
			l_splits: LIST [STRING]
			l_splitted_attrs: LIST [STRING]
			l_string: STRING
			l_attr_name, l_attr_value: STRING
		do
			l_splits := a_string.split ({COMMAND_PROTOCOL_NAMES}.component_separator)
			from
				l_splits.start
			until
				l_splits.after or has_error
			loop
				l_string := l_splits.item
				l_string.left_adjust
				l_string.right_adjust
				l_splitted_attrs := l_string.split ({COMMAND_PROTOCOL_NAMES}.attribute_separator)
					--| Example:
					--| system=base.6D7FF712-BBA5-4AC0-AABF-2D9880493A01
					--| target=base
					--| cluster=ise
					--| class=exception
					--| feature=raise
				if l_splitted_attrs.count >= 2 then
					l_attr_name := l_splitted_attrs.i_th (1)
					l_attr_name.left_adjust
					l_attr_name.right_adjust
					l_attr_name.to_lower
					eis_component_table.search (l_attr_name)
					if eis_component_table.found then
						l_attr_value := l_splitted_attrs.i_th (2)
						l_attr_value.left_adjust
						l_attr_value.right_adjust
						eis_component_found_table.force (l_attr_value, eis_component_table.found_item)
					else
						-- Unknown attribute name.
						has_error := True
						show_error (interface_names.l_unknown_attribute_name (l_attr_name))
					end
				else
					-- Invaid attribute format.
					has_error := True
					show_error (interface_names.l_unknown_format (l_string))
				end
				l_splits.forth
			end
		end

	eis_prepare_action
			-- Prepare EIS incoming command response actions
		local
			l_tuple: attached TUPLE [name, uuid: STRING]
			l_system_name, l_system_uuid,
			l_target_name, l_target_uuid,
			l_group_name, l_class_name, l_feature_name: STRING
			l_loader: EB_GRAPHICAL_PROJECT_LOADER
			l_project_path: PATH
			l_chosen_target: STRING
			l_window: EV_WINDOW
			l_uuid: UUID
		do
			eis_component_found_table.search (system_id)
			if eis_component_found_table.found and then attached eis_component_found_table.found_item as lt_string then
				l_tuple := name_and_uuid_from_raw_string (lt_string)
				l_system_name := l_tuple.name
				l_system_uuid := l_tuple.uuid
			end

			eis_component_found_table.search (target_id)
			if eis_component_found_table.found and then attached eis_component_found_table.found_item as lt_string1 then
				l_tuple := name_and_uuid_from_raw_string (lt_string1)
				l_target_name := l_tuple.name
				l_target_uuid := l_tuple.uuid
			end

			eis_component_found_table.search (cluster_id)
			if eis_component_found_table.found then
				l_group_name := eis_component_found_table.found_item
			end

			eis_component_found_table.search (class_id)
			if eis_component_found_table.found then
				l_class_name := eis_component_found_table.found_item
			end

			eis_component_found_table.search (feature_id)
			if eis_component_found_table.found then
				l_feature_name := eis_component_found_table.found_item
			end

			if condition_found and then condition_module.is_case_insensitive_equal ({COMMAND_PROTOCOL_NAMES}.compiler_module) and then condition.is_case_insensitive_equal ({COMMAND_PROTOCOL_NAMES}.project_ready) then
				if eiffel_project.initialized then
					locate (l_system_name, l_system_uuid, l_target_name, l_target_uuid, l_group_name, l_class_name, l_feature_name)
				else
					create l_uuid
					if (l_system_uuid /= Void implies l_uuid.is_valid_uuid (l_system_uuid)) then
						if (l_target_uuid /= Void implies l_uuid.is_valid_uuid (l_target_uuid)) then
						else
								-- Invalid UUID
							has_error := True
							show_error (interface_names.l_invalid_uuid (l_target_uuid))
						end
					else
							-- Invalid UUID
						has_error := True
						show_error (interface_names.l_invalid_uuid (l_target_uuid))
					end
					if not has_error then
							-- Open possible project and go to the location.
							-- Always accepted.
						project_open_actions.extend (agent locate (l_system_name, l_system_uuid, l_target_name, l_target_uuid, l_group_name, l_class_name, l_feature_name))
						command_accepted := True

							-- Place to search and open possible project.
						if attached preferences.misc_data.eis_path as lt_path then
								-- Search recent project first.
							project_searcher.search_projects (recent_projects_manager.recent_projects, l_system_name, l_system_uuid, l_target_name, l_target_uuid)
							if not project_searcher.project_found then
									-- Global search in EIS path
								project_searcher.search_project (lt_path, l_system_name, l_system_uuid, l_target_name, l_target_uuid)
							end
							if project_searcher.project_found and then attached project_searcher.found_project as lt_project then
								discard_start_dialog := True
									-- Trying to open the project directly, the starting window is not needed anymore.
								if starting_dialog /= Void and then not starting_dialog.is_destroyed then
									starting_dialog.destroy
								end
								if project_searcher.found_project_option /= Void and then project_searcher.found_project_option.target.last_location /= Void then
									l_project_path := project_searcher.found_project_option.target.last_location
									l_chosen_target := project_searcher.found_project_option.target_name
								else
									l_project_path := lt_project.parent
								end
								if l_chosen_target = Void then
									l_chosen_target := l_target_name
								end
								l_window := window_manager.last_created_window.window
								create l_loader.make (l_window)
								l_loader.set_is_project_location_requested (False)
								l_loader.open_project_file (lt_project, l_chosen_target, l_project_path, False, Void)
								if not l_loader.has_error then
									l_loader.set_is_compilation_requested (True)
									l_loader.compile_project
								else
									-- Leave the user to choose project from the normal starting dialog.
								end
							else
									-- Leave the user to choose project from the normal starting dialog.
								show_error (interface_names.l_resource_not_found (action))
							end
						else
							check Not_possible: False end
						end
					end
				end
			else
				if eiffel_project.initialized then
					locate (l_system_name, l_system_uuid, l_target_name, l_target_uuid, l_group_name, l_class_name, l_feature_name)
				else
						-- Nothing to do when project is not initialized.
				end
			end
		end

	locate (a_system_name, a_system_uuid,
			a_target_name, a_target_uuid,
			a_group_name, a_class_name, a_feature_name: detachable STRING)
					-- Locate the place from arguments.
		local
			l_target: detachable CONF_TARGET
			l_system: detachable CONF_SYSTEM
			l_group: CONF_GROUP
			l_class: CONF_CLASS
			l_feature: E_FEATURE
			l_stone: STONE
		do
				-- Go to the place in current system.
			l_system := check_system (a_system_name, a_system_uuid)

			if not has_error then
				l_target := check_target (a_target_name, a_target_uuid)

				if not has_error then
					if a_group_name /= Void then
						if l_target /= Void then
							l_group := check_group (l_target, a_group_name)
							if l_group = Void then
								show_error (Interface_names.l_target_does_not_have_group (l_target.name, l_group.name))
							end
						else
								-- If target is not specified, check the group in all possible targets
							l_group := check_group_with_name (a_group_name)
							if l_group = Void then
								show_error (Interface_names.l_group_not_found (a_group_name))
							end
						end
					end

					if a_class_name /= Void then
						if l_group /= Void then
							l_class := check_class_from_group (l_group, a_class_name)
								-- Did not find class in the group.
							if l_class = Void then
								show_error (Interface_names.l_group_does_not_have_class (a_class_name, l_group.name))
							end
						else
								-- Still try to get the class or feature directly from universe.
							l_class := check_class_from_universe (a_class_name)
							if l_class = Void then
								show_error (Interface_names.l_class_not_found (a_class_name))
							end
						end

						if l_class /= Void then
							if a_feature_name /= Void then
								l_feature := check_feature (l_class, a_feature_name)
								if l_feature = Void then
									show_error (Interface_names.l_class_does_not_have_feature (l_class.name, a_feature_name))
								end
							end
						else
								-- Do not think about feature when class is not found.
							if a_feature_name /= Void then
								has_error := True
								show_error (Interface_names.l_no_enough_info_for_feature (a_feature_name))
							end
						end
					end

						-- Check if command can be accepted.
					if not has_error then
						if l_feature /= Void then
							create {FEATURE_STONE}l_stone.make (l_feature)
							command_accepted := True
						elseif l_class /= Void then
							l_stone := stone_of_class (l_class)
							command_accepted := True
						elseif l_group /= Void then
							create {CLUSTER_STONE}l_stone.make (l_group)
							command_accepted := True
						end
						if l_stone /= Void then
							set_stone_when_idle (l_stone)
						end
					end
				end
			end
		end

	check_feature (a_class: CONF_CLASS; a_feature_string: STRING): E_FEATURE
			-- Check feature from `a_class'.
		require
			a_class_not_void: a_class /= Void
			a_feature_string_not_void: a_feature_string /= Void
		do
			if attached {CLASS_I} a_class as lt_class and then lt_class.is_compiled then
				Result := lt_class.compiled_representation.feature_with_name_32 (a_feature_string.as_lower)
			end
			if Result = Void then
				has_error := True
			end
		end

	check_class_from_group (a_group: CONF_GROUP; a_class_string: STRING): CONF_CLASS
			-- Check class from `a_group'.
		require
			a_group_not_void: a_group /= Void
			a_class_string_not_void: a_class_string /= Void
		do
			if a_group.classes /= Void then
				Result := a_group.classes.item (a_class_string.as_upper)
			end
			if Result = Void then
				has_error := True
			end
		end

	check_class_from_universe (a_class_string: STRING): CONF_CLASS
			-- Check class from `a_target'.
		require
			a_class_string_not_void: a_class_string /= Void
		local
			l_list: LIST [CLASS_I]
		do
			l_list := universe.classes_with_name (a_class_string.as_upper)
			if not l_list.is_empty and then attached {CLASS_I} l_list.first as lt_class then
				Result := lt_class.config_class
			end
			if Result = Void then
				has_error := True
			end
		end

	check_group (a_target: CONF_TARGET; a_group_string: STRING): CONF_GROUP
			-- Check group from `a_target'.
		require
			a_target_not_void: a_target /= Void
			a_group_string_not_void: a_group_string /= Void
		do
			Result := a_target.groups.item (a_group_string)
			if Result = Void then
				has_error := True
			end
		end

	check_group_with_name (a_group_name: STRING): detachable CONF_GROUP
			-- Try to get group from all possible targets with access
		require
			a_group_name_not_void: a_group_name /= Void
		do
			if attached universe.conf_system as l_system and then attached l_system.application_target as l_target then
				if attached l_target.groups.item (a_group_name) as l_group then
					Result := l_group
				else
					if attached l_system.all_libraries as l_libraries then
						across
							l_libraries as l_c
						until
							Result /= Void
						loop
							if attached l_c.item.groups.item (a_group_name) as l_g then
								Result := l_g
							end
						end
					end
				end
			end
			if Result = Void then
				has_error := True
			end
		end

	check_system (a_system_name, a_system_uuid: detachable STRING): detachable CONF_SYSTEM
			-- Get possible system
			-- If Void is returned, `a_raw_system_string' is not recognized as possible system
		local
			l_system_name, l_uuid_string: STRING
			l_uuid: UUID
			l_current_system: detachable CONF_SYSTEM
		do
			l_current_system := universe.conf_system
			if a_system_name /= Void or a_system_uuid /= Void then
				l_system_name := a_system_name
				l_uuid_string := a_system_uuid
				if l_uuid_string /= Void then
					l_uuid := universe.conf_system.uuid
					if l_uuid.is_valid_uuid (l_uuid_string) then
						if l_uuid.is_equal (create {UUID}.make_from_string (l_uuid_string)) then
							if l_system_name /= Void then
								if l_current_system.name.is_case_insensitive_equal (l_system_name) then
										-- Is current system.
									Result := l_current_system
								else
										-- UUID and name doesn't match
									has_error := True
									show_error (interface_names.l_system_uuid_name_not_match (l_uuid_string, l_system_name))
								end
							else
								Result := l_current_system
							end
						else
								-- Not current system, try library systems
							if
								attached l_current_system.all_libraries as l_libraries and then
								attached l_libraries.item (create {UUID}.make_from_string (l_uuid_string)) as l_target
							then
								Result := l_target.system
							end
						end
					else
						-- Not Valid UUID
						has_error := True
						show_error (interface_names.l_invalid_uuid (l_uuid_string))
					end
				else
					if l_current_system.name.is_case_insensitive_equal (l_system_name) then
						Result := l_current_system
					else
							-- Not current system
					end
				end
			end
		end

	check_target (a_target_name, a_target_uuid: detachable STRING): detachable CONF_TARGET
			-- Get possible target from given string.
			-- If `a_raw_target_string' is Void, return system target
			-- If Void is returned, `a_raw_target_string' is not recognized as possible target
		local
			l_target_name, l_uuid_string: STRING
			l_uuid: UUID
			l_current_system: detachable CONF_SYSTEM
			l_target: CONF_TARGET
			l_arrayed_targets: ARRAYED_LIST [CONF_TARGET]
		do
			l_current_system := universe.conf_system
			if a_target_name /= Void or a_target_uuid /= Void then
				l_target_name := a_target_name
				l_uuid_string := a_target_uuid
				if l_uuid_string /= Void then
					l_uuid := universe.conf_system.uuid
					if l_uuid.is_valid_uuid (l_uuid_string) then
						if l_uuid.is_equal (create {UUID}.make_from_string (l_uuid_string)) then
							if l_target_name /= Void then
								if l_current_system.application_target.name.is_case_insensitive_equal (l_target_name) then
										-- Is system target.
									Result := l_current_system.application_target
								else
										-- UUID and name doesn't match
									has_error := True
									show_error (interface_names.l_target_uuid_name_not_match (l_uuid_string, l_target_name))
								end
							else
								Result := l_current_system.application_target
							end
						else
								-- Not application system
							l_target := l_current_system.targets.item (l_uuid_string)
							if l_target = Void and then attached l_current_system.all_libraries as l_libraries then
									-- Try to find the library target that the system is able to access.
								l_target := l_libraries.item (create {UUID}.make_from_string (l_uuid_string))
							end
							if l_target /= Void then
								if l_target_name /= Void then
									if l_target.name.is_case_insensitive_equal (l_target_name) then
											-- Is system target.
										Result := l_target
									else
											-- UUID and name doesn't match
										has_error := True
										show_error (interface_names.l_target_uuid_name_not_match (l_uuid_string, l_target_name))
									end
								else
									Result := l_target
								end
							else
								Result := l_current_system.application_target
							end
						end
					else
						-- Not Valid UUID
						has_error := True
						show_error (interface_names.l_invalid_uuid (l_uuid_string))
					end
				else
					if universe.target_name.is_case_insensitive_equal (l_target_name) then
						Result := universe.target
					else
						l_arrayed_targets := l_current_system.all_libraries.linear_representation
						from
							l_arrayed_targets.start
						until
							l_arrayed_targets.after or Result /= Void
						loop
							if l_target_name.is_case_insensitive_equal_general (l_arrayed_targets.item_for_iteration.name) then
								Result := l_arrayed_targets.item_for_iteration
							end
							l_arrayed_targets.forth
						end
							-- Target could still not be found here.
					end
				end
			end
		end

	name_and_uuid_from_raw_string (a_raw_string: attached STRING): attached TUPLE [name, uuid: STRING]
			-- Name and UUID from `a_raw_string'
		local
			l_name, l_uuid: STRING
			l_dot_index: INTEGER
			l_tuuid: UUID
		do
			l_dot_index := a_raw_string.index_of ({COMMAND_PROTOCOL_NAMES}.system_separator, 1)
			if l_dot_index = 0 then
				create l_tuuid
				if l_tuuid.is_valid_uuid (a_raw_string) then
					l_uuid := a_raw_string
				else
					l_name := a_raw_string
				end
			else
				l_name := a_raw_string.substring (1, l_dot_index - 1)
				l_uuid := a_raw_string.substring (l_dot_index + 1, a_raw_string.count)
			end
			Result := [l_name, l_uuid]
		end

	stone_of_class (a_class: CONF_CLASS): CLASSI_STONE
			-- Stone of `a_class'
		do
			if attached {CLASS_I} a_class as l_class then
				if l_class.is_compiled then
					create {CLASSC_STONE} Result.make (l_class.compiled_class)
				else
					create Result.make (l_class)
				end
			else
				check expected_type: False end
			end
		ensure
			result_not_void: Result /= Void
		end

	set_stone_when_idle (a_stone: STONE)
			-- Set stone to window when idle.
		do
			ev_application.do_once_on_idle (agent set_stone_to_window (a_stone))
		end

	set_stone_to_window (a_stone: STONE)
			-- Set stone to a window.
		require
			a_stone_not_void: a_stone /= Void
		do
			if attached {EB_DEVELOPMENT_WINDOW} window_manager.last_focused_development_window as lt_window then
				lt_window.show
				lt_window.set_stone (a_stone)
			end
		end

	show_error (an_error: detachable STRING_GENERAL)
			-- Show `an_error'
		do
			if an_error /= Void then
				prompts.show_error_prompt (an_error, Void, Void)
			end
		end

feature {NONE} -- EIS access

	eis_component_found_table: attached HASH_TABLE [STRING, INTEGER]
			-- Found component table [found_value, component_id]

	eis_component_table: attached HASH_TABLE [INTEGER, STRING]
			-- EIS component table.
			-- With keys in lower cases.
		once
			create Result.make (5)
			Result.put (system_id, system_string)
			Result.put (target_id, target_string)
			Result.put (cluster_id, cluster_string)
			Result.put (class_id, class_string)
			Result.put (feature_id, feature_string)
			Result.compare_objects
		end

	system_id: INTEGER = unique
	target_id: INTEGER = unique
	cluster_id: INTEGER = unique
	class_id: INTEGER = unique
	feature_id: INTEGER = unique

	system_string: STRING = "system"
	target_string: STRING = "target"
	cluster_string: STRING = "cluster"
	class_string: STRING = "class"
	feature_string: STRING = "feature"

feature -- Query

	command_resolved: BOOLEAN
			-- Does the command accepted or can be passed to other instances of ES?
			-- Return True if as long as there was error, despite of whether the command is accepted.
			-- Or command has been accepted.
		do
			Result := has_error or command_accepted
		end

	has_error: BOOLEAN
			-- Has error during processing?

	command_accepted: BOOLEAN
			-- Does the command accepted by EiffelStudio.

	discard_start_dialog: BOOLEAN
			-- Need to discard start dialog?

feature {NONE} -- Implementation

	starting_dialog: detachable EB_STARTING_DIALOG
			-- Starting dialog

	on_project_openned
			-- Called when project is opened.
		local
			l_actions: like project_open_actions
		do
			l_actions := project_open_actions
			if not l_actions.is_empty then
				from
					l_actions.start
				until
					l_actions.after
				loop
					l_actions.item.apply
					l_actions.forth
				end
				l_actions.wipe_out
			end
		end

	project_open_actions: ARRAYED_LIST [PROCEDURE]
			-- Project open actions
		once
			create Result.make (1)
		end

	project_searcher: ES_PROJECT_SEARCHER
			-- Project searcher
		once
			create Result
		end

feature {NONE} -- Access

	condition_found: BOOLEAN

	action_found: BOOLEAN

	condition_module: detachable STRING_32

	condition: detachable STRING_32

	action_module: detachable STRING_32

	action: detachable STRING_32;

note
	copyright: "Copyright (c) 1984-2023, Eiffel Software"
	license:   "GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
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

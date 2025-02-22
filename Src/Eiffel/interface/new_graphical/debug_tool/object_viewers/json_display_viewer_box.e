note
	description: "Summary description for {JSON_DISPLAY_VIEWER_BOX}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JSON_DISPLAY_VIEWER_BOX

inherit

	EB_OBJECT_VIEWER

	EV_SHARED_APPLICATION

	EB_CONSTANTS

	EB_SHARED_DEBUGGER_MANAGER

	EB_SHARED_WINDOW_MANAGER

	EB_SHARED_PREFERENCES

	REFACTORING_HELPER

create
	make

feature {NONE} -- Implementation

	build_widget
		local
			vb: EV_VERTICAL_BOX
			viewerborder: EV_VERTICAL_BOX
		do
			create vb
			widget := vb
			if not is_associated_with_tool then
				vb.set_border_width (layout_constants.dialog_unit_to_pixels (2))
			end

				--| Viewer
			create viewerborder
			viewerborder.set_border_width (layout_constants.dialog_unit_to_pixels (1))
			viewerborder.set_background_color ((create {EV_STOCK_COLORS}).black)

			create viewer.make
			viewer.widget.set_minimum_height (100)
			viewer.drop_actions.extend (agent on_stone_dropped)
			viewer.drop_actions.set_veto_pebble_function (agent is_valid_stone)

			viewer.set_key_color (preferences.editor_data.keyword_text_color)
			viewer.set_string_value_color (preferences.editor_data.string_text_color)
			viewer.set_value_color (preferences.editor_data.number_text_color)
			viewer.set_error_color (preferences.editor_data.error_text_color)
			viewer.set_info_color (preferences.editor_data.comments_text_color)

			viewer.attach_to_container (viewerborder)
			vb.extend (viewerborder)

 			set_title (name)
		end

feature -- Access

	name: STRING_GENERAL
		do
			Result := Interface_names.t_viewer_json_display_title
		end

	widget: EV_WIDGET

	viewer: ES_GRID_JSON_VIEWER

feature -- Access

	is_valid_stone (a_stone: ANY; is_strict: BOOLEAN): BOOLEAN
			-- Is `st' valid stone for Current?
		local
			dv: DUMP_VALUE
			s: STRING
		do
			if attached {OBJECT_STONE} a_stone as st then
				dv := debugger_manager.dump_value_factory.new_object_value (st.object_address, st.dynamic_class, 0)
				-- CHECKME: use 0 for scp_pid since we don't really care about the scoop pid here.				
				if dv.has_formatted_output then
					if is_strict then
						s := dv.formatted_truncated_string_representation (0, 10)
						s.left_adjust
						Result := begin_with (s, "{", True) -- FIXME: maybe have stronger check...
					else
						Result := True
					end
				end
			end
		end

feature -- Change

	refresh
			-- Recompute the displayed text.
		local
			l_trunc_str: STRING_32
		do
			clear
			if
				Debugger_manager.application_is_executing
				and then Debugger_manager.application_is_stopped
			then
				if has_object then
					retrieve_dump_value
					if current_dump_value /= Void then
						l_trunc_str := current_dump_value.formatted_truncated_string_representation (0, -1)
						viewer.load_string (l_trunc_str)
					end
				end
			end
		end

	destroy
			-- Destroy Current
		do
			reset
			if widget /= Void then
				widget.destroy
				widget := Void
			end
		end

feature {NONE} -- Implementation

	is_in_default_state: BOOLEAN
		do
			Result := True
		end

	parent_window (w: EV_WIDGET): EV_WINDOW
		do
			if attached w.parent as p then
				Result := if attached {EV_WINDOW} p as r then r else parent_window (p) end
			end
		end

	clear
			-- Clean current data, useless if dialog closed or destroyed
		do
			viewer.clear
		end

feature {NONE} -- Event handling

	on_stone_dropped (st: OBJECT_STONE)
			-- A stone was dropped in the editor. Handle it.
		do
			set_stone (st)
		end

	close_action
			-- Close dialog
		do
			destroy
		end

note
	copyright: "Copyright (c) 1984-2018, Eiffel Software"
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

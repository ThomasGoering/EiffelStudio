﻿note
	description: "Contents that have a tool bar items that client programmer want to managed by docking library."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	SD_TOOL_BAR_CONTENT

inherit
	HASHABLE

	SD_ACCESS

create
	make_with_items,
	make_with_tool_bar

feature {NONE} -- Initlization

	make_with_items (a_unique_title: READABLE_STRING_GENERAL; a_items: like items)
			-- Creation method
		require
			a_title_not_void: a_unique_title /= Void
			a_items_not_void: a_items /= Void
		do
			unique_title := a_unique_title.as_string_32
				-- We set display title same as unique title by default
			title := unique_title.twin
			items := a_items
		ensure
			set: unique_title.same_string_general (a_unique_title)
			set: items = a_items
		end

	make_with_tool_bar (a_unique_title: READABLE_STRING_GENERAL; a_tool_bar: EV_TOOL_BAR)
			-- Creation method. A helper function, actually SD_TOOL_BAR_ZONE only appcept EV_TOOL_BAR_ITEMs.
			-- Warning: use this method will lose alpha data, which will show nothing when use AlphaBlend functions!
		require
			a_title_not_void: a_unique_title /= Void
			a_tool_bar_not_void: a_tool_bar /= Void
		local
			l_item: EV_TOOL_BAR_ITEM
			l_temp_items: like items
		do
			create l_temp_items.make (0)
			across
				a_tool_bar as i
			loop
				l_item := i
				if attached l_item.parent as p then
					p.prune (l_item)
				end
				l_temp_items.extend (convert_to_sd_item (l_item, @ i.target_index.out))
			end
			make_with_items (a_unique_title, l_temp_items)
		ensure
			set: a_unique_title.same_string (unique_title)
			set: a_tool_bar.count = items.count
		end

	convert_to_sd_item (a_ev_item: EV_TOOL_BAR_ITEM; a_name: READABLE_STRING_GENERAL): SD_TOOL_BAR_ITEM
			-- Convert a EV_TOOL_BAR_ITEM to SD_TOOL_BAR_ITEM
			-- Warning: use this method to convert pixmap in `a_ev_item' will lose alpha data, which will show nothing when use AlphaBlend functions!
		require
			not_void: a_ev_item /= Void
		local
			l_sd_button: SD_TOOL_BAR_BUTTON
		do
			if attached {EV_TOOL_BAR_BUTTON} a_ev_item as l_tool_bar_button then
				if attached {EV_TOOL_BAR_TOGGLE_BUTTON} a_ev_item then
					create {SD_TOOL_BAR_TOGGLE_BUTTON} l_sd_button.make
				else
					create l_sd_button.make
				end
				if l_tool_bar_button.text /= Void then
					l_sd_button.set_text (l_tool_bar_button.text)
				end
				if attached l_tool_bar_button.pixmap as l_pixmap then
					l_sd_button.set_pixmap (l_pixmap)
				end
				if l_tool_bar_button.select_actions /= Void then
					l_sd_button.select_actions.append (l_tool_bar_button.select_actions)
				end
				Result := l_sd_button
			else
				check must_be_separator: attached {EV_TOOL_BAR_SEPARATOR} a_ev_item end
				create {SD_TOOL_BAR_SEPARATOR} Result.make
			end
			Result.set_name (a_name)
		ensure
			not_void: Result /= Void
		end

feature -- Command

	show
			-- Show Current
		require
			not_destroyed: not is_destroyed
		do
			if not is_visible then
				if attached zone as l_zone then
					l_zone.show
					if attached l_zone.floating_tool_bar as b then
						b.show
					else
						if l_zone.assistant.last_state.is_docking_state_recorded then
							l_zone.assistant.dock_last_state_for_hide
						elseif attached manager as m then
							m.set_top (Current, {SD_ENUMERATION}.top)
						end
					end
				end
				is_visible := True
			end
		end

	hide
			-- Hide Current
		require
			not_destroyed: not is_destroyed
		local
			l_row: detachable SD_TOOL_BAR_ROW
		do
			if is_visible then
				if attached zone as l_zone then
					if attached l_zone.floating_tool_bar as b then
						b.hide
					else
						l_row := l_zone.row
						if l_row /= Void then
							l_zone.assistant.record_docking_state
							l_row.prune (l_zone)
							if l_row.is_empty then
								l_row.destroy
							end
						end
					end
					l_zone.hide
				end
				is_visible := False
				if attached manager as m then
					m.docking_manager.command.resize (True)
				end
			end
		end

	close
			-- Close Current
		require
			not_destroyed: not is_destroyed
		do
			destroy_container
			if attached manager as m then
				m.contents.start
				m.contents.prune (Current)
			end
		end

	set_title (a_display_title: READABLE_STRING_GENERAL)
			-- Set `title' with `a_display_title'
		require
			not_destroyed: not is_destroyed
			not_void: a_display_title /= Void
		do
			title := a_display_title.as_string_32
		ensure
			set: title.same_string_general (a_display_title)
		end

	set_top (a_direction: INTEGER)
			-- Set dock at `a_direction'
		require
			not_destroyed: not is_destroyed
			valid: a_direction = {SD_ENUMERATION}.top or a_direction = {SD_ENUMERATION}.bottom
			added: is_added
		do
			if attached zone as l_zone then
					-- Use this function to set all SD_TOOL_BAR_ITEM wrap states
				l_zone.change_direction (True)
			end
			destroy_container

			if attached manager as m then
				m.set_top (Current, a_direction)
			else
				check
					from_precondition_added: False
				end
			end

			is_visible := True
		ensure
			visible: is_visible
		end

	set_top_with (a_target_content: SD_TOOL_BAR_CONTENT)
			-- Set Current dock at same row/column with `a_other_content'
		require
			not_destroyed: not is_destroyed
			not_void: a_target_content /= Void
			added: is_added
			target_docking: a_target_content.is_docking
		do
			if attached zone as l_zone then
					-- Use this function to set all SD_TOOL_BAR_ITEM wrap states
				l_zone.change_direction (True)
			end
			destroy_container

			if attached manager as m then
				m.set_top_with (Current, a_target_content)
			else
				check
					from_precondition_added: False
				end
			end

			is_visible := True
		ensure
			visible: is_visible
		end

	refresh
			-- Refresh tool bar if items visible changed
		require
			not_destroyed: not is_destroyed
		do
			if attached zone as l_zone then
				l_zone.assistant.refresh_items_visible
			end
		end

	destroy
			-- When a SD_DOCKING_MANAGER destroy, all SD_CONTENTs in it will be destroyed
			-- Clear all resources and all references
		do
			if attached zone as l_zone then
				l_zone.destroy
			end
			is_destroyed := True
		ensure
			destroyed: is_destroyed
		end

feature -- Query

	unique_title: STRING_32
			-- Unique tool bar title
			-- It's used for store/open layout data, so it should not be changed

	title: STRING_32
			-- Title for display

	items: ARRAYED_SET [SD_TOOL_BAR_ITEM]
			-- All 	EV_TOOL_BAR_ITEM in `Current' including invisible items

	items_visible: LIST [SD_TOOL_BAR_ITEM]
			-- All displayed items
		do
			create {ARRAYED_LIST [SD_TOOL_BAR_ITEM]} Result.make (1)
			across
				items as i
			loop
				if i.is_displayed then
					Result.extend (i)
				end
			end
		ensure
			not_void: Result /= Void
		end

	items_except_sep (a_include_invisible: BOOLEAN): LIST [SD_TOOL_BAR_ITEM]
			-- `items' except SD_TOOL_BAR_SEPARATOR
		local
			l_snap_shot: LIST [SD_TOOL_BAR_ITEM]
		do
			if a_include_invisible then
				Result := items.twin
				l_snap_shot := items.twin
			else
				Result := items_visible
				l_snap_shot := items_visible
			end
			across
				l_snap_shot as i
			loop
				if attached {SD_TOOL_BAR_SEPARATOR} i as l_separator then
					Result.start
					Result.prune (l_separator)
				end
			end
		ensure
			not_void: Result /= Void
		end

	groups_count (a_include_invisible: BOOLEAN): INTEGER
			-- Group count, group is buttons before one separater
		local
			l_last_is_separator: BOOLEAN -- Maybe two separator together
			l_items: like items_visible
		do
			Result := 1
				-- Ignore the first separator.
			l_last_is_separator := True
			l_items := if a_include_invisible then items else items_visible end
			across
				l_items as i
			loop
				if i.is_displayed then
					if not attached {SD_TOOL_BAR_SEPARATOR} i then
						l_last_is_separator := False
					elseif l_last_is_separator and @ i.target_index /= l_items.count then
							-- We ignore last separator
						Result := Result + 1
						l_last_is_separator := True
					end
				end
			end
			if items.valid_index (l_items.count - 1) then
				if l_last_is_separator and attached {SD_TOOL_BAR_SEPARATOR} l_items.i_th (l_items.count - 1) then
						-- At least two sepators at the end.
					Result := Result - 1
				end
			elseif l_last_is_separator and l_items.count = 1 then
					-- Only one separator
				Result := 0
			elseif l_items.is_empty then
				Result := 0
			end
		end

	group_items (a_group_index: INTEGER; a_include_invisible: BOOLEAN): LIST [SD_TOOL_BAR_ITEM]
			-- Group items.
		require
			valid: 0 < a_group_index and a_group_index <= groups_count (False)
		local
			l_group_count: INTEGER
			l_stop: BOOLEAN
			l_items: like items_visible
			l_last_is_separator: BOOLEAN
		do
			from
					-- If first item is separator, we ingore it
				l_last_is_separator := True
				if a_include_invisible then
					l_items := items
				else
					l_items := items_visible
				end
				create {ARRAYED_LIST [SD_TOOL_BAR_ITEM]} Result.make (1)
				l_group_count := 1
				l_items.start
			until
				l_items.after or l_stop
			loop
				if attached {SD_TOOL_BAR_SEPARATOR} l_items.item as l_separator then
					if not l_last_is_separator then
						l_group_count := l_group_count + 1
					end
					l_last_is_separator := True
				else
					if l_group_count = a_group_index and l_items.item.is_displayed then
						Result.extend (l_items.item)
					end
					l_last_is_separator := False
				end
				if l_group_count > a_group_index then
					l_stop := True
				end
				l_items.forth
			end
		ensure
			not_void: Result /= Void
			not_contain_separator: ∀ c: Result ¦ not attached {SD_TOOL_BAR_SEPARATOR} c
		end

	show_request_actions: EV_NOTIFY_ACTION_SEQUENCE
			-- Actions to perform when show requested
		do
			Result := internal_show_request_actions
			if not attached Result then
				create Result
				internal_show_request_actions := Result
			end
		end

	close_request_actions: EV_NOTIFY_ACTION_SEQUENCE
			-- Actions to perfrom when close requested.
		do
			Result := internal_close_request_actions
			if not attached Result then
				create Result
				internal_close_request_actions := Result
			end
		end

	item_count_except_sep (a_include_invisible: BOOLEAN): INTEGER
			-- Item count except SD_TOOL_BAR_SEPARATOR
		do
			across
				items as i
			loop
				if attached {SD_TOOL_BAR_SEPARATOR} i then
					Result := Result + (a_include_invisible or i.is_displayed).to_integer
				end
			end
		end

	is_contain_widget_item: BOOLEAN
			-- If Current contain normal widget items?
		do
			Result := ∃ i: items ¦ attached {SD_TOOL_BAR_WIDGET_ITEM} i
		end

	is_added: BOOLEAN
			-- If Current added to a tool bar manager?
		do
			Result := attached manager
		end

	is_destroyed: BOOLEAN
			-- If Current destroyed?

	is_visible: BOOLEAN
			-- If Current visible?

	is_docking: BOOLEAN
			-- If current docking at four side of main container?
		do
			Result := attached zone as l_zone and then l_zone.row /= Void
		end

	is_floating: BOOLEAN
			-- If current floating?
		do
			if attached zone as l_zone then
				Result := l_zone.is_floating
			end
		end

	is_menu_bar: BOOLEAN
			-- If Current is a menu bar which only contain SD_TOOL_BAR_MENU_ITEM.
		do
			Result := ∀ i: items ¦ attached {SD_TOOL_BAR_MENU_ITEM} i
		end

	hash_code: INTEGER
			-- Hash code
		do
			Result := unique_title.hash_code
		end

feature -- Obsolete

	item_count_except_separator: INTEGER
			-- Item count except SD_TOOL_BAR_SEPARATOR.
		obsolete
			"Use item_count_except_sep instead. [2017-05-31]"
		do
			Result := item_count_except_sep (True)
		end

	group (a_group_index: INTEGER_32): like group_items
			-- Group items except hidden items.
		obsolete
			"Use group_items instead. [2017-05-31]"
		do
			Result := group_items (a_group_index, True)
		end

	group_count: INTEGER
			-- Group count, group is buttons before one separater.
		obsolete
			"Use groups_count instead. [2017-05-31]"
		do
			Result := groups_count (True)
		end

	items_except_separator: like items_except_sep
			-- `items' except SD_TOOL_BAR_SEPARATOR.
		obsolete
			"Use items_except_sep instead. [2017-05-31]"
		do
			Result := items_except_sep (True)
		end

feature {SD_ACCESS} -- Internal issues

	wipe_out
			-- Remove all items
		do
			items.wipe_out
		end

	clear
			-- Clear widget items' parents and reset state flags
		do
			across
				items.twin as i
			loop
				if
					attached {SD_TOOL_BAR_WIDGET_ITEM} i as l_widget_item and then
					attached {EV_CONTAINER} l_widget_item.widget.parent as l_parent
				then
					l_parent.prune (l_widget_item.widget)
				end
			end
			if attached zone as l_zone and then attached l_zone.customize_dialog as l_dialog then
				l_dialog.destroy
				l_zone.set_customize_dialog (Void)
			end
		end

	index_of (a_item: SD_TOOL_BAR_ITEM; a_include_invisible: BOOLEAN): INTEGER
			-- Index of `a_item'
		require
			has: items.has (a_item)
		do
			across
				if a_include_invisible then items else items_visible end as i
			until
				Result /= 0
			loop
				if i = a_item then
					Result := @ i.target_index
				end
			end
		ensure
			valid: Result /= 0
		end

	separator_after_item (a_item: SD_TOOL_BAR_ITEM): detachable SD_TOOL_BAR_SEPARATOR
			-- Separator after `a_item' if exists, except invisible items
		require
			has: items_visible.has (a_item)
		local
			l_items_visible: like items_visible
		do
			l_items_visible := items_visible
			l_items_visible.go_i_th (l_items_visible.index_of (a_item, 1))
			if not l_items_visible.after then
				l_items_visible.forth
				if
					not l_items_visible.after and then
					attached {SD_TOOL_BAR_SEPARATOR} l_items_visible.item as sep
				then
					Result := sep
				end
			end
		end

	separator_before_item (a_item: SD_TOOL_BAR_ITEM): detachable SD_TOOL_BAR_SEPARATOR
			-- Separator before `a_item' if exists, except invisible items
		require
			has: items.has (a_item)
		local
			l_index: INTEGER
			l_items_visible: like items_visible
		do
			l_items_visible := items_visible
			l_index := l_items_visible.index_of (a_item, 1)
			debug ("docking")
				print ("%N SD_TOOL_BAR_CONTENT: separator_before_item: index_of `a_item' is: " + l_index.out)
			end

			l_items_visible.go_i_th (l_index)
			if not l_items_visible.before then
				l_items_visible.go_i_th (l_index - 1)
				if
					not l_items_visible.before and then
					attached {SD_TOOL_BAR_SEPARATOR} l_items_visible.item as sep
				then
					Result := sep
				end
			end
		end

	item_start_index (a_group_index: INTEGER; a_inclue_invisible: BOOLEAN): INTEGER
			-- Start index in `items' of a group. Start index not include SD_TOOL_BAR_SEPARATOR
		require
			valid: a_group_index > 0 and a_group_index <= groups_count (False)
		local
			l_group_count: INTEGER
			l_last_is_separator: BOOLEAN
		do
			l_last_is_separator := True
			Result := 1
			l_group_count := 1
			across
				if a_inclue_invisible then items else items_visible end as i
			until
				l_group_count = a_group_index
			loop
				if attached {SD_TOOL_BAR_SEPARATOR} i as l_separator then
					if not l_last_is_separator then
						l_group_count := l_group_count + 1
					end
					l_last_is_separator := True
				else
					l_last_is_separator := False
				end
				Result := Result + 1
			end
		ensure
			valid: Result > 0 and Result <= items.count
		end

	item_end_index (a_group_index: INTEGER): INTEGER
			-- End index in `items' of a group. End index not include SD_TOOL_BAR_SEPARATOR.
		require
			valid: a_group_index > 0 and a_group_index <= groups_count (False)
		do
			if a_group_index = groups_count (False) then
				Result := items.count
			else
				Result := item_start_index (a_group_index + 1, False) - 2
			end
		ensure
			valid: Result > 0 and Result <= items.count
		end

	zone: detachable SD_TOOL_BAR_ZONE
			-- Tool bar zone which Current related. May be Void if not exists.

	set_zone (a_zone: SD_TOOL_BAR_ZONE)
			-- Set `zone'.
		require
			not_void: a_zone /= Void
		do
			zone := a_zone
		ensure
			set: zone = a_zone
		end

	manager: detachable SD_TOOL_BAR_MANAGER
			-- Manager which manages `Current' (if any).

	set_manager (a_manager: detachable SD_TOOL_BAR_MANAGER)
			-- Set `manager' to `a_manager'.
		do
			manager := a_manager
		ensure
			set: manager = a_manager
		end

	set_visible (a_bool: BOOLEAN)
			-- Set `is_visible'
		do
			is_visible := a_bool
		ensure
			set: is_visible = a_bool
		end

feature {NONE} -- Implementation

	destroy_container
			-- Destroy related containers
		do
			if attached zone as l_zone then
				l_zone.destroy_parent_containers
				if attached l_zone.floating_tool_bar as b then
					b.destroy
					if attached manager as m then
						m.floating_tool_bars.prune_all (b)
					end
				end
				l_zone.destroy
			end
		end

	internal_show_request_actions: detachable EV_NOTIFY_ACTION_SEQUENCE
			-- Actions to perform when show requested

	internal_close_request_actions: detachable EV_NOTIFY_ACTION_SEQUENCE
			-- Actions to perfrom when close requested

invariant
	items_not_void: items /= Void

note
	library: "SmartDocking: Library of reusable components for Eiffel."
	copyright: "Copyright (c) 1984-2021, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"

end

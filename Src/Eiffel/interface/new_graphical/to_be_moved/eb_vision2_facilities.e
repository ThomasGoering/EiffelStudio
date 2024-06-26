note
	description	: "Facilities for programming in Vision2. %
				  %Your Class should inherit from the class to use the facilities"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author		: "Arnaud PICHERY [ aranud@mail.dotcom.fr ]"
	date		: "$Date$"
	revision	: "$Revision$"

class
	EB_VISION2_FACILITIES

inherit
	EB_CONSTANTS

feature -- Basic operations

	extend_no_expand (container: EV_BOX; widget: EV_WIDGET)
			-- Add `widget' to `container' and make `widget' not expandable
		do
			container.extend (widget)
			container.disable_item_expand (widget)
		end

	extend_with_size (container: EV_BOX; widget: EV_WIDGET; a_width, a_height: INTEGER)
			-- Add `widget' to `container' and make `widget' not expandable
			-- Set the minimum size of `widget' to (`a_width',`a_height')
		do
			widget.set_minimum_size (a_width, a_height)
			container.extend (widget)
			container.disable_item_expand (widget)
		end

	extend_button (container: EV_BOX; button: EV_BUTTON)
			-- Add `widget' to `container' and make `widget' not expandable
			-- Set the minimum size of `widget' to the default size for buttons
		do
			Layout_constants.set_default_width_for_button (button)
			container.extend (button)
			container.disable_item_expand (button)
		end

	adjust_sensitivity (a_widget: EV_WIDGET; a_sensitive: BOOLEAN)
			-- Enable/disable sensitivity of given widget according to `a_sensitive'.
		require
			not_a_widget_destroyed: not a_widget.is_destroyed
		do
			if a_sensitive then
				if not a_widget.is_sensitive then
					a_widget.enable_sensitive
				end
			else
				if a_widget.is_sensitive then
					a_widget.disable_sensitive
				end
			end
		end

feature -- Useful query

	parent_window_from (w: EV_WIDGET): EV_WINDOW
			-- Top parent Window containing `w'.
		require
			w_not_void: w /= Void
		do
			if attached {EV_WINDOW} w as win then
				Result := win
			elseif attached w.parent as p then
				Result := parent_window_from (p)
			end
		end

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

end -- class EB_VISION2_FACILITIES

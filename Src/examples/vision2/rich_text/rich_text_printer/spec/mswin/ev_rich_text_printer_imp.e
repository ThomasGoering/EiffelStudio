note
	description: "[
			Windows implementation of RTF printer.
		]"
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	EV_RICH_TEXT_PRINTER_IMP

inherit
	EV_PRINT_DIALOG_IMP
		redefine
			interface
		end

create {EV_RICH_TEXT_PRINTER}
	make

feature {EV_RICH_TEXT_PRINTER} -- Basic operations

	send_print_request (ctx: EV_PRINT_CONTEXT)
			-- Send a print request based on the parameters in `interface'.
		require
			text_set: attached_interface.rich_text /= Void
			do_not_print_to_file: not ctx.output_to_file
		local
			wnd: WEL_FRAME_WINDOW -- Needed to create the rich edit component.
			rich: WEL_RICH_EDIT
			pdc: WEL_PRINTER_DC
			txt: STRING
			l_loader: WEL_RICH_EDIT_BUFFER_LOADER
			i: like attached_interface
		do
			i := attached_interface
			create wnd.make_top ("_dummy_")
			create rich.make (wnd, "_dummy_", 10, 10, 300, 500, -1)
			create pdc.make_by_pointer (ctx.printer_context)
			txt := i.to_rtf
			create l_loader.make (txt)
			rich.set_text_limit (txt.count)
			rich.rtf_stream_in (l_loader)
			if attached i.job_name as jn then
				rich.print_all (pdc, jn)
			else
				rich.print_all (pdc, "From EV_RICH_TEXT_PRINTER")
			end
			wnd.destroy
		end

feature {EV_RICH_TEXT_PRINTER, EV_ANY, EV_ANY_I} -- Implementation

	interface: detachable EV_RICH_TEXT_PRINTER note option: stable attribute end;
			-- The object that is visible from outside.

note
	copyright:	"Copyright (c) 1984-2006, Eiffel Software"
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
			distributed in the hope that it will be useful,	but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the	GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA
		]"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"

end

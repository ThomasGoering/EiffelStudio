﻿note
	description: "Utility used for customized formatter/tool"
	date: "$Date$"
	revision: "$Revision$"

class
	EB_XML_DOCUMENT_HELPER [G]

inherit
	SHARED_BENCH_NAMES

feature -- Access

	items_from_parsing (a_parse_agent: PROCEDURE [XML_CALLBACKS]; a_callback: XML_CALLBACKS_FILTER; a_result_retriever: FUNCTION [LIST [G]]; a_error_retriever: FUNCTION [EB_METRIC_ERROR]): TUPLE [items: LIST [G]; error: EB_METRIC_ERROR]
			-- Setup related callbacks including `a_callback' for parsing definition xml and call `a_parse_agent' with those callbacks.
			-- Store descriptors retrieved from `a_result_retriever' after parsing in `items'.
			-- If error occurred, it will be stored in `error' which is retrieved from `a_error_retriever', otherwise, `error' will be Void.
		require
			a_parse_agent_attached: a_parse_agent /= Void
			a_callback_attached: a_callback /= Void
			a_result_retriever_attached: a_result_retriever /= Void
			a_error_retriever_attached: a_error_retriever /= Void
		local
			l_retried: BOOLEAN
			l_ns_cb: XML_NAMESPACE_RESOLVER
			l_content_filter: XML_CONTENT_CONCATENATOR
			l_history_filter: EB_XML_LOCATION_HISTORY_FILTER
			l_filter_factory: XML_CALLBACKS_FILTER_FACTORY
			l_error: EB_METRIC_ERROR
			l_items:  LIST [G]
		do
			create {LINKED_LIST [G]} l_items.make
			if not l_retried then
				create l_ns_cb.make_null
				create l_content_filter.make_null
				create l_history_filter.make
				create l_filter_factory

				l_history_filter.set_history_item_output_function (agent metric_names.xml_location (?, Void))

				a_parse_agent.call ([l_filter_factory.callbacks_pipe (<<l_ns_cb, l_content_filter, l_history_filter, a_callback>>)])
				l_items.append (a_result_retriever.item (Void))
			else
				l_error := a_error_retriever.item (Void)
				if l_error /= Void then
					l_error.set_location (l_history_filter.location)
				end
			end
			Result := [l_items, l_error]
		ensure
			result_attached: Result /= Void
		rescue
			l_retried := True
			retry
		end

	xml_document_for_items (a_root_element_name: STRING; a_descriptors: LIST [G]; a_xml_generator: FUNCTION [TUPLE [a_item: G; a_parent: XML_COMPOSITE], XML_ELEMENT]): XML_DOCUMENT
			-- Xml document for `a_descriptors' generated by `a_xml_generator'
		require
			a_root_element_name_attached: a_root_element_name /= Void
			not_a_root_element_name_is_empty: not a_root_element_name.is_empty
			a_descriptors_attached: a_descriptors /= Void
			a_xml_generator_attached: a_xml_generator /= Void
		local
			l_cursor: CURSOR
			l_root: XML_ELEMENT
		do
			create Result.make_with_root_named (a_root_element_name, create {XML_NAMESPACE}.make_default)
			l_cursor := a_descriptors.cursor
			from
				l_root := Result.root_element
				a_descriptors.start
			until
				a_descriptors.after
			loop
				l_root.force_last (a_xml_generator.item ([a_descriptors.item, Result]))
				a_descriptors.forth
			end
			a_descriptors.go_to (l_cursor)
		ensure
			result_attached: Result /= Void
		end

	items_from_xml_document (a_document: XML_DOCUMENT; a_callback: XML_CALLBACKS_FILTER ; a_result_retriever: FUNCTION [LIST [G]]; a_error_retriever: FUNCTION [EB_METRIC_ERROR]): LIST [G]
			-- Formatter descriptors from `a_document'
		require
			a_document_attached: a_document /= Void
		local
			l_desp_tuple: like items_from_parsing
		do
			l_desp_tuple := items_from_parsing (agent a_document.process_to_events, a_callback, a_result_retriever, a_error_retriever)
			check l_desp_tuple.error = Void end
			Result := l_desp_tuple.items
		ensure
			result_attached: Result /= Void
		end

	items_from_file_path (a_path: PATH; a_callback: XML_CALLBACKS_FILTER ; a_result_retriever: FUNCTION [LIST [G]]; a_error_retriever: FUNCTION [EB_METRIC_ERROR]; a_set_file_error_agent: PROCEDURE): like items_from_parsing
			-- Items from path `a_path' parsed using `a_callback'.
			-- If error occurred, it will be stored in `error'
			-- If failed because of file issue, call `a_set_file_error_agent'.
		require
			a_file_name_attached: a_path /= Void
			a_callback_attached: a_callback /= Void
			a_result_retriever_attached: a_result_retriever /= Void
			a_error_retriever_attached: a_error_retriever /= Void
		local
			l_parser: XML_STOPPABLE_PARSER
		do
			create l_parser.make
			Result := items_from_parsing (agent parse_file_path (a_path, ?, l_parser, a_set_file_error_agent), a_callback, a_result_retriever, a_error_retriever)

				-- Setup error information.
			if attached Result.error as err then
				err.set_file_location (a_path)
				err.set_xml_location ([l_parser.position.column, l_parser.position.row])
			end
		ensure
			result_attached: Result /= Void
		end

	items_from_file (a_file_name: READABLE_STRING_GENERAL; a_callback: XML_CALLBACKS_FILTER ; a_result_retriever: FUNCTION [LIST [G]]; a_error_retriever: FUNCTION [EB_METRIC_ERROR]; a_set_file_error_agent: PROCEDURE): like items_from_parsing
			-- Items from file named `a_file_name' parsed using `a_callback'.
			-- If error occurred, it will be stored in `error'
			-- If failed because of file issue, call `a_set_file_error_agent'.
		obsolete "use items_from_file_path [2012-nov]"
		require
			a_file_name_attached: a_file_name /= Void
			a_callback_attached: a_callback /= Void
			a_result_retriever_attached: a_result_retriever /= Void
			a_error_retriever_attached: a_error_retriever /= Void
		do
			Result := items_from_file_path (create {PATH}.make_from_string (a_file_name), a_callback, a_result_retriever, a_error_retriever, a_set_file_error_agent)
		ensure
			result_attached: Result /= Void
		end

	satisfied_items (a_descriptors: LIST [G]; a_criterion: FUNCTION [G, BOOLEAN]): LIST [G]
			-- Formatter descriptors from `a_descriptors' which satisfy `a_criterion'
			-- If `a_criterion' is Void, all formatter descriptors will be returned.
		require
			a_descriptors_attached: a_descriptors /= Void
		local
			l_fmt_desp: G
			l_cursor: CURSOR
		do
			create {LINKED_LIST [G]} Result.make
			l_cursor := a_descriptors.cursor
			from
				a_descriptors.start
			until
				a_descriptors.after
			loop
				l_fmt_desp := a_descriptors.item
				if a_criterion = Void or else a_criterion.item ([l_fmt_desp]) then
					Result.extend (l_fmt_desp)
				end
				a_descriptors.forth
			end
			a_descriptors.go_to (l_cursor)
		ensure
			result_attached: Result /= Void
		end

feature -- Setting

	store_xml (a_doc: XML_DOCUMENT; a_file: PATH; a_error_agent: PROCEDURE)
			-- Store xml defined in `a_doc' in file named `a_file'.
			-- When error occurs, `a_error_agent' will be invoked.
		require
			a_doc_attached: a_doc /= Void
			a_file_attached: a_file /= Void
		local
			l_file: RAW_FILE
			l_retried: BOOLEAN
			l_printer: XML_INDENT_PRETTY_PRINT_FILTER
			l_filter_factory: XML_CALLBACKS_FILTER_FACTORY
		do
			if not l_retried then
				create l_file.make_with_path (a_file)
				l_file.open_write
				create l_filter_factory
				create l_printer.make_null
				l_printer.set_indent ("%T")
				l_printer.set_output_file (l_file)
				a_doc.process_to_events (l_filter_factory.callbacks_pipe (<<l_printer>>))
				l_printer.flush
				l_file.close
			else
				if l_file /= Void and then not l_file.is_closed then
					l_file.close
				end
				if a_error_agent /= Void then
					a_error_agent.call (Void)
				end
			end
		rescue
			l_retried := True
			retry
		end

feature -- Parsing

	parse_file_path (a_file: PATH; a_callback: XML_CALLBACKS; a_parser: XML_PARSER; a_set_file_error_agent: PROCEDURE)
			-- Parse `a_file' using `a_parser' with `a_callback'.			
			-- Raise exception if error occurs.
			-- If failed because of file issue, invoke `a_set_file_error_agent'.
		require
			a_file_ok: a_file /= Void and then not a_file.is_empty
			a_callback_attached: a_callback /= Void
			a_parser_attached: a_parser /= Void
		local
			l_file: PLAIN_TEXT_FILE
		do
			create l_file.make_with_path (a_file)
			if l_file.exists and then l_file.is_readable then
				l_file.open_read
				check l_file.is_open_read end
				a_parser.set_callbacks (a_callback)
				a_parser.parse_from_file (l_file)
				l_file.close
			else
				if not l_file.is_closed then
					l_file.close
				end
				if l_file.exists and then a_set_file_error_agent /= Void then
					a_set_file_error_agent.call (Void)
				end
			end
		end

feature -- Backup

	backup_file (a_file: PATH)
			-- Backup file `a_file'.
			-- `a_file' is not guaranteed to be backuped maybe because `a_file' doesn't exists or is not readable, or
			-- the chosen backup file name is not writable.
		require
			a_file_attached: a_file /= Void
		local
			u: FILE_UTILITIES
		do
			u.copy_file_path (a_file, backup_file_name (a_file))
		end

	backup_file_name (a_file: PATH): PATH
			-- Backup file name for `a_file'.
		require
			a_file_attached: a_file /= Void
		do
			create Result.make_from_string (a_file.name + ".bak")
		ensure
			result_attached: Result /= Void
		end

note
	ca_ignore:
		"CA093", "CA093: manifest array type mismatch"
	copyright: "Copyright (c) 1984-2018, Eiffel Software"
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

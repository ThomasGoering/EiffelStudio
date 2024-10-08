note
	description: "Wizard for EiffelWeb projects."
	date: "$Date$"
	revision: "$Revision$"

class
	EWF_WIZARD

inherit
	WIZARD

create
	make

feature -- Access

	title: STRING_32 = "Web Application Wizard"

	default_project_name: STRING_32 = "new_app"

feature -- Factory	

	wizard_generator : EWF_WIZARD_GENERATOR
		do
			create Result.make (Current)
		end

feature -- Pages

	first_page: WIZARD_PAGE
		once
			Result := new_page ("first")
			Result.set_title ("Web Application Wizard")
			Result.set_subtitle ("Based on the EiffelWeb framework...")
			Result.add_section_text ("Create Web server application with EiffelWeb (Framework).")
			Result.add_text ("[
		
Using the EiffelWeb Framework (EWF), build server application for any platforms.
Depending on the connector(s), there are dependencies on third-party httpd server.
(For instance libfcgi requires to setup apache, ...)

More information at:
  - http://www.eiffelweb.org/
  - https://www.eiffel.org/projects/eiffel-web .

			]")
		end

	project_page: WIZARD_PAGE
		local
			q_str: WIZARD_STRING_QUESTION
			q_dir: WIZARD_DIRECTORY_QUESTION
		once
			Result := new_page ("project")
			Result.set_title ("Project Name and Project Location")
			Result.set_subtitle ("You can choose the name of the project and%Nthe directory where the project will be generated.")
			Result.add_text ("[
Please fill in:
	The name of the project (without space).
	The directory where you want the eiffel classes to be generated.
	]")
			q_str := Result.new_string_question ("Project name:", "name", "ASCII name, without space")
			Result.extend (q_str)
			q_dir := Result.new_directory_question ("Project location:", "location", "Valid directory path, it will be created if missing")
			Result.extend (q_dir)
			q_str.value_change_actions.extend (agent (i_str: WIZARD_STRING_QUESTION; i_dir: WIZARD_DIRECTORY_QUESTION)
					local
						s, v: READABLE_STRING_GENERAL
						p: PATH
					do
						v := i_str.value
						create p.make_from_string (i_dir.text)
						if
							i_dir.text.ends_with_general ("/")
							or i_dir.text.ends_with_general ("\")
						then
								-- Keep current dir
						else
							p := p.parent
						end

						if v = Void then
							s := application.available_directory_path (default_project_name, p).name
							i_dir.set_text (s)
						elseif not v.is_whitespace then
							s := application.available_directory_path (v, p).name
							i_dir.set_text (s)
						end
					end(?,q_dir)
				)
			Result.data.force (default_project_name, "name")
			Result.data.force (application.available_directory_path (default_project_name, application.layout.default_projects_location.extended ("eiffelweb")).name, "location")

			Result.set_validation (agent (a_page: WIZARD_PAGE)
				do
					if
						not attached a_page.data.item ("name") as l_name
						or else l_name.is_whitespace
					then
						a_page.report_error ("Invalid value for `name'!")
					end
					if not a_page.data.has ("location") then
						a_page.report_error ("Missing value for `location'!")
					end
				end)
		end

	connectors_page: WIZARD_PAGE
		once
			Result := new_page ("connectors")
			Result.set_title ("Connectors selection")
			Result.set_subtitle ("You can choose one or multiple connectors%Nto use as the same time.")
			Result.add_text ("[
Web application runs on top of connectors 
(i.e layer handling httpd incoming connections)

Select connectors you want to support:
	]")
			Result.add_boolean_question ("Standalone", "use_standalone", "Using the standalone Eiffel Web server")
			Result.add_boolean_question ("CGI", "use_cgi", "Require to setup associated httpd server")
			Result.add_boolean_question ("libFCGI", "use_libfcgi", "Require to setup associated httpd server, and have libfcgi dynamic libraries in the path")

			Result.data.force ("yes", "use_standalone")
			Result.data.force ("yes", "use_cgi")
			Result.data.force ("yes", "use_libfcgi")
		end

	standalone_connector_page: WIZARD_PAGE
		once
			Result := new_page ("standalone_connector")
			Result.set_title ("Standalone connector")
			Result.set_subtitle ("Set options .")
			Result.add_integer_question ("Port number", "port", "If port 8080 is already taken, then choose another one.")
			Result.add_boolean_question ("Verbose", "verbose", "Verbose output")

			Result.data.force ("8080", "port")
			Result.data.force ("no", "verbose")
		end

	routers_page: WIZARD_PAGE
		once
			Result := new_page ("routers")
			Result.set_title ("Use Router (URL dispatching)")
			Result.set_subtitle ("Use the router component to easily map url patterns to handlers.")
			Result.add_text ("[
Use the router component to easily map URL patterns to handlers:
	]")
			Result.add_boolean_question ("use the router component", "use_router", "Check generated code to see how to configure it.")

			Result.data.force ("yes", "use_router")
		end

	filters_page: WIZARD_PAGE
		once
			Result := new_page ("filters")
			Result.set_title ("Use Filter (chain filter)")
			Result.set_subtitle ("Use the filter component.")
			Result.add_text ("[
Use the filter component:
	]")
			Result.add_boolean_question ("use the filter component", "use_filter", "Check generated code to see how to configure it.")

			Result.data.force ("yes", "use_filter")
		end

	final_page: WIZARD_PAGE
		local
--			s,sv: STRING_32
--			l_settings: ARRAYED_LIST [TUPLE [title: READABLE_STRING_GENERAL; value: READABLE_STRING_GENERAL]]
--			l_project_settings: STRING_32
--			l_ewf_settings: STRING_32
			txt1, txt2: WIZARD_PAGE_TEXT_ITEM
		once
			Result := new_page ("final")
			Result.set_title ("Completing the New Web Application Wizard")
			Result.add_text ("You have specified the following settings:%N%N")
			txt1 := Result.new_fixed_size_text_item ("...")
--			Result.add_fixed_size_text ("...", "projects_settings")
			Result.extend (txt1)

			txt2 := Result.new_fixed_size_text_item ("...")
--			Result.add_fixed_size_text ("...", "ewf_settings")
			Result.extend (txt2)

			Result.update_actions.extend (agent (a_page: WIZARD_PAGE; a_txt1, a_txt2: WIZARD_PAGE_TEXT_ITEM)
				local
					sv: STRING_32
					l_settings: ARRAYED_LIST [TUPLE [title: READABLE_STRING_GENERAL; value: READABLE_STRING_GENERAL]]
				do
						-- Project
					create l_settings.make (10)
					if attached project_page.field_value ("name") as l_project_name then
						l_settings.force (["Project name", l_project_name])
					end
					if attached project_page.field_value ("location") as l_project_location then
						l_settings.force (["Location", l_project_location])
					end
					a_txt1.set_text (formatted_title_value_items (l_settings))

						-- EWF
					create l_settings.make (5)
					create sv.make_empty
					if connectors_page.boolean_field_value ("use_standalone") then
						if not sv.is_empty then
							sv.append (", ")
						end
						sv.append ("standalone")
					end
					if connectors_page.boolean_field_value ("use_cgi") then
						if not sv.is_empty then
							sv.append (", ")
						end
						sv.append ("cgi")
					end
					if connectors_page.boolean_field_value ("use_libfcgi") then
						if not sv.is_empty then
							sv.append (", ")
						end
						sv.append ("libfcgi")
					end

					l_settings.force (["Connectors", sv])

					if routers_page.boolean_field_value ("use_router") then
						l_settings.force (["Use Router", "yes"])
					end
					if routers_page.boolean_field_value ("use_filter") then
						l_settings.force (["Use Filter", "yes"])
					end

					a_txt2.set_text (formatted_title_value_items (l_settings))
				end(Result, txt1, txt2))
		end

feature -- Events

	next_page (a_current_page: detachable WIZARD_PAGE): WIZARD_PAGE
		do
			Result := notfound_page
			if a_current_page = Void then
				Result := first_page
			elseif a_current_page = first_page then
				Result := project_page
			elseif a_current_page = project_page then
				Result := connectors_page
			elseif a_current_page = connectors_page then
				if
					connectors_page.boolean_field_value ("use_standalone")
				then
					Result := standalone_connector_page
				else
					Result := routers_page
				end
			elseif a_current_page = standalone_connector_page then
				Result := routers_page
			elseif a_current_page = routers_page then
				Result := filters_page
			elseif a_current_page = filters_page then
				Result := final_page
			end
		end

end

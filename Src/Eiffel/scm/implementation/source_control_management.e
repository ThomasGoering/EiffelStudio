note
	description: "Summary description for {SOURCE_CONTROL_MANAGEMENT}."
	date: "$Date$"
	revision: "$Revision$"

class
	SOURCE_CONTROL_MANAGEMENT

inherit
	SOURCE_CONTROL_MANAGEMENT_S
		redefine
			statuses,
			on_statuses_updated
		end

	DISPOSABLE_SAFE

	EIFFEL_LAYOUT

	SHARED_EIFFEL_PROJECT

	EV_SHARED_APPLICATION

create
	make

feature {NONE} -- Creation

	make (cfg: SCM_CONFIG)
		do
			config := cfg

			create changelists.make_caseless (1)
			create_new_changelist ("default")

			create mutex.make

			eiffel_project.manager.compile_stop_agents.extend (agent on_project_recompiled)
		end

feature {NONE} -- Default

	config_filename: detachable PATH
		do
		end

feature {NONE} -- Clean up

	safe_dispose (a_explicit: BOOLEAN)
			-- <Precursor>
		do
		end

feature -- Access

	config: SCM_CONFIG

	workspace: detachable SCM_WORKSPACE
		do
			Result := internal_workspace
			if Result = Void then
				if
					attached eiffel_project.workbench.lace as l_lace and then
					attached l_lace.target as tgt
				then
					create Result.make_with_target (tgt)
					internal_workspace := Result
					Result.analyze
				end
			end
		end

	changelists: STRING_TABLE [SCM_CHANGELIST_COLLECTION]

feature -- Changelist

	create_new_changelist (a_name: READABLE_STRING_GENERAL)
		local
			ch: SCM_CHANGELIST_COLLECTION
		do
			create ch.make (a_name, 10)
			changelists [ch.name] := ch
		end

feature -- Async Operations

	mutex: MUTEX

	update_statuses_temp: detachable TUPLE [timeout: detachable EV_TIMEOUT; workers: ARRAYED_LIST [WORKER_THREAD]]
			-- Keep references to avoid GC to reclaim them.

	update_statuses
			-- Update statuses for all known SCM locations, i.e for the workspace
		local
			grp: SCM_GROUP
			wt: WORKER_THREAD
			l_worker_queue: ARRAYED_LIST [WORKER_THREAD]
			m: MUTEX
			nb: INTEGER
			cfg: SCM_FLAT_CONFIG
			d: SCM_ASYNC_STATUSES_DATA
			l_location_count_by_worker: INTEGER
			l_results, l_worker_data: ARRAYED_LIST [SCM_ASYNC_STATUSES_DATA]
			t: detachable EV_TIMEOUT
		do
			debug ("scm")
				print (generator + ".update_statuses is_updating_statuses=" + is_updating_statuses.out + "%N")
			end
			if
				not is_updating_statuses and then
				attached workspace as ws
			then
					-- FIXME: experienced issue on non Windows platforms, so for now operate all update in same thread [2022-02-09]
				if {PLATFORM}.is_windows then
					create l_worker_queue.make (5)
				else
					create l_worker_queue.make (1)
				end

				on_update_statuses_enter
				create m.make
				create l_results.make (ws.locations.count) -- Protected by mutex `m`

				l_location_count_by_worker := 1 + ws.locations.count // l_worker_queue.capacity -- N concurrent workers
				update_statuses_temp := [t, l_worker_queue]

					-- New thread
				across
					ws.locations as ic
				loop
					if l_worker_data = Void or else l_worker_data.count >= l_location_count_by_worker then
							-- New thread
						nb := nb + 1
						create l_worker_data.make (l_location_count_by_worker)
						create cfg.make_from_config (config)

						create wt.make (agent async_update_statuses (nb, l_worker_data, m))
						l_worker_queue.force (wt)
					end

					grp := ic.item
					create d.make (grp.root.deep_twin, grp.location.deep_twin, cfg)
					l_results.extend (d)
					check has_more_room: l_worker_data.count < l_location_count_by_worker end
					l_worker_data.force (d)
				end
				across
					l_worker_queue as ic
				loop
					ic.item.launch
				end
				ev_application.add_idle_action_kamikaze (agent check_for_async_update_statuses_completion (l_results, m))
			end
		end

	async_update_statuses (a_id: INTEGER; a_data_set: LIST [SCM_ASYNC_STATUSES_DATA]; a_mutex: MUTEX)
		local
			st_lst: SCM_STATUS_LIST
			d: SCM_ASYNC_STATUSES_DATA
			nb: INTEGER
			r: SCM_LOCATION
		do
			nb := a_data_set.count
			across
				a_data_set as ic
			loop
				d := ic.item
				r := d.root
				st_lst := r.changes (r.location, d.path, d.config)
				a_mutex.lock
				d.set_statuses (st_lst)
				a_mutex.unlock
				nb := nb - 1
			end

		end

	check_for_async_update_statuses_completion (
			a_list: LIST [SCM_ASYNC_STATUSES_DATA];
			a_mutex: MUTEX)
		local
			t: EV_TIMEOUT
		do
			create t
			if attached update_statuses_temp as temp then
				temp.timeout := t
			else
				check has_update_statuses_temp: False end
			end
			t.actions.extend (agent (i_list: LIST [SCM_ASYNC_STATUSES_DATA]; i_t: EV_TIMEOUT; i_m: MUTEX)
				local
					n, nb: INTEGER
				do
					i_m.lock
					nb := i_list.count
					n := nb
					across
						i_list as ic
					loop
						if ic.item.completed then
							n := n - 1
						end
					end
					i_m.unlock

					if n = 0 then
						i_t.destroy
						update_statuses_temp := Void -- Clear all references kept to avoid GC to reclaim them.
						across
							i_list as ic
						loop
							if attached ic.item as d then
								n := n + 1
								on_statuses_updated (d.root, d.path, d.statuses)
							end
						end
						i_list.wipe_out
						on_update_statuses_leave
					else
							-- continue timeout
					end
				end(a_list, t, a_mutex)
			)
			t.set_interval (500) -- interval in milliseconds)
		end

feature -- Operations

	on_statuses_updated (a_root: SCM_LOCATION; a_location: PATH; a_statuses: detachable SCM_STATUS_LIST)
		do
			record_statuses_cache (a_statuses, a_location)
			if attached {LOGGER_S} (create {SERVICE_CONSUMER [LOGGER_S]}).service as l_logger_service then
				if a_statuses /= Void then
					l_logger_service.put_message ({STRING_32} "Updated statuses: "+ a_statuses.changes_count.out +" changes (unversioned="+ a_statuses.unversioned_count.out +")" + a_location.name, {ENVIRONMENT_CATEGORIES}.tools)
				end
			end
			Precursor (a_root, a_location, a_statuses)
		end

	statuses (a_root: SCM_LOCATION; a_location: PATH): detachable SCM_STATUS_LIST
		do
			Result := Precursor (a_root, a_location)
			record_statuses_cache (Result, a_location)
		end

	update (a_changelist: SCM_CHANGELIST): detachable STRING_32
		local
			retried: BOOLEAN
		do
			if retried then
				Result := {STRING_32} "Exception raised ..." -- FIXME: provide more informations.
			else
				if attached {SCM_SVN_LOCATION} a_changelist.root as l_svn_loc then
					Result := l_svn_loc.update (a_changelist, config)
				elseif attached {SCM_GIT_LOCATION} a_changelist.root as l_git_loc then
					Result := l_git_loc.update (a_changelist, config)
				end
			end
		rescue
			retried := True
			retry
		end

	revert (a_changelist: SCM_CHANGELIST): detachable STRING_32
		local
			retried: BOOLEAN
		do
			if retried then
				Result := {STRING_32} "Exception raised ..." -- FIXME: provide more informations.
			else
				Result := a_changelist.root.revert (a_changelist, config)
			end
		rescue
			retried := True
			retry
		end

	add (a_changelist: SCM_CHANGELIST): detachable STRING_32
		local
			retried: BOOLEAN
		do
			if retried then
				Result := {STRING_32} "Exception raised ..." -- FIXME: provide more informations.
			else
				Result := a_changelist.root.add (a_changelist, config)
			end
		rescue
			retried := True
			retry
		end

	delete (a_changelist: SCM_CHANGELIST): detachable STRING_32
		local
			retried: BOOLEAN
		do
			if retried then
				Result := {STRING_32} "Exception raised ..." -- FIXME: provide more informations.
			else
				Result := a_changelist.root.delete (a_changelist, config)
			end
		rescue
			retried := True
			retry
		end

	diff (a_changelist: SCM_CHANGELIST): detachable SCM_DIFF
		local
			retried: BOOLEAN
		do
			if retried then
				create Result.make (0)
				Result.report_error ({STRING_32} "Exception raised ...") -- FIXME: provide more informations.
			else
				if attached {SCM_SVN_LOCATION} a_changelist.root as l_svn_loc then
					Result := l_svn_loc.diff (a_changelist, config)
				elseif attached {SCM_GIT_LOCATION} a_changelist.root as l_git_loc then
					Result := l_git_loc.diff (a_changelist, config)
				end
			end
		rescue
			retried := True
			retry
		end

	commit (a_commit: SCM_COMMIT_SET)
		local
			l_single_commit: SCM_SINGLE_COMMIT_SET
			retried: BOOLEAN
		do
			if retried then
				a_commit.report_error ("Exception raised ...") -- FIXME: provide more informations.
			else
				a_commit.reset
				if attached {SCM_SINGLE_COMMIT_SET} a_commit as l_single then
					if attached {SCM_SVN_LOCATION} l_single.changelist.root as l_svn_loc then
						l_svn_loc.commit (l_single, config)
					elseif attached {SCM_GIT_LOCATION} l_single.changelist.root as l_git_loc then
						l_git_loc.commit (l_single, config)
					end
				elseif attached {SCM_MULTI_COMMIT_SET} a_commit as l_multi then
					across
						l_multi.changelists as ic
					loop
						create l_single_commit.make_with_changelist (a_commit.message, ic.item)
						commit (l_single_commit)
						if l_single_commit.is_processed then
							if l_single_commit.has_error then
								a_commit.report_error (l_single_commit.execution_message)
							else
								a_commit.report_success (l_single_commit.execution_message)
							end
						end
					end
				else
					a_commit.report_error (a_commit.generator + ": not supported%N") -- FIXME
				end
			end
		rescue
			retried := True
			retry
		end

	push (a_push: SCM_PUSH_OPERATION)
		local
			retried: BOOLEAN
		do
			if retried then
				a_push.report_error ("Exception raised ...") -- FIXME: provide more informations.
			else
				a_push.reset
				if attached {SCM_GIT_LOCATION} a_push.root_location as l_git_loc then
					l_git_loc.push (a_push, config)
				else
					a_push.report_error (a_push.root_location.generator + ": push not supported%N") -- FIXME
				end
			end
		rescue
			retried := True
			retry
		end

	push_command_line (a_push: SCM_PUSH_OPERATION): detachable STRING_32
		do
			a_push.reset
			if attached {SCM_GIT_LOCATION} a_push.root_location as l_git_loc then
				Result := l_git_loc.push_command_line (a_push, config)
			else
				a_push.report_error (a_push.root_location.generator + ": push not supported%N") -- FIXME
			end
		end

	pull (a_pull: SCM_PULL_OPERATION)
		local
			retried: BOOLEAN
		do
			if retried then
				a_pull.report_error ("Exception raised ...") -- FIXME: provide more informations.
			else
				a_pull.reset
				if attached {SCM_GIT_LOCATION} a_pull.root_location as l_git_loc then
					l_git_loc.pull (a_pull, config)
				else
					a_pull.report_error (a_pull.root_location.generator + ": pull not supported%N") -- FIXME
				end
			end
		rescue
			retried := True
			retry
		end

	pull_command_line (a_pull: SCM_PULL_OPERATION): detachable STRING_32
		do
			a_pull.reset
			if attached {SCM_GIT_LOCATION} a_pull.root_location as l_git_loc then
				Result := l_git_loc.pull_command_line (a_pull, config)
			else
				a_pull.report_error (a_pull.root_location.generator + ": pull not supported%N") -- FIXME
			end
		end

	rebase (a_op: SCM_REBASE_OPERATION)
		local
			retried: BOOLEAN
		do
			if retried then
				a_op.report_error ("Exception raised ...") -- FIXME: provide more informations.
			else
				a_op.reset
				if attached {SCM_GIT_LOCATION} a_op.root_location as l_git_loc then
					l_git_loc.rebase (a_op, config)
				else
					a_op.report_error (a_op.root_location.generator + ": rebase not supported%N") -- FIXME
				end
			end
		rescue
			retried := True
			retry
		end

	rebase_command_line (a_op: SCM_REBASE_OPERATION): detachable STRING_32
		do
			a_op.reset
			if attached {SCM_GIT_LOCATION} a_op.root_location as l_git_loc then
				Result := l_git_loc.rebase_command_line (a_op, config)
			else
				a_op.report_error (a_op.root_location.generator + ": rebase not supported%N") -- FIXME
			end
		end

	post_commit_operations (a_commit: SCM_COMMIT_SET): detachable LIST [SCM_POST_COMMIT_OPERATION]
		do
			create {ARRAYED_LIST [SCM_POST_COMMIT_OPERATION]} Result.make (1)
			if attached {SCM_MULTI_COMMIT_SET} a_commit as l_multi then
				across
					l_multi.changelists as ic
				loop
					if attached {SCM_GIT_LOCATION} ic.item.root as l_gitloc then
						Result.extend (create {SCM_POST_COMMIT_GIT_PUSH_OPERATION}.make_with_location (l_gitloc))
					end
				end
			elseif attached {SCM_SINGLE_COMMIT_SET} a_commit as l_single then
				if attached {SCM_GIT_LOCATION} l_single.changelist.root as l_gitloc then
					Result.extend (create {SCM_POST_COMMIT_GIT_PUSH_OPERATION}.make_with_location (l_gitloc))
				end
			end
			if Result.is_empty then
				Result := Void
			end
		end

feature -- Status

	file_status (a_path: PATH): detachable SCM_STATUS
		local
			l_file_path: PATH
			p: PATH
			n: READABLE_STRING_GENERAL
			b: BOOLEAN
		do
			if attached statuses_cache as l_statuses_cache then
				l_file_path := a_path.absolute_path.canonical_path
				n := l_file_path.name
				across
					l_statuses_cache as ic
				until
					b
				loop
					p := ic.key
					if n.starts_with (p.name) then
							-- Found SCM location
						b := True
						if attached ic.item as l_statuses then
							Result := l_statuses.status (l_file_path)
						end
					end
				end
			end
		end

	scm_root_location (a_path: PATH): detachable SCM_LOCATION
		do
			if attached workspace as ws then
				Result := ws.scm_root (a_path.absolute_path.canonical_path)
			end
		end

feature {NONE} -- Access: internals

	internal_workspace: detachable like workspace


	statuses_cache: detachable HASH_TABLE [detachable SCM_STATUS_LIST, PATH]
			-- Statuses indexed by scm location.

feature -- Element change

	set_workspace (ws: like workspace)
		do
--			reset_statuses_cache
			internal_workspace := ws
			on_workspace_updated (ws)
		end

feature -- Element change

	reset_statuses_cache
		do
			statuses_cache := Void
		end

	record_statuses_cache (a_statuses: detachable SCM_STATUS_LIST; a_location: PATH)
		local
			l_statuses: like statuses_cache
		do
			l_statuses := statuses_cache
			if a_statuses /= Void and l_statuses = Void then
				create l_statuses.make_equal (1)
				statuses_cache := l_statuses
			end
			if l_statuses /= Void then
				l_statuses [a_location] := a_statuses
			end
		end

	cached_statuses (a_location: PATH): detachable SCM_STATUS_LIST
		do
			if attached statuses_cache as l_statuses_cache then
				Result := l_statuses_cache [a_location]
			end
		end

feature -- Status report

	is_available: BOOLEAN
			-- Is account service available?

	is_svn_available: BOOLEAN
			-- Is svn available?

	is_git_available: BOOLEAN
			-- Is git available?

	check_scm_availability
		do
			is_available := True
			is_git_available := (create {SCM_GIT}.make (config)).is_available
			is_svn_available := (create {SCM_SVN}.make (config)).is_available
		end

feature -- Events

	on_project_recompiled
		local
			prev_ws, ws: like workspace
		do
			if attached eiffel_project.workbench.lace.target as tgt then
				prev_ws := workspace
				create ws.make_with_target (tgt)
			end
			set_workspace (ws)
			if prev_ws /= Void and then prev_ws /= ws then
				ws.restore (prev_ws)
			end
		end

feature -- Events: Connection point

	scm_connection: EVENT_CONNECTION_I [SCM_OBSERVER, SOURCE_CONTROL_MANAGEMENT_S]
			-- <Precursor>
		do
			Result := internal_connection
			if not attached Result then
				create {EVENT_CONNECTION [SCM_OBSERVER, SOURCE_CONTROL_MANAGEMENT_S]} Result.make (
					agent (o: SCM_OBSERVER):
						ARRAY [TUPLE
							[event: EVENT_TYPE [TUPLE];
							action: PROCEDURE]
						]
						do
							Result :=
								<<
									[workspace_updated_event, agent o.on_workspace_updated],
									[statuses_updated_event, agent o.on_statuses_updated],
									[change_detected_event, agent o.on_change_detected]
								>>
						end)
				automation.auto_dispose (Result)
				internal_connection := Result
			end
		end

feature -- Events

	workspace_updated_event: EVENT_TYPE [TUPLE [ws: detachable SCM_WORKSPACE]]
			-- <Precursor>
		do
			Result := internal_workspace_updated_event
			if Result = Void then
				create Result
				internal_workspace_updated_event := Result
				auto_dispose (Result)
			end
		end

	statuses_updated_event: EVENT_TYPE [TUPLE [root: SCM_LOCATION; location: PATH; statuses: SCM_STATUS_LIST]]
			-- <Precursor>
		do
			Result := internal_statuses_updated_event
			if Result = Void then
				create Result
				internal_statuses_updated_event := Result
				auto_dispose (Result)
			end
		end

	change_detected_event: EVENT_TYPE [TUPLE [ch: detachable SCM_CHANGE]]
			-- <Precursor>
		do
			Result := internal_change_detected_event
			if Result = Void then
				create Result
				internal_change_detected_event := Result
				auto_dispose (Result)
			end
		end

feature {NONE} -- Implementation: Internal cache

	internal_connection: detachable like scm_connection
			-- Cached version of `es_cloud_connection`.
			-- Note: Do not use directly!	

	internal_workspace_updated_event: detachable like workspace_updated_event
			-- Cached version of `workspace_updated_event`.
			-- Note: Do not use directly!

	internal_statuses_updated_event: detachable like statuses_updated_event
			-- Cached version of `statuses_updated_event`.
			-- Note: Do not use directly!

	internal_change_detected_event: detachable like change_detected_event
			-- Cached version of `change_detected_event`.
			-- Note: Do not use directly!

invariant

note
	copyright: "Copyright (c) 1984-2022, Eiffel Software"
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

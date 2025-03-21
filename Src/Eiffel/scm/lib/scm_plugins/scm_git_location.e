note
	description: "Git location."
	date: "$Date$"
	revision: "$Revision$"

class
	SCM_GIT_LOCATION

inherit
	SCM_DISTRIBUTED_LOCATION

create
	make

feature -- Access

	nature: STRING = "GIT"


feature -- Execution

	changes (a_root_loc, loc: PATH; cfg: SCM_CONFIG): detachable SCM_STATUS_LIST
		local
			scm: SCM
		do
			reset_error
			create {SCM_GIT} scm.make (cfg)
			Result := scm.statuses (a_root_loc, loc, True, False, Void) -- True: is_recursive, False: with_all_untracked
		end

	update (a_changelist: SCM_CHANGELIST; cfg: SCM_CONFIG): detachable STRING_32
		local
			scm: SCM
		do
			reset_error
			create {SCM_GIT} scm.make (cfg)
			if attached scm.update (a_changelist, Void) as res then
				if res.succeed then
					if attached res.message as msg and then not msg.is_whitespace then
						Result := msg
					else
						Result := "GIT update completed"
					end
				else
					if attached res.message as msg and then not msg.is_whitespace then
						Result := msg
					else
						Result := "GIT update failed"
					end
					has_error := True
				end
			end
		end

	revert (a_changelist: SCM_CHANGELIST; cfg: SCM_CONFIG): detachable STRING_32
		local
			scm: SCM_GIT
		do
			reset_error
			create scm.make (cfg)
			if attached scm.revert (a_changelist, Void) as res then
				if res.succeed then
					if attached res.message as msg and then not msg.is_whitespace then
						Result := msg
					else
						Result := "GIT revert completed"
					end
				else
					if attached res.message as msg then
						Result := msg
					else
						Result := "GIT revert failed"
					end
					has_error := True
				end
			end
		end

	diff (a_changelist: SCM_CHANGELIST; cfg: SCM_CONFIG): detachable SCM_DIFF
		local
			scm: SCM
		do
			reset_error
			create {SCM_GIT} scm.make (cfg)
			create Result.make (a_changelist.count)
			Result.set_changelist (a_changelist)
			across
				a_changelist as ic
			loop
				if attached scm.diff (ic.item.location.name, Void) as d then
					Result.put_string_diff (ic.item.location.name, d.to_string_32)
				end
			end
		end

	add (a_changelist: SCM_CHANGELIST; cfg: SCM_CONFIG): detachable STRING_32
			-- Add items from `a_changelist`, and return updated status for those items.
		local
			scm: SCM_GIT
			opts: SCM_OPTIONS
		do
			reset_error
			create scm.make (cfg)
			create opts

			if attached scm.add (a_changelist, opts) as res then
				if res.succeed then
					if attached res.message as msg and then not msg.is_whitespace then
						Result := msg
					else
						Result := "GIT addition completed"
					end
				else
					if attached res.message as msg and then not msg.is_whitespace then
						Result := msg
					else
						Result := "GIT addition failed"
					end
					has_error := True
				end
			end
		end

	delete (a_changelist: SCM_CHANGELIST; cfg: SCM_CONFIG): detachable STRING_32
			-- Delete items from `a_changelist`, and return updated status for those items
		local
			scm: SCM_GIT
			opts: SCM_OPTIONS
		do
			reset_error
			create scm.make (cfg)
			create opts

			if attached scm.delete (a_changelist, opts) as res then
				if res.succeed then
					if attached res.message as msg and then not msg.is_whitespace then
						Result := msg
					else
						Result := "GIT deletion completed"
					end
				else
					if attached res.message as msg and then not msg.is_whitespace then
						Result := msg
					else
						Result := "GIT deletion failed"
					end
					has_error := True
				end
			end
		end

	commit (a_commit_set: SCM_SINGLE_COMMIT_SET; cfg: SCM_CONFIG)
		local
			scm: SCM_GIT
			opts: SCM_OPTIONS
			res: SCM_RESULT
		do
			reset_error
			create scm.make (cfg)
			create opts

			if attached a_commit_set.message as m then
				res := scm.commit (a_commit_set.changelist, m, opts)
				if res.succeed then
					if attached res.message as msg and then not msg.is_whitespace then
						a_commit_set.report_success (msg)
					else
						a_commit_set.report_success ("git operation completed")
					end
				else
					if attached res.message as msg and then not msg.is_whitespace then
						a_commit_set.report_error (msg)
					else
						a_commit_set.report_error ("git operation failed")
					end
					has_error := True
				end
			else
				has_error := True
				check is_ready: False end
				a_commit_set.report_error ("commit is not ready, message is missing")
			end
		end

	push (a_push: SCM_PUSH_OPERATION; cfg: SCM_CONFIG)
		local
			scm: SCM_GIT
			opts: SCM_OPTIONS
			res: SCM_RESULT
		do
			reset_error
			create scm.make (cfg)
			create opts
			res := scm.push (a_push, opts)
			if res.succeed then
				if attached res.message as msg and then not msg.is_whitespace then
					a_push.report_success (msg)
				else
					a_push.report_success ("git operation completed")
				end
			else
				if attached res.message as msg and then not msg.is_whitespace then
					a_push.report_error (msg)
				else
					a_push.report_error ("git operation failed")
				end
				has_error := True
			end
		end

	push_command_line (a_push: SCM_PUSH_OPERATION; cfg: SCM_CONFIG): detachable STRING_32
		local
			scm: SCM_GIT
			opts: SCM_OPTIONS
		do
			reset_error
			create scm.make (cfg)
			create opts
			Result := scm.push_command_line (a_push, opts)
		end

	pull (a_pull: SCM_PULL_OPERATION; cfg: SCM_CONFIG)
		local
			scm: SCM_GIT
			opts: SCM_OPTIONS
			res: SCM_RESULT
		do
			reset_error
			create scm.make (cfg)
			create opts
			res := scm.pull (a_pull, opts)
			if res.succeed then
				if attached res.message as msg and then not msg.is_whitespace then
					a_pull.report_success (msg)
				else
					a_pull.report_success ("git operation completed")
				end
			else
				if attached res.message as msg and then not msg.is_whitespace then
					a_pull.report_error (msg)
				else
					a_pull.report_error ("git operation failed")
				end
				has_error := True
			end
		end

	pull_command_line (a_pull: SCM_PULL_OPERATION; cfg: SCM_CONFIG): detachable STRING_32
		local
			scm: SCM_GIT
			opts: SCM_OPTIONS
		do
			reset_error
			create scm.make (cfg)
			create opts
			Result := scm.pull_command_line (a_pull, opts)
		end

	rebase (a_op: SCM_REBASE_OPERATION; cfg: SCM_CONFIG)
		local
			scm: SCM_GIT
			opts: SCM_OPTIONS
			res: SCM_RESULT
		do
			reset_error
			create scm.make (cfg)
			create opts
			res := scm.rebase (a_op, opts)
			if res.succeed then
				if attached res.message as msg and then not msg.is_whitespace then
					a_op.report_success (msg)
				else
					a_op.report_success ("git operation completed")
				end
			else
				if attached res.message as msg and then not msg.is_whitespace then
					a_op.report_error (msg)
				else
					a_op.report_error ("git operation failed")
				end
				has_error := True
			end
		end

	rebase_command_line (a_op: SCM_REBASE_OPERATION; cfg: SCM_CONFIG): detachable STRING_32
		local
			scm: SCM_GIT
			opts: SCM_OPTIONS
		do
			reset_error
			create scm.make (cfg)
			create opts
			Result := scm.rebase_command_line (a_op, opts)
		end

	remotes (cfg: SCM_CONFIG): detachable STRING_TABLE [GIT_REMOTE]
		local
			scm: SCM_GIT
		do
			reset_error
			create scm.make (cfg)
			Result := scm.remotes (location, Void)
		end

	branches (cfg: SCM_CONFIG): detachable STRING_TABLE [GIT_BRANCH]
		local
			scm: SCM_GIT
		do
			reset_error
			create scm.make (cfg)
			Result := scm.branches (location, False, Void)
		end

	all_branches (cfg: SCM_CONFIG): detachable STRING_TABLE [GIT_BRANCH]
		local
			scm: SCM_GIT
		do
			reset_error
			create scm.make (cfg)
			Result := scm.branches (location, True, Void)
		end

note
	copyright: "Copyright (c) 1984-2022, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
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

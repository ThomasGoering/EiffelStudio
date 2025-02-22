﻿note
	description: "Definition of deferred inherited features by another non-deferred%N%
			%inherited feature."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	DEFINITION

inherit
	FEATURE_ADAPTATION
		redefine
			check_redeclaration
		end

	SHARED_WORKBENCH
		export
			{NONE} all
		end

	COMPILER_EXPORTER
		export
			{NONE} all
		end

	SHARED_ERROR_HANDLER
		export
			{NONE} all
		end

create
	make

feature -- Status Report

	is_valid_old_features (old_feats: like old_features): BOOLEAN
			-- Is `old_feats' valid for Current?
		do
			Result := True
		end

	is_inherited: BOOLEAN
			-- Is `new_feature` an inherited one?
		do
				-- `True` for joining.
			Result := True
		end

feature -- Checking

	check_adaptation (feat_tbl: FEATURE_TABLE)
			-- Check signature conformance between the precursors contained
			-- in `old_features' and the feature `new_feature'. Since it
			-- is a definition, there is no merging of assertions.
		local
			deferred_features, features: ARRAYED_LIST [INHERIT_INFO]
			new_feat: FEATURE_I
		do
				-- The signature of the new feature in the context of
				-- `feat_tbl' has been already evaluated by feature
				-- `check_types' of FEATURE_TABLE (See class INHERIT_TABLE).
			new_feat := feat_tbl.item_id (new_feature.feature_name_id)
			check
				new_feat /= Void
			end
				--| If it does not have the same reference then
				--| replication of new_feature has occurred.
				--! Hence, we need to update the new_feature
				--| so it is referenced correctly.
			new_feature_info.set_a_feature (new_feat)
			features := old_features.features
			deferred_features := old_features.deferred_features
				-- Check one of the lists of the other one is empty
			if deferred_features.is_empty then
				check_list (features, feat_tbl)
			elseif features.is_empty then
				check_list (deferred_features, feat_tbl)
			else
					-- Combine two lists and check them together.
					-- (This is needed to perform validity checks properly.)
				features := features.twin
				features.append (deferred_features)
				check_list (features, feat_tbl)
			end
		end

	check_list (feats: ARRAYED_LIST [INHERIT_INFO]; tbl: FEATURE_TABLE)
			-- Check signature conformance of the redefinition of the
			-- features contained into `features' into `new_feature'.
		require
			good_argument: feats /= Void
			not_empty: not feats.is_empty
		local
			i: INHERIT_INFO
			f: FEATURE_I
		do
			f := new_feature
			from
				feats.start
			until
				feats.after
			loop
				i := feats.item
				if i.a_feature_needs_instantiation then
					i.delayed_instantiate_a_feature
				end
				f.delayed_check_signature (i.internal_a_feature, tbl)
				feats.forth
			end
		end

	check_redeclaration (new_tbl, old_tbl: FEATURE_TABLE
			pattern_list: ARRAYED_LIST [INTEGER])

			-- Check redeclaration into an attribute.
		local
			rout_id_set: ROUT_ID_SET
			new_rout_id: INTEGER
			inherited_features: ARRAYED_LIST [INHERIT_INFO]
			stop: BOOLEAN
			l_new_feature: FEATURE_I
		do
			l_new_feature := new_feature
			if not l_new_feature.is_routine then
					-- Nothing needed for routines, however this check prevents checking for both attribute and constant separately.
				if attached {ATTRIBUTE_I} l_new_feature as l_attribute then
					if not old_features.all_attributes then
							-- At least, the attribute is a redeclaration
							-- of a deferred routine or an implemented function.
							-- Remember to generate a function
						if l_attribute.generate_in = 0 then
							l_attribute.set_has_function_origin (True)
							l_attribute.set_generate_in (new_tbl.feat_tbl_id)
								-- Remember to process a pattern for this
							pattern_list.extend (l_attribute.feature_name_id)
						end
						rout_id_set := l_attribute.rout_id_set
						if not rout_id_set.has_attribute_origin then
								-- We have to give a new routine id to the
								-- attribute. If possible, take the same given
								-- during a previous compilation
							if
								attached {ATTRIBUTE_I} old_tbl.item_id (l_attribute.feature_name_id) as old_attribute and then
								old_attribute.has_function_origin
							then
								new_rout_id := old_attribute.rout_id_set.first
							else
								new_rout_id := l_attribute.new_rout_id
							end
								-- Insertion into the routine info table.
							System.rout_info_table.put (new_rout_id, System.current_class)
							rout_id_set.extend (new_rout_id)
						end
					else
						l_attribute.set_has_function_origin (False)
							-- Case of a redefinition of attributes into
							-- an attribute: new funciton if one precursor
							-- is associated to a function
						from
							inherited_features := old_features.features
							inherited_features.start
						until
							inherited_features.after or else stop
						loop
							if attached {ATTRIBUTE_I} inherited_features.item.internal_a_feature as attr_precursor then
								stop :=  attr_precursor.generate_in /= 0
							end
							inherited_features.forth
						end
						if stop then
							l_attribute.set_generate_in (new_tbl.feat_tbl_id)
								-- Remember to process a pattern for this function
							pattern_list.extend (l_attribute.feature_name_id)
						end
					end
				elseif attached {CONSTANT_I} l_new_feature as constant then
						-- It must be a constant.
						-- We do not need to force the generation of a constant
						-- which is generated as a once function since it is
						-- always generated in class where it is written.
						--
						-- Otherwise, an encapsulation function is required in
						-- class that does the redefinition/merge.
					if not constant.is_once and then constant.generate_in = 0 then
						constant.set_generate_in (new_tbl.feat_tbl_id)
							-- Remember to process a pattern for this function
						pattern_list.extend (constant.feature_name_id)
					end
				else
					check
						is_feature_kind_known: False
					end
				end
			end


			if system.il_generation and then
				(not l_new_feature.has_property_getter or else
				not l_new_feature.has_property_setter)
			then
					-- Check if an inherited feature has a setter or a getter
					-- and ensure a getter and a setter are generated for the current feature.
				if
					old_features.features.there_exists (agent {INHERIT_INFO}.has_property_getter) or else
					old_features.deferred_features.there_exists (agent {INHERIT_INFO}.has_property_getter)
				then
					l_new_feature.set_has_property_getter (True)
				end
				if
					old_features.features.there_exists (agent {INHERIT_INFO}.has_property_setter) or else
					old_features.deferred_features.there_exists (agent {INHERIT_INFO}.has_property_setter)
				then
					l_new_feature.set_has_property_setter (True)
				end
			end

				-- Insert the feature with new rout id in the origin
				-- table for later process of a selection table
			origin_table.insert (inherit_info_cache.new_inherited_info (l_new_feature, Void, Void))
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

end

class
	PE_MD_TABLE_FIELD_ENTRY

inherit
	PE_MD_TABLE_ENTRY_WITH_STRUCTURE

	PE_MD_TABLE_ENTRY_WITH_IDENTIFIER

create
	make

feature -- Access

	initialize_structure
		local
			struct: like structure
		do
			create struct.make (3, "Field")
			structure := struct
			struct.add_field_attributes ("Flags")
			struct.add_string_index ("Name")
			struct.add_field_signature_blob_index ("Signature")
		end

feature -- Access

	field_attributes: detachable PE_FIELD_ATTRIBUTES_ITEM
		do
			if attached {PE_FIELD_ATTRIBUTES_ITEM} structure.item ("Flags") as ta then
				Result := ta
			else
				check False end
			end
		end

	name_index: detachable PE_INDEX_ITEM
		do
			Result := structure.index_item ("Name")
		end

	signature_index: detachable PE_BLOB_INDEX_ITEM
		do
			if attached {like signature_index} structure.item ("Signature") as i then
				Result := i
			else
				check False end
			end
		end

	resolved_identifier (pe: PE_FILE): detachable STRING_32
			-- Human identifier
		do
			create Result.make_empty
			if
				attached name_index as tn_idx  and then
				attached pe.string_heap_item (tn_idx) as s
			then
				Result.append_string_general (s)
			end
			if Result.is_whitespace then
				Result := Void
			end
		end

feature -- Access

	table_id: NATURAL_8
		once
			Result := {PE_TABLES}.tfield
		end

end

note
	description: "Summary description for {PE_FIELD_POINTER_INDEX}."
	date: "$Date$"
	revision: "$Revision$"

class
	PE_FIELD_POINTER_INDEX

inherit
	PE_POINTER_INDEX

create
	make_with_index

feature -- Access

	associated_table_index: NATURAL_32
		do
			Result := {PE_TABLES}.tFieldPtr
		end

end

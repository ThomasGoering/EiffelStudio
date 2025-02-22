note
	description: "Representation of an IMAGE_DATA_DIRECTORY for CLI."
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=image_data_directory", "src=https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-image_data_directory", "protocol=uri"

class
	CLI_DIRECTORY

create
	make

feature {NONE}

	make
		do
			set_rva_and_size (0, 0)
		end

feature -- Access

	rva: INTEGER_32
			-- RVA of the directory.
			--| Relative virtual address for current directory.

	data_size: INTEGER_32
			-- Size of the directory in bytes.

feature -- Setter

	set_rva (a_virtual_address: INTEGER_32)
			-- Set `rva` to `a_virtual_address'.
		do
			rva := a_virtual_address
		ensure
			rva_set: rva = a_virtual_address
		end

	set_data_size (a_size: INTEGER_32)
			-- Set `data_size` with `a_size'.
		do
			data_size := a_size
		ensure
			data_size_set: data_size = a_size
		end

	set_rva_and_size (a_rva, a_size: INTEGER)
			-- Set `rva' and `data_size' to `a_rva' and `a_size'.
		do
			set_rva (a_rva)
			set_data_size (a_size)
		ensure
			rva_set: rva = a_rva
			data_size_set: data_size = a_size
		end

feature -- Managed Pointer

	item: MANAGED_POINTER
			-- write the items to the buffer in  little-endian format.
		local
			mp: CLI_MANAGED_POINTER
		do
			create mp.make (size_of)

				-- rva
			mp.put_integer_32 (rva)
				-- data_size
			mp.put_integer_32 (data_size)

			Result := mp
		end

feature -- Size

	size_of: INTEGER_32
			-- Size of the structure.
		local
			s: CLI_MANAGED_POINTER_SIZE
		do
			create s.make
				-- rva
			s.put_integer_32
				-- data_size
			s.put_integer_32

			Result := s
		ensure
			is_class: class
		end

end -- class CLI_DIRECTORY

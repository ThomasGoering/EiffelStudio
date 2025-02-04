﻿indexing
	description: "[
		Set of features to access ISE runtime functionality.
		To be used at your own risk.
		]"
	date: "$Date$"
	revision: "$Revision$"

class
	ISE_RUNTIME

feature -- Feature specific to ISE runtime.

	frozen c_standard_clone (other: POINTER): ANY is
			-- New object of same dynamic type as `other'
		external
			"C signature (EIF_REFERENCE): EIF_REFERENCE use %"eif_copy.h%""
		alias
			"eclone"
		ensure
			is_class: class
		end

	frozen c_conforms_to (obj1, obj2: POINTER): BOOLEAN is
			-- Does dynamic type of object attached to `obj1' conform to
			-- dynamic type of object attached to `obj2'?
		external
			"C macro use %"eif_plug.h%""
		alias
			"econfg"
		ensure
			is_class: class
		end

	frozen c_same_type (obj1, obj2: POINTER): BOOLEAN is
			-- Are dynamic type of object attached to `obj1' and
			-- dynamic type of object attached to `obj2' the same?
		external
			"C macro use %"eif_plug.h%""
		alias
			"estypeg"
		ensure
			is_class: class
		end

	frozen c_standard_is_equal (target, source: POINTER): BOOLEAN is
			-- C external performing standard equality
		external
			"C signature (EIF_REFERENCE, EIF_REFERENCE): EIF_BOOLEAN use %"eif_equal.h%""
		alias
			"eequal"
		ensure
			is_class: class
		end

	frozen c_standard_copy (source, target: POINTER) is
			-- C external performing standard copy
		external
			"C signature (EIF_REFERENCE, EIF_REFERENCE) use %"eif_copy.h%""
		alias
			"ecopy"
		ensure
			is_class: class
		end

	frozen c_deep_clone (other: POINTER): ANY is
			-- New object structure recursively duplicated from the one
			-- attached to `other'
		external
			"C signature (EIF_REFERENCE): EIF_REFERENCE use %"eif_copy.h%""
		alias
			"edclone"
		ensure
			is_class: class
		end

	frozen c_deep_equal (a: POINTER; b: like a): BOOLEAN is
			-- Are `a' and `b' attached to recursively isomorphic
			-- object structures?
		external
			"C signature (EIF_REFERENCE, EIF_REFERENCE): EIF_BOOLEAN use %"eif_equal.h%""
		alias
			"ediso"
		ensure
			is_class: class
		end

	frozen c_tagged_out (o: ANY): STRING is
			-- Printable representation of current object
		external
			"C use %"eif_out.h%""
		ensure
			is_class: class
		end

	frozen c_generator_of_type (type_id: INTEGER): STRING is
			-- Name of the generating class of current object
		external
			"C use %"eif_out.h%""
		ensure
			is_class: class
		end

	frozen c_generator (o: POINTER): STRING is
			-- Name of the generating class of current object
		external
			"C macro use %"eif_out.h%""
		ensure
			is_class: class
		end

	frozen check_assert (b: BOOLEAN): BOOLEAN is
		external
			"C use %"eif_copy.h%""
		alias
			"c_check_assert"
		ensure
			is_class: class
		end

 	frozen c_generating_type (obj: POINTER): STRING is
 		external
 			"C macro use %"eif_gen_conf.h%""
 		alias
 			"eif_gen_typename"
		ensure
			is_class: class
 		end

 	frozen c_generating_type_of_type (type_id: INTEGER): STRING is
 		external
 			"C signature (int16): EIF_REFERENCE use %"eif_gen_conf.h%""
 		alias
 			"eif_gen_typename_of_type"
		ensure
			is_class: class
 		end

	frozen sp_count (sp_obj: POINTER): INTEGER is
			-- Count of special object
		external
			"C signature (EIF_REFERENCE): EIF_INTEGER use %"eif_plug.h%""
		ensure
			is_class: class
		end

feature -- Internal C routines

	frozen type_id_from_name (s: POINTER): INTEGER is
			-- Dynamic type whose name is represented by `s'.
		external
			"C signature (char *): EIF_INTEGER use %"eif_cecil.h%""
		alias
			"eif_type_id"
		ensure
			is_class: class
		end

	frozen dynamic_type (object: POINTER): INTEGER is
			-- Dynamic type of `object'.
		external
			"C macro signature (EIF_REFERENCE): EIF_INTEGER use %"eif_macros.h%""
		alias
			"Dftype"
		ensure
			is_class: class
		end
		
end

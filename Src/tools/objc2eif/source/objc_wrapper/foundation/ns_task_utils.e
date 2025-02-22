note
	description: "Auto-generated Objective-C wrapper class"
	date: "$Date$"
	revision: "$Revision$"

class
	NS_TASK_UTILS

inherit
	NS_OBJECT_UTILS
		redefine
			wrapper_objc_class_name,
			is_subclass_instance
		end


feature -- NSTaskConveniences

	launched_task_with_launch_path__arguments_ (a_path: detachable NS_STRING; a_arguments: detachable NS_ARRAY): detachable NS_TASK
			-- Auto generated Objective-C wrapper.
		local
			result_pointer: POINTER
			l_objc_class: OBJC_CLASS
			a_path__item: POINTER
			a_arguments__item: POINTER
		do
			if attached a_path as a_path_attached then
				a_path__item := a_path_attached.item
			end
			if attached a_arguments as a_arguments_attached then
				a_arguments__item := a_arguments_attached.item
			end
			create l_objc_class.make_with_name (get_class_name)
			check l_objc_class_registered: l_objc_class.registered end
			result_pointer := objc_launched_task_with_launch_path__arguments_ (l_objc_class.item, a_path__item, a_arguments__item)
			if result_pointer /= default_pointer then
				if attached objc_get_eiffel_object (result_pointer) as existing_eiffel_object then
					check attached {like launched_task_with_launch_path__arguments_} existing_eiffel_object as valid_result then
						Result := valid_result
					end
				else
					check attached {like launched_task_with_launch_path__arguments_} new_eiffel_object (result_pointer, True) as valid_result_pointer then
						Result := valid_result_pointer
					end
				end
			end
		end

feature {NONE} -- NSTaskConveniences Externals

	objc_launched_task_with_launch_path__arguments_ (a_class_object: POINTER; a_path: POINTER; a_arguments: POINTER): POINTER
			-- Auto generated Objective-C wrapper.
		external
			"C inline use <Foundation/Foundation.h>"
		alias
			"[
				return (EIF_POINTER)[(Class)$a_class_object launchedTaskWithLaunchPath:$a_path arguments:$a_arguments];
			 ]"
		end

feature {NONE} -- Implementation

	wrapper_objc_class_name: STRING
			-- The class name used for classes of the generated wrapper classes.
		do
			Result := "NSTask"
		end

	is_subclass_instance: BOOLEAN
			-- <Precursor>
		do
			Result := False
		end

end

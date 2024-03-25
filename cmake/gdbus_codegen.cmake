find_program(GDBUS_CODEGEN gdbus-codegen)
if(NOT GDBUS_CODEGEN)
	message(FATAL_ERROR "Could not find gdbus-codegen binary, which is required to build ${PROJECT_NAME}")
endif(NOT GDBUS_CODEGEN)

function(gdbus_codegen _xml _out_filename _args0)
	foreach(_arg ${_args0} ${ARGN})
		list(APPEND _args "${_arg}")
	endforeach(_arg)
	add_custom_command(
		OUTPUT ${_out_filename}
		COMMAND ${GDBUS_CODEGEN}
		ARGS ${_args} --output ${_out_filename} ${_xml}
		MAIN_DEPENDENCY ${_xml}
		VERBATIM
	)
endfunction(gdbus_codegen)

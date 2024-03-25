find_program(GLIB_MKENUMS glib-mkenums)
if(NOT GLIB_MKENUMS)
	message(FATAL_ERROR "Could not find glib-mkenums binary, which is required to build ${PROJECT_NAME}")
endif(NOT GLIB_MKENUMS)

set(GLIB_MKENUMS_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR})

function(glib_mkenums _out_dir _out_filename_noext _enums_header0)
    foreach(_enums_header ${_enums_header0} ${ARGN})
        list(APPEND _enums_headers "${_enums_header}")
    endforeach(_enums_header)
    # header template
    set(HEADER_TMPL "
/*** BEGIN file-header ***/
#pragma once

/* Include the main project header */
#include <glib-object.h>

G_BEGIN_DECLS
/*** END file-header ***/

/*** BEGIN file-production ***/

/* enumerations from \"@basename@\" */
/*** END file-production ***/

/*** BEGIN value-header ***/
GType @enum_name@_get_type (void) G_GNUC_CONST;
#define @ENUMPREFIX@_TYPE_@ENUMSHORT@ (@enum_name@_get_type ())
/*** END value-header ***/

/*** BEGIN file-tail ***/
G_END_DECLS
/*** END file-tail ***/")
    set(HEADER_TMPL_FILE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/enumtypes-${_out_filename_noext}.h.tmpl")
    file(WRITE ${HEADER_TMPL_FILE} "${HEADER_TMPL}\n")
    add_custom_command(
		OUTPUT ${_out_dir}/${_out_filename_noext}.h
		COMMAND ${GLIB_MKENUMS} --template ${HEADER_TMPL_FILE} ${_enums_headers} >${_out_dir}/${_out_filename_noext}.h
		DEPENDS ${_enums_headers}
	)
    # source template
    set(SOURCE_TMPL "
/*** BEGIN file-header ***/
#include \"${_out_filename_noext}.h\"

/*** END file-header ***/

/*** BEGIN file-production ***/
/* enumerations from \"@basename@\" */
#include \"@basename@\"

/*** END file-production ***/

/*** BEGIN value-header ***/
GType
@enum_name@_get_type (void)
{
    static gsize static_g_@type@_type_id;

    if (g_once_init_enter (&static_g_@type@_type_id))
    {
        static const G@Type@Value values[] = {
/*** END value-header ***/

/*** BEGIN value-production ***/
            { @VALUENAME@, \"@VALUENAME@\", \"@valuenick@\" },
/*** END value-production ***/

/*** BEGIN value-tail ***/
            { 0, NULL, NULL }
        };

        GType g_@type@_type_id =
        g_@type@_register_static (g_intern_static_string (\"@EnumName@\"), values);

        g_once_init_leave (&static_g_@type@_type_id, g_@type@_type_id);
    }
    return static_g_@type@_type_id;
}

/*** END value-tail ***/")
    set(SOURCE_TMPL_FILE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/enumtypes-${_out_filename_noext}.c.tmpl")
    file(WRITE ${SOURCE_TMPL_FILE} "${SOURCE_TMPL}\n")
    add_custom_command(
		OUTPUT ${_out_dir}/${_out_filename_noext}.c
		COMMAND ${GLIB_MKENUMS} --template ${SOURCE_TMPL_FILE} ${_enums_headers} >${_out_dir}/${_out_filename_noext}.c
		DEPENDS ${_enums_headers}
	)
endfunction(glib_mkenums)

find_package(Java QUIET COMPONENTS Runtime)

if("$ENV{Antlr4_DIR}" STREQUAL "")
  set(Antlr4_ROOT ${SPIDER_DB_THIRD_PARTY_DIR}/antlr4-4.10)
elseif()
  set(Antlr4_ROOT "$ENV{Antlr4_DIR}")
endif()
 
if(NOT Antlr4_GENERATOR)
  find_program(Antlr4_GENERATOR
               NAMES antlr.jar antlr4.jar antlr-4.jar antlr-4.10.1-complete.jar)
endif()
 
################################################################
# Find Antlr4 generator
################################################################

if (NOT Antlr4_GENERATOR)
  find_program(
    Antlr4_GENERATOR
    NAMES antlr-4.10.1-complete.jar
    PATHS ${Antlr4_ROOT}
    PATH_SUFFIXES bin
  )
endif()


if(Antlr4_GENERATOR AND Java_JAVA_EXECUTABLE)
  execute_process(
      COMMAND ${Java_JAVA_EXECUTABLE} -jar ${Antlr4_GENERATOR}
      OUTPUT_VARIABLE Antlr4_COMMAND_OUTPUT
      ERROR_VARIABLE Antlr4_COMMAND_ERROR
      RESULT_VARIABLE Antlr4_COMMAND_RESULT
      OUTPUT_STRIP_TRAILING_WHITESPACE)

  if(Antlr4_COMMAND_RESULT EQUAL 0)
    string(REGEX MATCH "Version [0-9]+(\\.[0-9])*" Antlr4_VERSION ${Antlr4_COMMAND_OUTPUT})
    string(REPLACE "Version " "" Antlr4_VERSION ${Antlr4_VERSION})
  else()
    message(
        SEND_ERROR
        "Command '${Java_JAVA_EXECUTABLE} -jar ${Antlr4_GENERATOR}' "
        "failed with the output '${Antlr4_COMMAND_ERROR}'")
  endif()

  macro(Antlr4_TARGET Name InputFile)
    set(Antlr4_OPTIONS LEXER PARSER LISTENER VISITOR)
    set(Antlr4_ONE_VALUE_ARGS PACKAGE OUTPUT_DIRECTORY DEPENDS_Antlr4)
    set(Antlr4_MULTI_VALUE_ARGS COMPILE_FLAGS DEPENDS)
    cmake_parse_arguments(Antlr4_TARGET
                          "${Antlr4_OPTIONS}"
                          "${Antlr4_ONE_VALUE_ARGS}"
                          "${Antlr4_MULTI_VALUE_ARGS}"
                          ${ARGN})

    set(Antlr4_${Name}_INPUT ${InputFile})

    get_filename_component(Antlr4_INPUT ${InputFile} NAME_WE)

    if(Antlr4_TARGET_OUTPUT_DIRECTORY)
      set(Antlr4_${Name}_OUTPUT_DIR ${Antlr4_TARGET_OUTPUT_DIRECTORY})
    else()
      set(Antlr4_${Name}_OUTPUT_DIR
          ${CMAKE_CURRENT_BINARY_DIR}/antlr4cpp_generated_src/${Antlr4_INPUT})
    endif()

    unset(Antlr4_${Name}_CXX_OUTPUTS)

    if((Antlr4_TARGET_LEXER AND NOT Antlr4_TARGET_PARSER) OR
       (Antlr4_TARGET_PARSER AND NOT Antlr4_TARGET_LEXER))
      list(APPEND Antlr4_${Name}_CXX_OUTPUTS
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}.h
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}.cpp)
      set(Antlr4_${Name}_OUTPUTS
          ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}.interp
          ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}.tokens)
    else()
      list(APPEND Antlr4_${Name}_CXX_OUTPUTS
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}Lexer.h
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}Lexer.cpp
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}Parser.h
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}Parser.cpp)
      list(APPEND Antlr4_${Name}_OUTPUTS
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}Lexer.interp
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}Lexer.tokens)
    endif()

    if(Antlr4_TARGET_LISTENER)
      list(APPEND Antlr4_${Name}_CXX_OUTPUTS
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}BaseListener.h
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}BaseListener.cpp
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}Listener.h
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}Listener.cpp)
      list(APPEND Antlr4_TARGET_COMPILE_FLAGS -listener)
    endif()

    if(Antlr4_TARGET_VISITOR)
      list(APPEND Antlr4_${Name}_CXX_OUTPUTS
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}BaseVisitor.h
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}BaseVisitor.cpp
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}Visitor.h
           ${Antlr4_${Name}_OUTPUT_DIR}/${Antlr4_INPUT}Visitor.cpp)
      list(APPEND Antlr4_TARGET_COMPILE_FLAGS -visitor)
    endif()

    if(Antlr4_TARGET_PACKAGE)
      list(APPEND Antlr4_TARGET_COMPILE_FLAGS -package ${Antlr4_TARGET_PACKAGE})
    endif()

    list(APPEND Antlr4_${Name}_OUTPUTS ${Antlr4_${Name}_CXX_OUTPUTS})

    if(Antlr4_TARGET_DEPENDS_Antlr4)
      if(Antlr4_${Antlr4_TARGET_DEPENDS_Antlr4}_INPUT)
        list(APPEND Antlr4_TARGET_DEPENDS
             ${Antlr4_${Antlr4_TARGET_DEPENDS_Antlr4}_INPUT})
        list(APPEND Antlr4_TARGET_DEPENDS
             ${Antlr4_${Antlr4_TARGET_DEPENDS_Antlr4}_OUTPUTS})
      else()
        message(SEND_ERROR
                "Antlr4 target '${Antlr4_TARGET_DEPENDS_Antlr4}' not found")
      endif()
    endif()

    add_custom_command(
        OUTPUT ${Antlr4_${Name}_OUTPUTS}
        COMMAND ${Java_JAVA_EXECUTABLE} -jar ${Antlr4_GENERATOR}
                ${InputFile}
                -o ${Antlr4_${Name}_OUTPUT_DIR}
                -no-listener
                -Dlanguage=Cpp
                ${Antlr4_TARGET_COMPILE_FLAGS}
        DEPENDS ${InputFile}
                ${Antlr4_TARGET_DEPENDS}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Building ${Name} with Antlr4 ${Antlr4_VERSION}")
  endmacro(Antlr4_TARGET)

endif(Antlr4_GENERATOR AND Java_JAVA_EXECUTABLE)
###############################################################
# find path
###############################################################

find_path(Antlr4_runtime_INCLUDE_DIR antlr4-runtime/antlr4-runtime.h
  PATHS ${Antlr4_ROOT}
  PATH_SUFFIXES include
)

find_path(Antlr4_runtime_ANOTHER_INCLUDE_DIR antlr4-runtime.h
  PATHS ${Antlr4_ROOT}/include/antlr4-runtime
)

find_library(Antlr4_runtime_LIBRARY
  NAMES libantlr4-runtime.a
  PATHS ${Antlr4_ROOT}
  PATH_SUFFIXES lib64 
)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    Antlr4
    REQUIRED_VARS 
      Antlr4_GENERATOR Java_JAVA_EXECUTABLE Antlr4_runtime_INCLUDE_DIR Antlr4_runtime_LIBRARY Antlr4_runtime_ANOTHER_INCLUDE_DIR
    VERSION_VAR 
      Antlr4_VERSION
)

if(Antlr4_FOUND)
  add_library(Antlr4::runtime STATIC IMPORTED)
  set(Antlr4_INCLUDE_DIR ${Antlr4_runtime_INCLUDE_DIR} ${Antlr4_runtime_ANOTHER_INCLUDE_DIR})
  set_target_properties(Antlr4::runtime
    PROPERTIES
    IMPORTED_LOCATION ${Antlr4_runtime_LIBRARY}
    INTERFACE_INCLUDE_DIRECTORIES "${Antlr4_INCLUDE_DIR}"
  )
endif()
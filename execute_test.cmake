# Common settings for CTest runs
#######################################################################

# determine the hostname and set the site name accordingly
site_name(CTEST_SITE)

# generate the build name
set(CTEST_BUILD_NAME       "${CMAKE_SYSTEM_NAME}-${COMPILER_NAME}-${COMPILER_VERSION}-${CTEST_BUILD_CONFIGURATION}-${TARGET_NAME}")

# generate the build directory
set(CTEST_BINARY_DIRECTORY "${ROOT_DIRECTORY}/${CTEST_BUILD_NAME}")


ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})

find_program(CTEST_GIT_COMMAND NAMES git)
find_program(CTEST_COVERAGE_COMMAND NAMES gcov)
find_program(CTEST_MEMORYCHECK_COMMAND NAMES valgrind)



ctest_start("Nightly")

message("USED PROJECTS: ${USED_PROJECTS}")

# Updating repositories according to configured branches
FOREACH(PROJECT ${USED_PROJECTS})

    message("${PROJECT} BRANCH: ${${PROJECT}_BRANCH}")
    message("${PROJECT} PATH: $ENV{${PROJECT}PATH}")
    execute_process( COMMAND "${CTEST_GIT_COMMAND}" fetch WORKING_DIRECTORY "$ENV{${PROJECT}PATH}")
    execute_process( COMMAND "${CTEST_GIT_COMMAND}" checkout ${${PROJECT}_BRANCH} WORKING_DIRECTORY "$ENV{${PROJECT}PATH}")
    execute_process( COMMAND "${CTEST_GIT_COMMAND}" pull WORKING_DIRECTORY "$ENV{${PROJECT}PATH}")

ENDFOREACH()


SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)


message("CTEST_BUILD_OPTIONS: ${CTEST_BUILD_OPTIONS} ")

set(CTEST_CONFIGURE_COMMAND "${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CONFIGURE_COMMAND "${CTEST_CONFIGURE_COMMAND} ${CTEST_BUILD_OPTIONS}")
set(CTEST_CONFIGURE_COMMAND "${CTEST_CONFIGURE_COMMAND} \"-G${CTEST_CMAKE_GENERATOR}\"")
set(CTEST_CONFIGURE_COMMAND "${CTEST_CONFIGURE_COMMAND} \"${CTEST_SOURCE_DIRECTORY}\"")


ctest_configure()
ctest_build()
ctest_test()
if (WITH_COVERAGE AND CTEST_COVERAGE_COMMAND)
  ctest_coverage()
endif (WITH_COVERAGE AND CTEST_COVERAGE_COMMAND)
if (WITH_MEMCHECK AND CTEST_MEMORYCHECK_COMMAND)
  ctest_memcheck()
endif (WITH_MEMCHECK AND CTEST_MEMORYCHECK_COMMAND)
ctest_submit()


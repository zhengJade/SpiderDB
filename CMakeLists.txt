cmake_minimum_required(VERSION 3.15)

project(EasyDB)

set(SPIDER_DB_THIRD_PARTY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty)
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)
find_package(Antlr4)
add_subdirectory(src)


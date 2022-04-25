set(SQL_SRC main.cpp)

add_executable(hello ${SQL_SRC})

target_link_libraries(hello PRIVATE Antlr4::runtime)
cmake_minimum_required(VERSION 3.14)
project(PozoleBackend CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(drogon CONFIG REQUIRED)

file(GLOB_RECURSE SRC_FILES
    "main.cpp"
    "controllers/*.cc"
)

add_executable(${PROJECT_NAME} ${SRC_FILES})
target_link_libraries(${PROJECT_NAME} PRIVATE drogon::drogon)

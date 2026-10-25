cmake_minimum_required(VERSION 3.16)

# ----------------- 交叉编译环境硬编码 -----------------
# ⚠️ 必须放在 project() 之前，否则 CMake 会使用默认缓存的 x86 编译器
set(CMAKE_C_COMPILER "/home/lv/Linux/imx6ull_ws/GCC/arm-gnu-toolchain-15.2.rel1-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-gcc")
set(CMAKE_CXX_COMPILER "/home/lv/Linux/imx6ull_ws/GCC/arm-gnu-toolchain-15.2.rel1-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-g++")
# ------------------------------------------------------

project(mxui VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 导出 compile_commands.json，供 clangd / VSCode 做代码索引，消除红色波浪线
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ----------------- 库搜索路径配置 -----------------
# 强制 CMake 优先去这个目录寻找 Qt5 库和构建工具
set(CMAKE_PREFIX_PATH "/home/lv/Linux/imx6ull_ws/tools/qt-everywhere-src-5.15.19/install/" ${CMAKE_PREFIX_PATH})
# --------------------------------------------------

find_package(Qt5 REQUIRED COMPONENTS Core Gui Qml Quick Multimedia)

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)

file(GLOB_RECURSE SRC_FILES "src/*.cpp")
file(GLOB_RECURSE INC_FILES "src/*.h")

add_executable(mxui
    main.cpp
    ${SRC_FILES}
    ${INC_FILES}
    qml.qrc
)

target_link_libraries(mxui PRIVATE
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::Multimedia
)

# install(CODE "
#     message(STATUS \"开始部署 mxui 到开发板...\")
#     execute_process(
#         COMMAND ssh root@192.168.1.109 \"mkdir -p /root/app\"
#         COMMAND scp \${CMAKE_BINARY_DIR}/mxui root@192.168.1.109:/root/app/
#         RESULT_VARIABLE DEPLOY_RESULT
#     )
#     if(NOT DEPLOY_RESULT EQUAL 0)
#         message(FATAL_ERROR \"SSH 部署失败，请检查网络连接或免密登录配置！\")
#     else()
#         message(STATUS \"部署成功：/root/app/mxui\")
#     endif()
# ")
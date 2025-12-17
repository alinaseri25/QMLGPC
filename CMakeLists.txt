cmake_minimum_required(VERSION 3.16)

project(QMLGPC VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Positioning)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appQMLGPC
    main.cpp
    backend/GpsManager.cpp
    backend/GpsManager.h
)

qt_add_qml_module(appQMLGPC
    URI QMLGPC
    VERSION 1.0
    QML_FILES
        Main.qml
        components/Header.qml
        components/GpsDataCard.qml
        components/SatelliteBar.qml
        components/SatelliteView.qml
        panels/GpsPanel.qml
        theme/Theme.qml
    RESOURCES
)

set_target_properties(appQMLGPC PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appQMLGPC
    PRIVATE
        Qt6::Quick
        Qt6::Positioning
)

include(GNUInstallDirs)
install(TARGETS appQMLGPC
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

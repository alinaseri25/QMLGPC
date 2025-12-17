cmake_minimum_required(VERSION 3.16)

project(QMLGPC VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS
    Core
    Quick
    Positioning
)

qt_standard_project_setup(REQUIRES 6.5)

# =====================================================
# Main Application
# =====================================================
qt_add_executable(appQMLGPC
    main.cpp
    backend/GpsManager.h
    backend/GpsManager.cpp
)

# =====================================================
# QMLGPC Module
# =====================================================
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
)

# =====================================================
# Link Libraries
# =====================================================
target_link_libraries(appQMLGPC PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Positioning
)

set_target_properties(appQMLGPC PROPERTIES
    WIN32_EXECUTABLE TRUE
)

install(TARGETS appQMLGPC
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# =====================================================
# Android Settings
# =====================================================
if(ANDROID)
    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android" CACHE INTERNAL "")
    set(QT_ANDROID_PACKAGE_NAME "org.verya.QMLGPC" CACHE INTERNAL "")
    set(QT_ANDROID_VERSION_NAME "1.0.0" CACHE INTERNAL "")
    set(QT_ANDROID_VERSION_CODE "1" CACHE INTERNAL "")
    set(QT_ANDROID_TARGET_SDK_VERSION "35" CACHE INTERNAL "")
    set(QT_ANDROID_MIN_SDK_VERSION "28" CACHE INTERNAL "")

    set_property(TARGET appQMLGPC APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
        ${ANDROID_PACKAGE_SOURCE_DIR}
    )
endif()

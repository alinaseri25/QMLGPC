cmake_minimum_required(VERSION 3.16)

project(QMLGPC VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS
    Core
    Quick
    Positioning
    Sensors
)

qt_standard_project_setup(REQUIRES 6.8)

# =====================================================
# فایل‌های پروژه
# =====================================================
qt_add_executable(QMLGPC
    main.cpp
    backend/GpsManager.h
    backend/GpsManager.cpp
)

qt_add_qml_module(QMLGPC
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
        qtquickcontrols2.conf
)

# =====================================================
# لینک کتابخانه‌ها
# =====================================================
target_link_libraries(QMLGPC PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Positioning
    Qt6::Sensors
)

# =====================================================
# کپی qtquickcontrols2.conf (فقط Desktop)
# =====================================================
if(NOT ANDROID)
    add_custom_command(TARGET QMLGPC POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_CURRENT_SOURCE_DIR}/qtquickcontrols2.conf"
            "$<TARGET_FILE_DIR:QMLGPC>/qtquickcontrols2.conf"
        COMMENT "Copying qtquickcontrols2.conf to build directory"
    )
endif()

# =====================================================
# تنظیمات نصب
# =====================================================
install(TARGETS QMLGPC
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

if(NOT ANDROID)
    install(FILES qtquickcontrols2.conf
        DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
endif()

if(ANDROID)
    set_target_properties(QMLGPC PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR
            ${CMAKE_CURRENT_SOURCE_DIR}/android
    )

    set(QT_ANDROID_TARGET_SDK_VERSION "35" CACHE INTERNAL "")
endif()

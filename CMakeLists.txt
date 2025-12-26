cmake_minimum_required(VERSION 3.16)

project(QMLGPC VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS
    Core
    Quick
    Positioning
    Sensors
)

qt_standard_project_setup(REQUIRES 6.5)

# =====================================================
# تنظیمات Android
# =====================================================
if(ANDROID)
    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android" CACHE INTERNAL "")
    set(QT_ANDROID_PACKAGE_NAME "org.verya.QMLGPC" CACHE INTERNAL "")
    set(QT_ANDROID_VERSION_NAME "1.0.0" CACHE INTERNAL "")
    set(QT_ANDROID_VERSION_CODE "1" CACHE INTERNAL "")
    set(QT_ANDROID_TARGET_SDK_VERSION "35" CACHE INTERNAL "")
    set(QT_ANDROID_MIN_SDK_VERSION "28" CACHE INTERNAL "")

    set(ANDROID_EXTRA_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/android/AndroidManifest.xml"
        "${CMAKE_CURRENT_SOURCE_DIR}/android/build.gradle"
        "${CMAKE_CURRENT_SOURCE_DIR}/android/gradle.properties"
        "${CMAKE_CURRENT_SOURCE_DIR}/android/gradlew"
        "${CMAKE_CURRENT_SOURCE_DIR}/android/gradlew.bat"
    )

    message(STATUS "Android build detected")
    message(STATUS "Android package source: ${ANDROID_PACKAGE_SOURCE_DIR}")
    message(STATUS "Android package name: ${QT_ANDROID_PACKAGE_NAME}")
endif()

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

# =====================================================
# تنظیمات اضافی Android
# =====================================================
if(ANDROID)
    set_property(TARGET QMLGPC APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
        ${ANDROID_PACKAGE_SOURCE_DIR}
    )

    message(STATUS "Building for Android ABI: ${ANDROID_ABI}")

    add_custom_command(TARGET QMLGPC POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "Android files configured in: ${ANDROID_PACKAGE_SOURCE_DIR}"
    )
endif()

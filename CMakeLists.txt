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
# تنظیمات Android
# =====================================================
if(ANDROID)
    # تنظیم مسیر پوشه Android
    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android" CACHE INTERNAL "")

    # Package Name
    set(QT_ANDROID_PACKAGE_NAME "org.verya.QMLGPC" CACHE INTERNAL "")

    # تنظیمات اضافی Android
    set(QT_ANDROID_VERSION_NAME "1.0.0" CACHE INTERNAL "")
    set(QT_ANDROID_VERSION_CODE "1" CACHE INTERNAL "")
    set(QT_ANDROID_TARGET_SDK_VERSION "35" CACHE INTERNAL "")
    set(QT_ANDROID_MIN_SDK_VERSION "28" CACHE INTERNAL "")

    # فایل‌های Android که باید کپی شوند
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
)

# =====================================================
# لینک کتابخانه‌ها
# =====================================================
target_link_libraries(QMLGPC PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Positioning
)

# =====================================================
# تنظیمات نصب
# =====================================================
install(TARGETS QMLGPC
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# =====================================================
# تنظیمات اضافی Android
# =====================================================
if(ANDROID)
    # دسترسی‌های مورد نیاز
    set_property(TARGET QMLGPC APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
        ${ANDROID_PACKAGE_SOURCE_DIR}
    )

    # تنظیم ABI
    if(NOT ANDROID_ABI)
        set(ANDROID_ABI "arm64-v8a")
    endif()

    message(STATUS "Building for Android ABI: ${ANDROID_ABI}")

    # اطمینان از کپی شدن فایل‌های Android
    add_custom_command(TARGET QMLGPC POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E echo "Android files configured in: ${ANDROID_PACKAGE_SOURCE_DIR}"
    )
endif()

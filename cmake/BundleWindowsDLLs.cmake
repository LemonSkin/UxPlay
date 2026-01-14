# CMake script to bundle Windows DLLs with UxPlay executable
# This script is called during installation on Windows

if(NOT WIN32)
    message(STATUS "Not Windows, skipping DLL bundling")
    return()
endif()

message(STATUS "Bundling Windows DLLs for standalone deployment...")

# Find MSYS2/MinGW bin directory
set(MINGW_BIN "")
if(DEFINED ENV{MINGW_PREFIX})
    set(MINGW_BIN "$ENV{MINGW_PREFIX}/bin")
elseif(EXISTS "C:/msys64/ucrt64/bin")
    set(MINGW_BIN "C:/msys64/ucrt64/bin")
elseif(EXISTS "C:/msys64/mingw64/bin")
    set(MINGW_BIN "C:/msys64/mingw64/bin")
else()
    message(WARNING "Could not find MinGW bin directory. DLLs will not be bundled.")
    return()
endif()

message(STATUS "Using MinGW bin directory: ${MINGW_BIN}")

# List of required DLLs
set(REQUIRED_DLLS
    # GLib
    "libglib-2.0-0.dll"
    "libgobject-2.0-0.dll"
    "libgmodule-2.0-0.dll"
    "libgio-2.0-0.dll"
    
    # GStreamer core
    "libgstreamer-1.0-0.dll"
    "libgstbase-1.0-0.dll"
    "libgstapp-1.0-0.dll"
    "libgstvideo-1.0-0.dll"
    "libgstaudio-1.0-0.dll"
    "libgstsdp-1.0-0.dll"
    "libgstrtp-1.0-0.dll"
    "libgstpbutils-1.0-0.dll"
    
    # Dependencies
    "libintl-8.dll"
    "libwinpthread-1.dll"
    "libiconv-2.dll"
    "libffi-8.dll"
    "libpcre2-8-0.dll"
    "liborc-0.4-0.dll"
    "zlib1.dll"
    
    # libplist
    "libplist-2.0-4.dll"
    
    # OpenSSL
    "libcrypto-3-x64.dll"
    "libssl-3-x64.dll"
)

# Alternative DLL names (fallbacks)
set(DLL_ALTERNATIVES
    "libffi-8.dll;libffi-7.dll"
    "libpcre2-8-0.dll;libpcre-1.dll"
    "zlib1.dll;libz.dll"
    "libplist-2.0-4.dll;libplist-2.0-3.dll"
    "libcrypto-3-x64.dll;libcrypto-1_1-x64.dll"
    "libssl-3-x64.dll;libssl-1_1-x64.dll"
)

# Copy DLLs to installation directory
foreach(DLL ${REQUIRED_DLLS})
    set(DLL_PATH "${MINGW_BIN}/${DLL}")
    if(EXISTS "${DLL_PATH}")
        file(INSTALL "${DLL_PATH}" DESTINATION "${CMAKE_INSTALL_PREFIX}/bin")
        message(STATUS "  Copied: ${DLL}")
    else()
        # Try alternatives
        set(FOUND FALSE)
        foreach(ALT_PAIR ${DLL_ALTERNATIVES})
            string(REPLACE ";" "|" ALT_PAIR_ESCAPED "${ALT_PAIR}")
            if("${DLL}" MATCHES "^([^|]+)")
                string(REGEX REPLACE "^([^|]+).*" "\\1" PRIMARY "${ALT_PAIR}")
                if("${DLL}" STREQUAL "${PRIMARY}")
                    string(REPLACE "${PRIMARY}|" "" ALTERNATIVES "${ALT_PAIR_ESCAPED}")
                    string(REPLACE "|" ";" ALT_LIST "${ALTERNATIVES}")
                    foreach(ALT ${ALT_LIST})
                        set(ALT_PATH "${MINGW_BIN}/${ALT}")
                        if(EXISTS "${ALT_PATH}")
                            file(INSTALL "${ALT_PATH}" DESTINATION "${CMAKE_INSTALL_PREFIX}/bin")
                            message(STATUS "  Copied (alternative): ${ALT}")
                            set(FOUND TRUE)
                            break()
                        endif()
                    endforeach()
                endif()
            endif()
            if(FOUND)
                break()
            endif()
        endforeach()
        
        if(NOT FOUND)
            message(WARNING "  Missing: ${DLL}")
        endif()
    endif()
endforeach()

# Copy GStreamer plugins
set(GST_PLUGIN_DIR "")
if(DEFINED ENV{MINGW_PREFIX})
    set(GST_PLUGIN_DIR "$ENV{MINGW_PREFIX}/lib/gstreamer-1.0")
elseif(EXISTS "C:/msys64/ucrt64/lib/gstreamer-1.0")
    set(GST_PLUGIN_DIR "C:/msys64/ucrt64/lib/gstreamer-1.0")
elseif(EXISTS "C:/msys64/mingw64/lib/gstreamer-1.0")
    set(GST_PLUGIN_DIR "C:/msys64/mingw64/lib/gstreamer-1.0")
endif()

if(GST_PLUGIN_DIR AND EXISTS "${GST_PLUGIN_DIR}")
    message(STATUS "Copying GStreamer plugins from: ${GST_PLUGIN_DIR}")
    
    set(REQUIRED_PLUGINS
        "libgstcoreelements.dll"
        "libgstapp.dll"
        "libgstvideoparsersbad.dll"
        "libgstlibav.dll"
        "libgstaudioconvert.dll"
        "libgstaudioresample.dll"
        "libgstaudioparsers.dll"
        "libgstisomp4.dll"
        "libgstmatroska.dll"
        "libgstplayback.dll"
        "libgsttypefindfunctions.dll"
        "libgstautodetect.dll"
        "libgstvideoconvertscale.dll"
        "libgstvideoconvert.dll"
        "libgstvideoscale.dll"
    )
    
    file(MAKE_DIRECTORY "${CMAKE_INSTALL_PREFIX}/lib/gstreamer-1.0")
    
    foreach(PLUGIN ${REQUIRED_PLUGINS})
        set(PLUGIN_PATH "${GST_PLUGIN_DIR}/${PLUGIN}")
        if(EXISTS "${PLUGIN_PATH}")
            file(INSTALL "${PLUGIN_PATH}" DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/gstreamer-1.0")
            message(STATUS "  Plugin: ${PLUGIN}")
        else()
            message(WARNING "  Missing plugin: ${PLUGIN}")
        endif()
    endforeach()
else()
    message(WARNING "Could not find GStreamer plugin directory")
endif()

message(STATUS "Windows DLL bundling complete")

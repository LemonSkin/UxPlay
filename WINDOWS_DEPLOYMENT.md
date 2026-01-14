# Windows Deployment Guide for UxPlay

This guide explains how to create a standalone Windows executable package that can run outside the MSYS2 environment.

## Overview

UxPlay depends on GStreamer and GLib libraries which are dynamically linked. To create a portable Windows application, you need to bundle all required DLLs with the executable.

## Method 1: Automatic Bundling with CMake Install (Recommended)

When you run `cmake --install`, the required DLLs will be automatically copied to the installation directory.

### Steps:

1. **Build UxPlay in MSYS2:**
   ```bash
   cd /path/to/UxPlay
   mkdir build
   cd build
   cmake ..
   cmake --build .
   ```

2. **Install with automatic DLL bundling:**
   ```bash
   cmake --install . --prefix ../uxplay-windows-portable
   ```

3. **The `uxplay-windows-portable` directory will contain:**
   - `bin/uxplay.exe` - The executable
   - `bin/*.dll` - All required DLLs
   - `lib/gstreamer-1.0/*.dll` - GStreamer plugins
   - Documentation files

4. **Test the standalone package:**
   - Copy the entire `uxplay-windows-portable` directory to a Windows machine without MSYS2
   - Run `bin/uxplay.exe` from Command Prompt or PowerShell

## Method 2: Manual Packaging Script

Use the provided shell script to create a portable package:

```bash
cd /path/to/UxPlay
./package_windows.sh
```

This creates a `uxplay-windows-portable` directory with all necessary files.

### Create a ZIP archive:
```bash
zip -r uxplay-windows-portable.zip uxplay-windows-portable
```

## What Gets Bundled

### Core Libraries:
- **GLib:** libglib-2.0-0.dll, libgobject-2.0-0.dll, libgio-2.0-0.dll, libgmodule-2.0-0.dll
- **GStreamer:** libgstreamer-1.0-0.dll, libgstbase-1.0-0.dll, libgstapp-1.0-0.dll, libgstvideo-1.0-0.dll, libgstaudio-1.0-0.dll, libgstsdp-1.0-0.dll
- **Dependencies:** libintl-8.dll, libwinpthread-1.dll, libiconv-2.dll, libffi-8.dll, libpcre2-8-0.dll
- **libplist:** libplist-2.0-4.dll
- **OpenSSL:** libcrypto-3-x64.dll, libssl-3-x64.dll

### GStreamer Plugins (in lib/gstreamer-1.0/):
- Core elements, parsers, codecs
- MP4 muxer for recording functionality
- Audio/video converters and resamplers

## Static Linking

The CMakeLists.txt has been modified to statically link the C/C++ runtime libraries on Windows:
- `-static-libgcc` - Static link GCC runtime
- `-static-libstdc++` - Static link C++ standard library

This reduces the number of DLL dependencies but GStreamer and GLib must remain dynamically linked due to their plugin architecture.

## Troubleshooting

### Missing DLL Errors

If you get "DLL not found" errors:

1. **Check which DLLs are missing:**
   ```bash
   ldd uxplay.exe | grep "not found"
   ```

2. **Copy missing DLLs from MSYS2:**
   - Location: `C:\msys64\ucrt64\bin\` (or your MSYS2 installation path)
   - Copy the missing DLL to the same directory as `uxplay.exe`

3. **For GStreamer plugin errors:**
   - Ensure `lib/gstreamer-1.0/` directory exists next to the executable
   - Copy plugins from `C:\msys64\ucrt64\lib\gstreamer-1.0\`

### GStreamer Plugin Loading Issues

Set the `GST_PLUGIN_PATH` environment variable to point to the bundled plugins:

```cmd
set GST_PLUGIN_PATH=%CD%\lib\gstreamer-1.0
uxplay.exe
```

Or create a batch file wrapper (`uxplay.bat`):
```batch
@echo off
set GST_PLUGIN_PATH=%~dp0lib\gstreamer-1.0
"%~dp0bin\uxplay.exe" %*
```

## Distribution

When distributing UxPlay for Windows:

1. Include the entire directory structure (bin/, lib/, docs/)
2. Provide a README with usage instructions
3. Consider creating an installer using NSIS or Inno Setup
4. Include LICENSE files for all bundled libraries

## Size Optimization

The portable package will be approximately 50-100 MB due to GStreamer dependencies. To reduce size:

- Remove unused GStreamer plugins from `lib/gstreamer-1.0/`
- Use UPX to compress the executable and DLLs (may trigger antivirus false positives)
- Only include essential documentation

## Notes

- The bundled DLLs are from MSYS2's UCRT64 environment (Universal C Runtime)
- UCRT64 is the recommended environment for modern Windows applications
- Ensure you have the correct architecture (x64) for all DLLs
- The package is portable and doesn't require installation
- GStreamer plugins are loaded dynamically at runtime

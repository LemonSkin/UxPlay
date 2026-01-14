#!/bin/bash
# Windows deployment packaging script for UxPlay
# Run this in MSYS2 after building to create a standalone package

set -e

PACKAGE_DIR="uxplay-windows-portable"
EXE_PATH="build/uxplay.exe"

if [ ! -f "$EXE_PATH" ]; then
    echo "Error: uxplay.exe not found at $EXE_PATH"
    echo "Please build the project first"
    exit 1
fi

echo "Creating Windows portable package..."

rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"

cp "$EXE_PATH" "$PACKAGE_DIR/"

echo "Copying required DLLs..."

MINGW_BIN="/ucrt64/bin"

cp "$MINGW_BIN/libglib-2.0-0.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libgobject-2.0-0.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libgmodule-2.0-0.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libgio-2.0-0.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libgthread-2.0-0.dll" "$PACKAGE_DIR/" 2>/dev/null || true

cp "$MINGW_BIN/libgstreamer-1.0-0.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libgstbase-1.0-0.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libgstapp-1.0-0.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libgstvideo-1.0-0.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libgstaudio-1.0-0.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libgstsdp-1.0-0.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libgstrtp-1.0-0.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libgstpbutils-1.0-0.dll" "$PACKAGE_DIR/"

cp "$MINGW_BIN/libintl-8.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libwinpthread-1.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libiconv-2.dll" "$PACKAGE_DIR/"
cp "$MINGW_BIN/libpcre2-8-0.dll" "$PACKAGE_DIR/" 2>/dev/null || cp "$MINGW_BIN/libpcre-1.dll" "$PACKAGE_DIR/" 2>/dev/null || true
cp "$MINGW_BIN/libffi-8.dll" "$PACKAGE_DIR/" 2>/dev/null || cp "$MINGW_BIN/libffi-7.dll" "$PACKAGE_DIR/" 2>/dev/null || true

cp "$MINGW_BIN/liborc-0.4-0.dll" "$PACKAGE_DIR/" 2>/dev/null || true
cp "$MINGW_BIN/libz.dll" "$PACKAGE_DIR/" 2>/dev/null || cp "$MINGW_BIN/zlib1.dll" "$PACKAGE_DIR/" 2>/dev/null || true

cp "$MINGW_BIN/libplist-2.0-4.dll" "$PACKAGE_DIR/" 2>/dev/null || cp "$MINGW_BIN/libplist-2.0-3.dll" "$PACKAGE_DIR/" 2>/dev/null || true

cp "$MINGW_BIN/libcrypto-3-x64.dll" "$PACKAGE_DIR/" 2>/dev/null || cp "$MINGW_BIN/libcrypto-1_1-x64.dll" "$PACKAGE_DIR/" 2>/dev/null || true
cp "$MINGW_BIN/libssl-3-x64.dll" "$PACKAGE_DIR/" 2>/dev/null || cp "$MINGW_BIN/libssl-1_1-x64.dll" "$PACKAGE_DIR/" 2>/dev/null || true

echo "Copying GStreamer plugins..."
mkdir -p "$PACKAGE_DIR/lib/gstreamer-1.0"

PLUGINS=(
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

for plugin in "${PLUGINS[@]}"; do
    if [ -f "/ucrt64/lib/gstreamer-1.0/$plugin" ]; then
        cp "/ucrt64/lib/gstreamer-1.0/$plugin" "$PACKAGE_DIR/lib/gstreamer-1.0/"
    fi
done

echo "Copying documentation..."
cp README.md "$PACKAGE_DIR/" 2>/dev/null || true
cp LICENSE "$PACKAGE_DIR/" 2>/dev/null || true

echo ""
echo "Package created successfully in: $PACKAGE_DIR/"
echo ""
echo "Testing for missing dependencies..."
cd "$PACKAGE_DIR"
ldd uxplay.exe | grep "not found" || echo "All dependencies satisfied!"
cd ..

echo ""
echo "To create a zip archive:"
echo "  zip -r uxplay-windows-portable.zip $PACKAGE_DIR"

#!/bin/bash

set -e

function print_usage() {
cat<<EOF
Usage: build.sh [--release] [--clean] [--with-tests]

    --help | -h               Print this help message and exit.
    --release                 Builds the release configuration (default).
    --clean                   Cleans the build artifacts.
    --with-tests              Also build Valkey test server (needed for ./tests/run-valkey-tests.sh).

Example usage:

    # Build the module
    ./build.sh --release

    # Build module and Valkey test server
    ./build.sh --with-tests

    # Clean build artifacts
    ./build.sh --clean
EOF
}

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BUILD_DIR="$SCRIPT_DIR/build"
BUILD_RELEASE=1
CLEAN_BUILD=0
BUILD_TESTS=0

while [[ $# -gt 0 ]]; do
    arg="$1"
    case $arg in
        --release)
            BUILD_RELEASE=1
            shift
            ;;
        --clean)
            CLEAN_BUILD=1
            shift
            ;;
        --with-tests)
            BUILD_TESTS=1
            shift
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            print_usage
            exit 1
            ;;
    esac
done

if [ $CLEAN_BUILD -eq 1 ]; then
    echo "Cleaning build artifacts..."
    rm -rf "$BUILD_DIR"
    echo "Clean completed"
    exit 0
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Initialize / update the Lua 5.5 submodule if needed.
if [ ! -f "$SCRIPT_DIR/deps/lua/lua.h" ]; then
    echo "Initializing Lua 5.5 submodule..."
    cd "$SCRIPT_DIR"
    git submodule update --init --recursive
    cd "$BUILD_DIR"
fi

if [ -z "$SERVER_VERSION" ]; then
    echo "SERVER_VERSION not set, defaulting to 'unstable'"
    export SERVER_VERSION="unstable"
fi

CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Release"

echo "Configuring with: $CMAKE_FLAGS"
cmake .. $CMAKE_FLAGS

echo "Building..."
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

if [ $BUILD_TESTS -eq 1 ]; then
    echo ""
    echo "Building Valkey test server..."
    "$SCRIPT_DIR/setup-tests.sh"
fi

echo ""
echo "Build complete!"
echo ""
echo "Module location: $BUILD_DIR/libvalkeylua55.so"
if [ $BUILD_TESTS -eq 1 ]; then
    echo "Valkey test server: $BUILD_DIR/valkey/src/valkey-server"
    echo ""
    echo "Run tests with:"
    echo "  ./tests/run-valkey-tests.sh"
    echo ""
    echo "Examples:"
    echo "  ./tests/run-valkey-tests.sh --single unit/scripting"
    echo "  ./tests/run-valkey-tests.sh --single unit/functions"
else
    echo ""
    echo "To build test infrastructure:"
    echo "  ./build.sh --with-tests"
    echo "  Or run separately: ./setup-tests.sh"
fi

#!/bin/bash

# ANSI Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Box Drawing Characters
TOP_LEFT="╭"
TOP_RIGHT="╮"
BOTTOM_LEFT="╰"
BOTTOM_RIGHT="╯"
VERTICAL="│"
HORIZONTAL="─"

# Status Symbols
CHECK="✓"
CROSS="✗"
INFO="ℹ"
WARN="⚠"
ARROW="→"

# Helper Functions
print_header() {
    echo -e "${BLUE}${BOLD}${TOP_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL} TestLang++ Dependency Setup ${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${TOP_RIGHT}${RESET}"
    echo -e "${BLUE}${VERTICAL}${RESET} Started at: ${BOLD}$(date '+%H:%M:%S')${RESET}"
    echo -e "${BLUE}${BOTTOM_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${BOTTOM_RIGHT}${RESET}"
    echo
}

print_step() {
    local num="$1"
    local total="$2"
    local desc="$3"
    echo -e "${BLUE}${BOLD}[Step $num/$total]${RESET} ${desc}"
}

print_progress() {
    echo -e "${ARROW} ${DIM}$1${RESET}"
}

print_success() {
    echo -e "${GREEN}${CHECK}${RESET} $1"
}

print_warning() {
    echo -e "${YELLOW}${WARN}${RESET} $1"
}

print_error() {
    echo -e "${RED}${CROSS}${RESET} $1\n${RED}${VERTICAL}${RESET} $2"
    exit 1
}

# Initialize
print_header

# Configuration
LIB_DIR="lib"
JFLEX_VERSION="1.9.1"
CUP_VERSION="11b"
JUNIT_VERSION="1.10.0"

print_progress "Creating library directories..."
mkdir -p "$LIB_DIR/junit"
print_success "Directory structure ready"
echo

# Step 1: Download JFlex
print_step "1" "3" "Installing JFlex Scanner Generator"
if [ ! -f "$LIB_DIR/jflex-full-$JFLEX_VERSION.jar" ]; then
    print_progress "Downloading JFlex version $JFLEX_VERSION..."
    if wget -O "$LIB_DIR/jflex-full-$JFLEX_VERSION.jar" \
        "https://repo1.maven.org/maven2/de/jflex/jflex/$JFLEX_VERSION/jflex-$JFLEX_VERSION.jar" 2>/dev/null || \
       curl -L -o "$LIB_DIR/jflex-full-$JFLEX_VERSION.jar" \
        "https://repo1.maven.org/maven2/de/jflex/jflex/$JFLEX_VERSION/jflex-$JFLEX_VERSION.jar"; then
        print_success "JFlex $JFLEX_VERSION installed successfully"
    else
        print_error "Failed to download JFlex" "Check your internet connection and try again"
    fi
else
    print_success "JFlex $JFLEX_VERSION already installed"
fi
echo

# Step 2: Download CUP
print_step "2" "3" "Installing CUP Parser Generator"
if [ ! -f "$LIB_DIR/java-cup-$CUP_VERSION.jar" ] || [ ! -f "$LIB_DIR/java-cup-$CUP_VERSION-runtime.jar" ]; then
    print_progress "Downloading CUP version $CUP_VERSION..."
    TMP_TAR="/tmp/cup-$CUP_VERSION.tar.gz"
    
    if wget -O "$TMP_TAR" \
        "http://www2.cs.tum.edu/projects/cup/releases/java-cup-bin-$CUP_VERSION-20160615.tar.gz" 2>/dev/null || \
       curl -L -o "$TMP_TAR" \
        "http://www2.cs.tum.edu/projects/cup/releases/java-cup-bin-$CUP_VERSION-20160615.tar.gz"; then
        
        print_progress "Extracting CUP components..."
        if tar -xzf "$TMP_TAR" -C "$LIB_DIR" 2>/dev/null; then
            # Rename files for consistency
            if [ -f "$LIB_DIR/java-cup-11b.jar" ] && [ ! -f "$LIB_DIR/java-cup-$CUP_VERSION.jar" ]; then
                mv "$LIB_DIR/java-cup-11b.jar" "$LIB_DIR/java-cup-$CUP_VERSION.jar"
            fi
            if [ -f "$LIB_DIR/java-cup-11b-runtime.jar" ] && [ ! -f "$LIB_DIR/java-cup-$CUP_VERSION-runtime.jar" ]; then
                mv "$LIB_DIR/java-cup-11b-runtime.jar" "$LIB_DIR/java-cup-$CUP_VERSION-runtime.jar"
            fi
            print_success "CUP $CUP_VERSION installed successfully"
        else
            print_error "Failed to extract CUP" "Archive may be corrupted, try downloading again"
        fi
        rm -f "$TMP_TAR"
    else
        print_error "Failed to download CUP" "Check your internet connection and try again"
    fi
else
    print_success "CUP $CUP_VERSION already installed"
fi
echo

# Step 3: Download JUnit
print_step "3" "3" "Installing JUnit Test Framework"
if [ ! -f "$LIB_DIR/junit/junit-platform-console-standalone-$JUNIT_VERSION.jar" ]; then
    print_progress "Downloading JUnit version $JUNIT_VERSION..."
    if wget -O "$LIB_DIR/junit/junit-platform-console-standalone-$JUNIT_VERSION.jar" \
        "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/$JUNIT_VERSION/junit-platform-console-standalone-$JUNIT_VERSION.jar" 2>/dev/null || \
       curl -L -o "$LIB_DIR/junit/junit-platform-console-standalone-$JUNIT_VERSION.jar" \
        "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/$JUNIT_VERSION/junit-platform-console-standalone-$JUNIT_VERSION.jar"; then
        print_success "JUnit $JUNIT_VERSION installed successfully"
    else
        print_error "Failed to download JUnit" "Check your internet connection and try again"
    fi
else
    print_success "JUnit $JUNIT_VERSION already installed"
fi
echo

# Print summary
echo -e "${GREEN}${BOLD}${TOP_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL} Installation Complete ${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${TOP_RIGHT}${RESET}"
echo -e "${GREEN}${VERTICAL}${RESET} ${CHECK} All dependencies installed successfully"
echo -e "${GREEN}${VERTICAL}${RESET} ${INFO} Installation directory: ${BOLD}$LIB_DIR/${RESET}"

# List installed files
print_progress "Verifying installed components..."
echo -e "${GREEN}${VERTICAL}${RESET} ${BOLD}Installed Components:${RESET}"
ls -lh "$LIB_DIR"/*.jar "$LIB_DIR/junit"/*.jar 2>/dev/null | while read -r line; do
    name=$(echo "$line" | awk '{print $9}')
    size=$(echo "$line" | awk '{print $5}')
    echo -e "${GREEN}${VERTICAL}${RESET}   ${ARROW} ${DIM}$(basename "$name")${RESET} (${BLUE}$size${RESET})"
done

echo -e "${GREEN}${BOTTOM_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${BOTTOM_RIGHT}${RESET}"
echo

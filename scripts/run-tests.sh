#!/bin/bash
# Compile and run the generated JUnit tests

# ANSI Colors and Styles
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
RESET='\033[0m'

# Box Drawing Characters
TOP_LEFT="╭"
TOP_RIGHT="╮"
BOTTOM_LEFT="╰"
BOTTOM_RIGHT="╯"
VERTICAL="│"
HORIZONTAL="─"
BRANCH="├"

# Symbols
CHECK="✓"
CROSS="✗"
INFO="ℹ"
WARN="⚠"

print_header() {
    echo
    echo -e "${BLUE}${BOLD}${TOP_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL} TestLang++ Test Runner ${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${TOP_RIGHT}${RESET}"
    echo -e "${BLUE}${VERTICAL}${RESET} $(date '+%Y-%m-%d %H:%M:%S')            ${BLUE}${VERTICAL}${RESET}"
    echo -e "${BLUE}${BOTTOM_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${BOTTOM_RIGHT}${RESET}"
    echo
}

print_section() {
    echo -e "${CYAN}${BRANCH}${HORIZONTAL}${RESET} ${BOLD}$1${RESET}"
    echo -e "${CYAN}${VERTICAL}${RESET}"
}

print_error() {
    echo -e "${RED}${BOLD}${TOP_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL} Error ${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${TOP_RIGHT}${RESET}"
    echo -e "${RED}${VERTICAL}${RESET} ${WARN} $1"
    echo -e "${RED}${VERTICAL}${RESET}"
    echo -e "${RED}${BRANCH}${HORIZONTAL}${RESET} Usage: $0 <GeneratedTests.java>"
    echo -e "${RED}${VERTICAL}${RESET} Example: $0 output/GeneratedTests.java"
    echo -e "${RED}${BOTTOM_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${BOTTOM_RIGHT}${RESET}"
    echo
    exit 1
}

# Print header
print_header

set -e

if [ $# -lt 1 ]; then
    print_error "No test file provided"
fi

GENERATED_FILE="$1"

if [ ! -f "$GENERATED_FILE" ]; then
    print_error "Test file not found: '$GENERATED_FILE'"
fi

# Setup directories
print_section "Setting up test environment"
JUNIT_DIR="lib/junit"
mkdir -p "$JUNIT_DIR"

if [ ! -f "$JUNIT_DIR/junit-platform-console-standalone-1.10.0.jar" ]; then
    echo -e "${CYAN}${VERTICAL}${RESET} ${INFO} Downloading JUnit 5..."
    wget -q --show-progress -O "$JUNIT_DIR/junit-platform-console-standalone-1.10.0.jar" \
        "https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/1.10.0/junit-platform-console-standalone-1.10.0.jar"
    echo -e "${CYAN}${VERTICAL}${RESET} ${CHECK} JUnit 5 downloaded successfully"
else
    echo -e "${CYAN}${VERTICAL}${RESET} ${CHECK} JUnit 5 is ready"
fi

JUNIT_JAR="$JUNIT_DIR/junit-platform-console-standalone-1.10.0.jar"
TEST_BUILD="build/tests"
mkdir -p "$TEST_BUILD"

# Compile tests
echo
print_section "Compiling Test Suite"
echo -e "${CYAN}${VERTICAL}${RESET} ${INFO} Compiling: ${DIM}$(basename "$GENERATED_FILE")${RESET}"
if javac -d "$TEST_BUILD" -cp "$JUNIT_JAR" "$GENERATED_FILE" 2>/dev/null; then
    echo -e "${CYAN}${VERTICAL}${RESET} ${CHECK} Compilation successful"
else
    print_error "Compilation failed. Check your test file for errors."
fi

# Run tests
echo
print_section "Executing Test Suite"
echo -e "${CYAN}${VERTICAL}${RESET} ${INFO} Running tests..."
echo

# Format and colorize the test output while preserving all information
java -jar "$JUNIT_JAR" --class-path "$TEST_BUILD" --scan-class-path | while IFS= read -r line; do
    if [[ $line == "Test run finished"* ]]; then
        # Test duration header
        echo -e "${BLUE}${BOLD}${TOP_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL} Test Results ${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${TOP_RIGHT}${RESET}"
        echo -e "${BLUE}${VERTICAL}${RESET} ${line}"
    elif [[ $line == *"containers found"* ]]; then
        echo -e "${BLUE}${VERTICAL}${RESET} ${DIM}${line}${RESET}"
    elif [[ $line == *"containers skipped"* ]]; then
        echo -e "${BLUE}${VERTICAL}${RESET} ${DIM}${line}${RESET}"
    elif [[ $line == *"containers started"* ]]; then
        echo -e "${BLUE}${VERTICAL}${RESET} ${DIM}${line}${RESET}"
    elif [[ $line == *"containers aborted"* ]]; then
        echo -e "${BLUE}${VERTICAL}${RESET} ${DIM}${line}${RESET}"
    elif [[ $line == *"containers successful"* ]]; then
        echo -e "${BLUE}${VERTICAL}${RESET} ${GREEN}${line}${RESET}"
    elif [[ $line == *"containers failed"* ]]; then
        echo -e "${BLUE}${VERTICAL}${RESET} ${RED}${line}${RESET}"
    elif [[ $line == *"tests found"* ]]; then
        echo -e "${BLUE}${VERTICAL}${RESET} ${BOLD}${line}${RESET}"
    elif [[ $line == *"tests skipped"* ]]; then
        echo -e "${BLUE}${VERTICAL}${RESET} ${DIM}${line}${RESET}"
    elif [[ $line == *"tests started"* ]]; then
        echo -e "${BLUE}${VERTICAL}${RESET} ${line}"
    elif [[ $line == *"tests aborted"* ]]; then
        echo -e "${BLUE}${VERTICAL}${RESET} ${YELLOW}${line}${RESET}"
    elif [[ $line == *"tests successful"* ]]; then
        echo -e "${BLUE}${VERTICAL}${RESET} ${GREEN}${line}${RESET}"
    elif [[ $line == *"tests failed"* ]]; then
        echo -e "${BLUE}${VERTICAL}${RESET} ${RED}${line}${RESET}"
        FAILED_COUNT=$(echo "$line" | grep -o '[0-9]\+')
    elif [[ $line == *"[OK]"* ]]; then
        echo -e "${GREEN}${CHECK} ${line/[OK]/${CHECK}}${RESET}"
    elif [[ $line == *"[X]"* ]]; then
        echo -e "${RED}${CROSS} ${line/[X]/${CROSS}}${RESET}"
    else
        echo "$line"
    fi
done

# Print final status
echo -e "${BLUE}${VERTICAL}${RESET}"
if [ "${FAILED_COUNT:-0}" -eq 0 ]; then
    echo -e "${BLUE}${VERTICAL}${RESET} ${GREEN}${CHECK} All tests completed successfully!${RESET}"
else
    echo -e "${BLUE}${VERTICAL}${RESET} ${RED}${WARN} Some tests failed. Check the details above.${RESET}"
fi
echo -e "${BLUE}${BOTTOM_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${BOTTOM_RIGHT}${RESET}"
echo

#!/bin/bash
# Compile the TestLang++ compiler: Scanner + Parser + Code Generator

# ANSI Colors and Styles
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
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
GEAR="⚙"
BUILD="🔨"

print_header() {
    echo
    echo -e "${BLUE}${BOLD}${TOP_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL} TestLang++ Compiler Build ${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${TOP_RIGHT}${RESET}"
    echo -e "${BLUE}${VERTICAL}${RESET} ${BUILD} Build started at $(date '+%H:%M:%S')       ${BLUE}${VERTICAL}${RESET}"
    echo -e "${BLUE}${BOTTOM_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${BOTTOM_RIGHT}${RESET}"
    echo
}

print_step() {
    local step=$1
    local total=$2
    local desc=$3
    echo -e "${CYAN}${BRANCH}${HORIZONTAL}${RESET} ${BOLD}[$step/$total]${RESET} $desc"
}

print_progress() {
    echo -e "${CYAN}${VERTICAL}${RESET} ${DIM}$1${RESET}"
}

print_success() {
    echo -e "${CYAN}${VERTICAL}${RESET} ${GREEN}${CHECK} $1${RESET}"
}

print_error() {
    echo -e "\n${RED}${BOLD}${TOP_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL} Error ${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${TOP_RIGHT}${RESET}"
    echo -e "${RED}${VERTICAL}${RESET} ${WARN} $1"
    echo -e "${RED}${VERTICAL}${RESET}"
    echo -e "${RED}${BRANCH}${HORIZONTAL}${RESET} ${YELLOW}Solution${RESET}"
    echo -e "${RED}${VERTICAL}${RESET} $2"
    echo -e "${RED}${BOTTOM_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${BOTTOM_RIGHT}${RESET}"
    echo
    exit 1
}

set -e

# Print header
print_header

# Initialize build environment
print_step "0" "5" "Initializing build environment"

# Paths
LIB_DIR="lib"
BUILD_DIR="build"
JFLEX_JAR="$LIB_DIR/jflex-full-1.9.1.jar"
CUP_JAR="$LIB_DIR/java-cup-11b.jar"
CUP_RUNTIME="$LIB_DIR/java-cup-11b-runtime.jar"

# Classpath separator: ':' on Unix-like, ';' on Windows (msys/cygwin)
CPSEP=":"
case "$(uname -s)" in
    *MINGW*|*MSYS*|*CYGWIN*|*WindowsNT*)
        CPSEP=";"
        ;;
esac

# Check dependencies
print_progress "Checking dependencies..."
if [ ! -f "$JFLEX_JAR" ] || [ ! -f "$CUP_JAR" ]; then
    print_error "Missing build dependencies" "Run the following command to install dependencies:\n${RED}${VERTICAL}${RESET} ./scripts/setup-deps.sh"
fi
print_success "All dependencies found"

# Create build directory
print_progress "Creating build directory..."
mkdir -p "$BUILD_DIR"
print_success "Build directory ready: ${DIM}$BUILD_DIR${RESET}"
echo

# Step 1: Generate Scanner
print_step "1" "5" "Generating Lexical Scanner"
print_progress "Running JFlex generator..."
if java -cp "$JFLEX_JAR${CPSEP}$CUP_RUNTIME" jflex.Main -d scanner scanner/lexer.flex > /dev/null 2>&1; then
    print_success "Scanner generated successfully"
else
    print_error "Scanner generation failed" "Check lexer.flex for syntax errors"
fi
echo

# Step 2: Generate Parser
print_step "2" "5" "Generating Syntactic Parser"
print_progress "Running CUP parser generator..."
if java -cp "$CUP_JAR${CPSEP}$CUP_RUNTIME" java_cup.Main -destdir parser -parser Parser -symbols sym parser/parser.cup > /dev/null 2>&1; then
    print_success "Parser generated successfully"
else
    print_error "Parser generation failed" "Check parser.cup for syntax errors"
fi
echo

# Step 3: Compile AST
print_step "3" "5" "Compiling Abstract Syntax Tree"
print_progress "Compiling AST classes..."
if javac -d "$BUILD_DIR" -cp "$CUP_RUNTIME" ast/*.java > /dev/null 2>&1; then
    print_success "AST classes compiled successfully"
else
    print_error "AST compilation failed" "Check ast/*.java for compilation errors"
fi
echo

# Step 4: Compile Scanner & Parser
print_step "4" "5" "Compiling Scanner and Parser"
print_progress "Compiling generated code..."
if javac -d "$BUILD_DIR" -cp "$CUP_RUNTIME${CPSEP}$BUILD_DIR" scanner/*.java parser/*.java > /dev/null 2>&1; then
    print_success "Scanner and Parser compiled successfully"
else
    print_error "Scanner/Parser compilation failed" "Check generated scanner/*.java and parser/*.java"
fi
echo

# Step 5: Compile Code Generator
print_step "5" "5" "Compiling Code Generator"
print_progress "Compiling final components..."
if javac -d "$BUILD_DIR" -cp "$CUP_RUNTIME${CPSEP}$BUILD_DIR" codegen/*.java compiler/*.java > /dev/null 2>&1; then
    print_success "Code Generator compiled successfully"
else
    print_error "Code Generator compilation failed" "Check codegen/*.java and compiler/*.java"
fi
echo

# Print success message
echo -e "${GREEN}${BOLD}${TOP_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL} Build Successful ${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${TOP_RIGHT}${RESET}"
echo -e "${GREEN}${VERTICAL}${RESET} ${CHECK} All components compiled successfully"
echo -e "${GREEN}${VERTICAL}${RESET} ${INFO} Build directory: ${BOLD}$BUILD_DIR/${RESET}"
echo -e "${GREEN}${VERTICAL}${RESET} ${INFO} Build completed in ${BOLD}$(date '+%H:%M:%S')${RESET}"
echo -e "${GREEN}${BOTTOM_LEFT}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${HORIZONTAL}${BOTTOM_RIGHT}${RESET}"
echo

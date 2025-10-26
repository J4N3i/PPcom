
<div align="center">
  <h1 style="font-family: 'Fira Mono', 'Consolas', monospace; font-size: 2.5em; letter-spacing: 0.1em;">TESTIFY</h1>
  <h3 style="font-family: 'Fira Mono', 'Consolas', monospace; font-size: 1.2em; color: #555;">A DSL for Effortless HTTP API Testing</h3>
  <p><em>"Simplify your API testing with <b>TESTIFY</b> — where automation meets elegance."</em></p>
</div>

## TestLang++ (TESTIFY) - Backend API Testing DSL

A Domain-Specific Language (DSL) for HTTP API testing that compiles `.test` files into executable JUnit 5 tests using Java's HttpClient.

## 🎯 Overview

TestLang++ allows you to write declarative HTTP API tests that are compiled into Java JUnit 5 test classes. Tests are executed against a local Spring Boot backend.

## 💻 System Requirements

**Developed and tested on MacBook**

- **Operating System**: macOS (primary) or Linux
  - All scripts are written in **Bash** and thoroughly tested on macOS
  - Developed and optimized for macOS environment
  - Linux users should have no issues running the project
  - Windows users may need Git Bash
- **Java**: JDK 11 or higher
- **Maven**: 3.6+ (for backend compilation)
- **wget** or **curl**: For downloading dependencies

> **Note**: This project was developed on MacBook Pro using macOS. All build scripts (`.sh` files) are Bash scripts that work seamlessly on macOS and are compatible with Linux environments.

## 📁 Project Structure

```
.
├── ast/                    # Abstract Syntax Tree node classes
├── backend/                # Spring Boot backend (test target)
├── codegen/                # Code generation (AST → JUnit)
├── compiler/               # Main compiler entry point
├── input/                  # Sample .test files
├── lib/                    # External dependencies (JFlex, CUP, JUnit)
├── output/                 # Generated Java test files
├── parser/                 # CUP parser specification
├── scanner/                # JFlex lexer specification
└── scripts/                # Build and run scripts
```

## 🚀 Quick Start

### 1. Setup Dependencies

Download JFlex and CUP (Java parser generators):

```bash
./scripts/setup-deps.sh
```

### 2. Compile the Compiler

Build the scanner, parser, and code generator:

```bash
./scripts/compile.sh
```

### 3. Write Your Tests

Create a `.test` file (see examples below):

```testlang
config {
  base_url = "http://localhost:8080";
  header "Content-Type" = "application/json";
}

let user = "admin";

test Login {
  POST "/api/login" {
    body = "{ \"username\": \"$user\", \"password\": \"1234\" }";
  }
  expect status = 200;
  expect body contains "\"token\":";
}
```

### 4. Generate Tests

Compile your `.test` file to Java:

```bash
./scripts/run-compiler.sh input/example.test output/GeneratedTests.java
```

### 5. Run Backend

Start the Spring Boot backend (in a separate terminal):

```bash
./scripts/start-backend.sh
```

The server will start at `http://localhost:8080`

### 6. Run Tests

Execute the generated JUnit tests:

```bash
./scripts/run-tests.sh output/GeneratedTests.java
```

## 📝 Language Syntax

### Config Block (Optional)

```testlang
config {
  base_url = "http://localhost:8080";
  header "Content-Type" = "application/json";
  header "X-App" = "TestLangDemo";
}
```

### Variables

```testlang
let user = "admin";
let id = 42;
```

Variables can be referenced in strings and paths using `$variableName`.

### Test Blocks

Each test becomes a `@Test` method in JUnit:

```testlang
test TestName {
  // HTTP requests
  // Assertions
}
```

### HTTP Requests

**GET/DELETE** (no body):
```testlang
GET "/api/users/42";
DELETE "/api/users/999";
```

**POST/PUT** (with optional body and headers):
```testlang
POST "/api/login" {
  header "Authorization" = "Bearer token";
  body = "{ \"username\": \"$user\" }";
}

PUT "/api/users/$id" {
  body = "{ \"role\": \"ADMIN\" }";
}
```

**Multiline Body Support** (using triple quotes):
```testlang
POST "/api/login" {
  body = """
{
  "username": "$user",
  "password": "1234"
}
""";
}

PUT "/api/users/$id" {
  body = """
{
  "role": "ADMIN",
  "email": "admin@example.com"
}
""";
}
```

> **Note**: You can now use triple-quoted strings (`"""..."""`) for multiline request bodies. This makes it easier to write complex JSON payloads with proper formatting and readability.

### Assertions

```testlang
expect status = 200;
expect header "Content-Type" = "application/json";
expect header "Content-Type" contains "json";
expect body contains "\"token\":";
```

**Requirements:**
- Each test must have ≥1 request
- Each test must have ≥2 assertions

## 🧪 Example Test Files

### Simple Login Test

**Single-line body:**
```testlang
config {
  base_url = "http://localhost:8080";
}

test Login {
  POST "/api/login" {
    header "Content-Type" = "application/json";
    body = "{ \"username\": \"admin\", \"password\": \"1234\" }";
  }
  expect status = 200;
  expect body contains "\"token\":";
}
```

**Multiline body:**
```testlang
config {
  base_url = "http://localhost:8080";
}

test LoginMultiline {
  POST "/api/login" {
    header "Content-Type" = "application/json";
    body = """
{
  "username": "admin",
  "password": "1234"
}
""";
  }
  expect status = 200;
  expect body contains "\"token\":";
}
```

### CRUD Operations

**Single-line body:**
```testlang
config {
  base_url = "http://localhost:8080";
  header "Content-Type" = "application/json";
}

let userId = 42;

test GetUser {
  GET "/api/users/$userId";
  expect status = 200;
  expect body contains "\"id\": 42";
}

test UpdateUser {
  PUT "/api/users/$userId" {
    body = "{ \"role\": \"ADMIN\", \"email\": \"admin@example.com\" }";
  }
  expect status = 200;
  expect header "Content-Type" contains "json";
  expect body contains "\"updated\": true";
}
```

**Multiline body:**
```testlang
config {
  base_url = "http://localhost:8080";
  header "Content-Type" = "application/json";
}

let userId = 42;

test UpdateUserMultiline {
  PUT "/api/users/$userId" {
    body = """
{
  "role": "ADMIN",
  "email": "admin@example.com"
}
""";
  }
  expect status = 200;
  expect body contains "\"updated\": true";
}
```

## 🔧 Backend API Endpoints

The provided Spring Boot backend supports:

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/login` | Login with username/password |
| GET | `/api/users/{id}` | Get user by ID |
| PUT | `/api/users/{id}` | Update user |
| DELETE | `/api/users/{id}` | Delete user |

### Manual Testing (cURL)

```bash
# Login
curl -X POST http://localhost:8080/api/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"1234"}'

# Get user
curl http://localhost:8080/api/users/42

# Update user
curl -X PUT http://localhost:8080/api/users/42 \
  -H 'Content-Type: application/json' \
  -d '{"role":"ADMIN"}'
```

## 🛠️ Development

### Modify Scanner (Lexer)

Edit `scanner/lexer.flex` and recompile:

```bash
./scripts/compile.sh
```

### Modify Parser

Edit `parser/parser.cup` and recompile:

```bash
./scripts/compile.sh
```

### Modify Code Generation

Edit `codegen/CodeGenerator.java` and recompile:

```bash
./scripts/compile.sh
```

## 📊 Generated Code Structure

The compiler generates JUnit 5 test classes like:

```java
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;
import java.net.http.*;

public class GeneratedTests {
  static String BASE = "http://localhost:8080";
  static HttpClient client;

  @BeforeAll
  static void setup() {
    client = HttpClient.newBuilder().build();
  }

  @Test
  void test_Login() throws Exception {
    HttpRequest req = HttpRequest.newBuilder(URI.create(BASE + "/api/login"))
      .POST(HttpRequest.BodyPublishers.ofString("{\n  \"username\": \"admin\",\n  \"password\": \"1234\"\n}", StandardCharsets.UTF_8))
      .build();
    HttpResponse<String> resp = client.send(req, HttpResponse.BodyHandlers.ofString());
    
    assertEquals(200, resp.statusCode());
    assertTrue(resp.body().contains("token"));
  }
}
```

> **Note**: When using multiline strings in `.test` files, the generated Java code preserves the formatting and line breaks in the request body.

## ⚠️ Limitations (By Design)

- No JSON parsing/JSONPath
- No loops, conditionals, or macros
- No response capture/assignment
- One file → one test class

## ✨ Features

- ✅ Single-line strings with escape sequences
- ✅ **Multiline strings using triple quotes (`"""..."""`)**
- ✅ Variable substitution in strings and paths
- ✅ HTTP methods: GET, POST, PUT, DELETE
- ✅ Custom headers per request
- ✅ Request body support (single-line and multiline)
- ✅ Status code assertions
- ✅ Header assertions (exact match and contains)
- ✅ Body content assertions
- ✅ Compiles to executable JUnit 5 tests

## 📚 Requirements

- **Java**: 11 or higher (tested with Java 21)
- **JFlex**: 1.9.1 (auto-downloaded)
- **CUP**: 11b (auto-downloaded)
- **JUnit**: 5.10.0 (auto-downloaded)
- **Maven**: For building backend (optional)

## 🐛 Troubleshooting

### "Dependencies not found"
Run `./scripts/setup-deps.sh` first

### "Build directory not found"
Run `./scripts/compile.sh` to compile the compiler

### Backend not starting
Check if port 8080 is available, or ensure Maven is installed to build the backend

### Compilation errors
Ensure Java 11+ is installed: `java -version`

## 📖 Grammar Summary

```
program       → config? variables* tests+
config        → 'config' '{' config_items '}'
config_items  → base_url | header_decl
variables     → 'let' IDENT '=' value ';'
tests         → 'test' IDENT '{' statements+ '}'
statements    → request | assertion
request       → method path ['{' request_items '}'] ';'
assertion     → 'expect' assertion_type ';'
```

## 📄 License

Educational project for PP Module @sliit uni CS.

## 👤 Author

**J4N3i**

Assignment: TestLang++ DSL Compiler  
Course: SE2062 - Programming Paradigms

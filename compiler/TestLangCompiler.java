package compiler;

import scanner.Lexer;
import parser.Parser;
import ast.ProgramNode;
import codegen.CodeGenerator;
import java_cup.runtime.Symbol;

import java.io.FileReader;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Main compiler entry point
 * Usage: java compiler.TestLangCompiler input.test output.java
 */
public class TestLangCompiler {
    // ANSI Colors and Styles
    private static final String RED = "\u001B[31m";
    private static final String GREEN = "\u001B[32m";
    private static final String YELLOW = "\u001B[33m";
    private static final String BLUE = "\u001B[34m";
    private static final String MAGENTA = "\u001B[35m";
    private static final String CYAN = "\u001B[36m";
    private static final String BOLD = "\u001B[1m";
    private static final String DIM = "\u001B[2m";
    private static final String ITALIC = "\u001B[3m";
    private static final String RESET = "\u001B[0m";

    // Box Drawing Characters
    private static final String TOP_LEFT = "╭";
    private static final String TOP_RIGHT = "╮";
    private static final String BOTTOM_LEFT = "╰";
    private static final String BOTTOM_RIGHT = "╯";
    private static final String VERTICAL = "│";
    private static final String HORIZONTAL = "─";
    private static final String BRANCH = "├";

    // Symbols
    private static final String SUCCESS = "✓";
    private static final String ERROR = "✗";
    private static final String INFO = "ℹ";
    private static final String WARNING = "⚠";
    private static final String DEBUG = "🔍";

    private static void printCompilerHeader() {
        System.out.println();
        System.out.println(BLUE + BOLD + TOP_LEFT + HORIZONTAL.repeat(3) + " TestLang++ Compiler "
                + HORIZONTAL.repeat(3) + TOP_RIGHT + RESET);
        System.out.println(BLUE + VERTICAL + RESET + " Version: 1.0.0" + " ".repeat(17) + BLUE + VERTICAL + RESET);
        System.out.println(BLUE + BOTTOM_LEFT + HORIZONTAL.repeat(30) + BOTTOM_RIGHT + RESET);
        System.out.println();
    }

    private static void printStageHeader(String stage, int current, int total) {
        System.out.println(CYAN + BRANCH + HORIZONTAL + RESET + " " + BOLD +
                String.format("[%d/%d] %s", current, total, stage) + RESET);
    }

    private static void printSuccess(String message) {
        System.out.println(GREEN + SUCCESS + " " + BOLD + message + RESET);
    }

    private static void printError(String title, String details, String... hints) {
        StringBuilder error = new StringBuilder();
        error.append("\n").append(RED).append(BOLD).append(TOP_LEFT).append(HORIZONTAL.repeat(3))
                .append(" TestLang++ Error ").append(HORIZONTAL.repeat(3)).append(TOP_RIGHT)
                .append(RESET).append("\n");

        // Error title
        error.append(RED).append(VERTICAL).append(RESET).append(" ")
                .append(BOLD).append(ERROR).append(" ").append(title).append(RESET).append("\n");

        // Timestamp
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        error.append(RED).append(VERTICAL).append(RESET).append(" ")
                .append(DIM).append(timestamp).append(RESET).append("\n");

        // Details
        error.append(RED).append(VERTICAL).append(RESET).append("\n");
        error.append(RED).append(BRANCH).append(HORIZONTAL).append(RESET).append(" ")
                .append(YELLOW).append("Details").append(RESET).append("\n");
        error.append(RED).append(VERTICAL).append(RESET).append(" ").append(details).append("\n");

        // Hints
        if (hints.length > 0) {
            error.append(RED).append(VERTICAL).append(RESET).append("\n");
            error.append(RED).append(BRANCH).append(HORIZONTAL).append(RESET).append(" ")
                    .append(BLUE).append("Suggestions").append(RESET).append("\n");
            for (String hint : hints) {
                error.append(RED).append(VERTICAL).append(RESET).append(" • ").append(hint).append("\n");
            }
        }

        // Footer
        error.append(RED).append(VERTICAL).append(RESET).append("\n");
        error.append(RED).append(BOTTOM_LEFT).append(HORIZONTAL).append(RESET).append(" ")
                .append(INFO).append(" ").append(ITALIC)
                .append("Need help? Check the TestLang++ documentation.")
                .append(RESET).append("\n");

        System.err.println(error.toString());
    }

    public static void main(String[] args) {
        printCompilerHeader();

        if (args.length != 2) {
            printError(
                    "Invalid Arguments",
                    "Incorrect number of arguments provided.",
                    "Usage: java compiler.TestLangCompiler <input.test> <output.java>",
                    "Example: java compiler.TestLangCompiler mytest.test MyTest.java");
            System.exit(1);
        }

        String inputFile = args[0];
        String outputFile = args[1];

        try {
            compile(inputFile, outputFile);

            // Print success message with file details
            StringBuilder success = new StringBuilder();
            success.append("\n").append(GREEN).append(TOP_LEFT).append(HORIZONTAL.repeat(3))
                    .append(" Compilation Successful ").append(HORIZONTAL.repeat(3)).append(TOP_RIGHT)
                    .append(RESET).append("\n");

            success.append(GREEN).append(VERTICAL).append(RESET).append(" ")
                    .append(SUCCESS).append(" Input File:  ").append(BOLD).append(inputFile)
                    .append(RESET).append("\n");

            success.append(GREEN).append(VERTICAL).append(RESET).append(" ")
                    .append(SUCCESS).append(" Output File: ").append(BOLD).append(outputFile)
                    .append(RESET).append("\n");

            success.append(GREEN).append(BOTTOM_LEFT).append(HORIZONTAL.repeat(30))
                    .append(BOTTOM_RIGHT).append(RESET).append("\n");

            System.out.println(success.toString());

        } catch (Exception e) {
            printError(
                    "Compilation Failed",
                    e.getMessage(),
                    "Check your test file syntax",
                    "Ensure all required sections are present",
                    "Verify that file paths are correct");
            System.exit(1);
        }
    }

    public static void compile(String inputFile, String outputFile) throws Exception {
        try {
            // Step 1: Lexical Analysis (Scanning)
            printStageHeader("Lexical Analysis", 1, 3);
            Lexer lexer = new Lexer(new FileReader(inputFile));

            // Step 2: Syntax Analysis (Parsing)
            printStageHeader("Syntax Analysis", 2, 3);
            Parser parser = new Parser(lexer);
            Symbol parseResult = parser.parse();
            ProgramNode program = (ProgramNode) parseResult.value;

            // Validate AST
            validateProgram(program);

            // Step 3: Code Generation
            printStageHeader("Code Generation", 3, 3);
            CodeGenerator generator = new CodeGenerator(program);
            generator.generate(outputFile);

        } catch (IOException e) {
            throw new Exception("Could not read input file: " + e.getMessage());
        } catch (Exception e) {
            if (e.getMessage() != null && !e.getMessage().isEmpty()) {
                throw e;
            } else {
                throw new Exception("An unexpected error occurred during compilation");
            }
        }
    }

    /**
     * Validate the parsed program
     */
    private static void validateProgram(ProgramNode program) {
        // Check that we have at least one test
        if (program.getTests().isEmpty()) {
            throw new RuntimeException(
                    "No test blocks found in the program.\n" +
                            RED + VERTICAL + RESET
                            + " A valid TestLang++ program must contain at least one test block.\n" +
                            RED + VERTICAL + RESET + " Example:\n" +
                            RED + VERTICAL + RESET + " test MyFirstTest {\n" +
                            RED + VERTICAL + RESET + "     GET \"/api/users\";\n" +
                            RED + VERTICAL + RESET + "     expect status = 200;\n" +
                            RED + VERTICAL + RESET + "     expect body contains \"success\";\n" +
                            RED + VERTICAL + RESET + " }");
        }

        // Validate each test
        for (var test : program.getTests()) {
            if (test.getRequests().isEmpty()) {
                throw new RuntimeException(
                        "Empty test block found: '" + test.getName() + "'\n" +
                                RED + VERTICAL + RESET + " Each test block must contain at least one HTTP request.\n" +
                                RED + VERTICAL + RESET + " Valid requests are: GET, POST, PUT, DELETE\n" +
                                RED + VERTICAL + RESET + " Example:\n" +
                                RED + VERTICAL + RESET + " test " + test.getName() + " {\n" +
                                RED + VERTICAL + RESET + "     GET \"/api/users\";\n" +
                                RED + VERTICAL + RESET + "     expect status = 200;\n" +
                                RED + VERTICAL + RESET + " }");
            }
            if (test.getAssertions().size() < 2) {
                throw new RuntimeException(
                        "Insufficient assertions in test: '" + test.getName() + "'\n" +
                                RED + VERTICAL + RESET
                                + " Each test must have at least 2 assertions to be meaningful.\n" +
                                RED + VERTICAL + RESET + " Current assertions: " + test.getAssertions().size() + "\n" +
                                RED + VERTICAL + RESET + " Available assertions:\n" +
                                RED + VERTICAL + RESET + " • expect status = <code>;\n" +
                                RED + VERTICAL + RESET + " • expect status in <min>..<max>;\n" +
                                RED + VERTICAL + RESET + " • expect body contains \"text\";\n" +
                                RED + VERTICAL + RESET + " • expect header \"Name\" = \"Value\";");
            }
        }
    }
}
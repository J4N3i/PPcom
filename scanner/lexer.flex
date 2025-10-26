package scanner;

import java_cup.runtime.*;
import parser.sym;

%%

%class Lexer
%public
%unicode
%cup
%line
%column

%{
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

    private Symbol symbol(int type) {
        return new Symbol(type, yyline + 1, yycolumn + 1);
    }

    private Symbol symbol(int type, Object value) {
        return new Symbol(type, yyline + 1, yycolumn + 1, value);
    }

    private void printLexicalError(String errorType, String details, String... examples) {
        StringBuilder error = new StringBuilder();
        error.append("\n").append(RED).append(BOLD).append("╭── TestLang++ Lexical Error ").append(RESET)
             .append(DIM).append("at line ").append(yyline + 1).append(", column ").append(yycolumn + 1).append(RESET).append("\n");
        error.append(RED).append("│").append(RESET).append("\n");
        
        // Error type and details
        error.append(RED).append("│").append(RESET).append("  ").append(BOLD).append("⚠️  ").append(errorType).append(RESET).append("\n");
        error.append(RED).append("│").append(RESET).append("\n");
        error.append(RED).append("├─").append(RESET).append(YELLOW).append(" PROBLEM").append(RESET).append("\n");
        error.append(RED).append("│").append(RESET).append("  ").append(details).append("\n");
        error.append(RED).append("│").append(RESET).append("\n");

        if (examples.length > 0) {
            error.append(RED).append("├─").append(RESET).append(CYAN).append(" EXAMPLES").append(RESET).append("\n");
            for (String example : examples) {
                if (example.startsWith("INVALID:")) {
                    error.append(RED).append("│").append(RESET).append("  ").append(DIM).append("✗ Invalid: ").append(RESET)
                         .append(RED).append(example.substring(8).trim()).append(RESET).append("\n");
                } else if (example.startsWith("VALID:")) {
                    error.append(RED).append("│").append(RESET).append("  ").append(DIM).append("✓ Valid:   ").append(RESET)
                         .append(GREEN).append(example.substring(6).trim()).append(RESET).append("\n");
                }
            }
            error.append(RED).append("│").append(RESET).append("\n");
        }

        error.append(RED).append("╰─").append(RESET).append(" 💡 ")
             .append(ITALIC).append("Refer to TestLang++ documentation for complete syntax guide.")
             .append(RESET).append("\n");

        System.err.println(error.toString());
        System.exit(1);
    }
%}

/* Regular Expressions */
LineTerminator = \r|\n|\r\n
WhiteSpace     = {LineTerminator} | [ \t\f]
Comment        = "//" [^\r\n]*

Identifier     = [A-Za-z_][A-Za-z0-9_]*
InvalidIdentifier = [0-9]+[A-Za-z_][A-Za-z0-9_]*
Number         = 0 | [1-9][0-9]*
String         = \"([^\\\"]|\\.)*\"
MultilineString = \"\"\"([^\"]|\"[^\"]|\"\"[^\"])*\"\"\"

%%

/* Keywords */
<YYINITIAL> {
    "config"        { return symbol(sym.CONFIG); }
    "base_url"      { return symbol(sym.BASE_URL); }
    "header"        { return symbol(sym.HEADER); }
    "let"           { return symbol(sym.LET); }
    "test"          { return symbol(sym.TEST); }
    "GET"           { return symbol(sym.GET); }
    "POST"          { return symbol(sym.POST); }
    "PUT"           { return symbol(sym.PUT); }
    "DELETE"        { return symbol(sym.DELETE); }
    "expect"        { return symbol(sym.EXPECT); }
    "status"        { return symbol(sym.STATUS); }
    "body"          { return symbol(sym.BODY); }
    "contains"      { return symbol(sym.CONTAINS); }
    "in"            { return symbol(sym.IN); }

    /* Operators and Delimiters */
    "="             { return symbol(sym.EQUALS); }
    ";"             { return symbol(sym.SEMICOLON); }
    "{"             { return symbol(sym.LBRACE); }
    "}"             { return symbol(sym.RBRACE); }
    ".."            { return symbol(sym.DOTDOT); }

    /* Literals */
    {InvalidIdentifier} {
        printLexicalError(
            "Invalid Variable Name",
            "The identifier '" + yytext() + "' starts with a number, which is not allowed in TestLang++.\n" +
            RED + "│" + RESET + "  Variable names must start with a letter (a-z, A-Z) or underscore (_).",
            "INVALID: " + yytext(),
            "VALID: " + yytext().replaceFirst("[0-9]+", "_"),
            "VALID: user" + yytext(),
            "VALID: my" + yytext().substring(0, 1).toUpperCase() + yytext().substring(1)
        );
    }
    {Identifier}    { return symbol(sym.IDENTIFIER, yytext()); }
    {Number}        { return symbol(sym.NUMBER, Integer.parseInt(yytext())); }
    {MultilineString} {
        // Remove triple quotes and preserve content
        String str = yytext();
        str = str.substring(3, str.length() - 3); // Remove """ at both ends
        return symbol(sym.MULTILINE_STRING, str);
    }
    {String}        { 
        // Remove quotes and handle escape sequences
        String str = yytext();
        str = str.substring(1, str.length() - 1); // Remove quotes
        str = str.replace("\\\"", "\"");
        str = str.replace("\\\\", "\\");
        return symbol(sym.STRING, str); 
    }

    /* Whitespace and Comments */
    {WhiteSpace}    { /* ignore */ }
    {Comment}       { /* ignore */ }
}

/* Error fallback */
[^] { 
    String errorChar = yytext();
    String errorType = "Invalid Character";
    String details = "Found unexpected character '" + errorChar + "' in the source code.";
    
    if (errorChar.matches("[0-9]")) {
        // Numeric start error
        printLexicalError(
            errorType,
            details + "\n" +
            RED + "│" + RESET + "  If you're trying to create a variable name, remember:\n" +
            RED + "│" + RESET + "  • Variable names must start with a letter or underscore\n" +
            RED + "│" + RESET + "  • Numbers can be used after the first character\n" +
            RED + "│" + RESET + "  • Use camelCase or snake_case for better readability",
            "INVALID: 1user",
            "VALID: user1",
            "VALID: _user1",
            "VALID: userId"
        );
    } else if (errorChar.matches("[!@#$%^&*(),?\":{}|<>]")) {
        // Special character error
        printLexicalError(
            errorType,
            details + "\n" +
            RED + "│" + RESET + "  This character is not allowed in TestLang++.\n" +
            RED + "│" + RESET + "  Common fixes:\n" +
            RED + "│" + RESET + "  • Use quotes for strings: \"value\"\n" +
            RED + "│" + RESET + "  • Use semicolons to end statements: ;\n" +
            RED + "│" + RESET + "  • Use curly braces for blocks: { }",
            "INVALID: user@name",
            "VALID: userName",
            "VALID: user_name"
        );
    } else {
        // Generic invalid character error
        printLexicalError(
            errorType,
            details + "\n" +
            RED + "│" + RESET + "  This might be caused by:\n" +
            RED + "│" + RESET + "  • Copying special characters from other sources\n" +
            RED + "│" + RESET + "  • Using non-ASCII characters\n" +
            RED + "│" + RESET + "  • Missing quotes around text values",
            "INVALID: let μser = \"value\"",
            "VALID: let user = \"value\"",
            "VALID: let userName = \"value\""
        );
    }
}
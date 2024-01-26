use token;
use strings;
use fmt;

type lexer = struct {
    input: str,
    position: u8,
    read_position: u8,
    ch: rune
};

fn new(input: str) lexer = {
    let l = lexer { input = input, position = 0, read_position = 0, ch = '\0' };
    read_char(&l);

    return l;
};

fn torune(input: str, index: u8) rune = {
    let runes = strings::torunes(input);
    return runes[index];
};

fn read_char(l: *lexer) void = {
    if (l.read_position >= len(l.input)) {
        l.ch = '\0';
    } else {
        l.ch = torune(l.input, l.read_position);
    };
    l.position = l.read_position;
    l.read_position += 1;
};

fn read_identifier(l: *lexer) str = {
    let position = l.position;
    for (is_letter(l.ch)) {
        read_char(l);
    };

    return strings::sub(l.input, position, l.position);
};

fn read_number(l: *lexer) str = {
    let position = l.position;
    for (is_digit(l.ch)) {
        read_char(l);
    };

    return strings::sub(l.input, position, l.position);
};

fn is_letter(ch: rune) bool = {
    let u = ch: u8;
    return ('a' <= u && u <= 'z') || 'A' <= u && u <= 'Z' || ch == '_';
};

fn is_digit(ch: rune) bool = {
    let u = ch: u8;
    return ('0' <= u && u <= '9');
};

fn skip_whitespace(l: *lexer) void = {
    for (l.ch == ' ' || l.ch == '\t' || l.ch == '\n' || l.ch == '\r') {
        read_char(l);
    };
};

fn peek_char(l: *lexer) rune = {
    if (l.read_position >= len(l.input)) {
        return '\0';
    } else {
        return torune(l.input, l.read_position);
    };
};

fn next_token(l: *lexer) token::token = {
    let tok = token::token { tok_type = token::token_type::ILLEGAL, literal = "" };

    skip_whitespace(l);

    switch (l.ch) {
        case '=' =>
            if (peek_char(l) == '=') {
                let ch = l.ch;
                read_char(l);
                let literal = strings::fromrunes([ch, l.ch]);
                tok = token::new_with_str(token::token_type::EQ, literal);
            } else {    
                tok = token::new(token::token_type::ASSIGN, l.ch);
            };
        case ';' =>
            tok = token::new(token::token_type::SEMICOLON, l.ch);
        case '-' =>
            tok = token::new(token::token_type::MINUS, l.ch);
        case '!' =>
            if (peek_char(l) == '=') {
                let ch = l.ch;
                read_char(l);
                let literal = strings::fromrunes([ch, l.ch]);
                tok = token::new_with_str(token::token_type::NOT_EQ, literal);
            } else {
                tok = token::new(token::token_type::BANG, l.ch);
            };
        case '/' =>
            tok = token::new(token::token_type::SLASH, l.ch);
        case '*' =>
            tok = token::new(token::token_type::ASTERISK, l.ch);
        case '<' =>
            tok = token::new(token::token_type::LT, l.ch);
        case '>' =>
            tok = token::new(token::token_type::GT, l.ch);
        case '(' => 
            tok = token::new(token::token_type::LPAREN, l.ch);
        case ')' =>
            tok = token::new(token::token_type::RPAREN, l.ch);
        case ',' =>
            tok = token::new(token::token_type::COMMA, l.ch);
        case '+' =>
            tok = token::new(token::token_type::PLUS, l.ch);
        case '{' =>
            tok = token::new(token::token_type::LBRACE, l.ch);
        case '}' =>
            tok = token::new(token::token_type::RBRACE, l.ch);
        case '\0' =>
            tok = token::new(token::token_type::EOF, l.ch);
        case =>
            if (is_letter(l.ch)) {
                tok.literal = read_identifier(l);
                tok.tok_type = token::lookup_ident(tok.literal);
                return tok;
            } else if (is_digit(l.ch)) {
                tok.tok_type = token::token_type::INT;
                tok.literal = read_number(l);
                return tok;
            } else {
                tok = token::new(token::token_type::ILLEGAL, '\0');
            };
    };

    read_char(l);
    return tok;
};

@test fn test_next_token_signs() void = {
    let input = "=+(){},;";

    let tests: [](token::token_type, str) = [
         (token::token_type::ASSIGN, "="),
         (token::token_type::PLUS, "+"),
         (token::token_type::LPAREN, "("),
         (token::token_type::RPAREN, ")"),
         (token::token_type::LBRACE, "{"),
         (token::token_type::RBRACE, "}"),
         (token::token_type::COMMA, ","),
         (token::token_type::SEMICOLON, ";")
    ];

    let l = new(input);
    for (let i = 0z; i < len(tests); i += 1) {
        let tok = next_token(&l);

        let test = tests[i];
        assert(tok.tok_type == test.0, 
            fmt::asprintf("tests[{}] - tokentype wrong. expected={}, got={}", 
                i, 
                token::token_str(test.0), 
                token::token_str(tok.tok_type)));
    };
};

@test fn test_next_token_code() void = {
    let input = "let five = 5;
let ten = 10;

let add = fn(x, y) {
    x + y;
};

let result = add(five, ten);";

    let tests: [](token::token_type, str) = [
         (token::token_type::LET, "let"),
         (token::token_type::IDENT, "five"),
         (token::token_type::ASSIGN, "="),
         (token::token_type::INT, "5"),
         (token::token_type::SEMICOLON, ";"),
         (token::token_type::LET, "let"),
         (token::token_type::IDENT, "ten"),
         (token::token_type::ASSIGN, "="),
         (token::token_type::INT, "10"),
         (token::token_type::SEMICOLON, ";"),
         (token::token_type::LET, "let"),
         (token::token_type::IDENT, "add"),
         (token::token_type::ASSIGN, "="),
         (token::token_type::FUNCTION, "fn"),
         (token::token_type::LPAREN, "("),
         (token::token_type::IDENT, "x"),
         (token::token_type::COMMA, ","),
         (token::token_type::IDENT, "y"),
         (token::token_type::RPAREN, ")"),
         (token::token_type::LBRACE, "{"),
         (token::token_type::IDENT, "x"),
         (token::token_type::PLUS, "+"),
         (token::token_type::IDENT, "y"),
         (token::token_type::SEMICOLON, ";"),
         (token::token_type::RBRACE, "}"),
         (token::token_type::SEMICOLON, ";"),
         (token::token_type::LET, "let"),
         (token::token_type::IDENT, "result"),
         (token::token_type::ASSIGN, "="),
         (token::token_type::IDENT, "add"),
         (token::token_type::LPAREN, "("),
         (token::token_type::IDENT, "five"),
         (token::token_type::COMMA, ","),
         (token::token_type::IDENT, "ten"),
         (token::token_type::RPAREN, ")"),
         (token::token_type::SEMICOLON, ";"),
         (token::token_type::EOF, "\0"),
    ];

    let l = new(input);
    for (let i = 0z; i < len(tests); i += 1) {
        let tok = next_token(&l);

        let test = tests[i];
        assert(tok.tok_type == test.0, 
            fmt::asprintf("tests[{}] - tokentype wrong. expected={}, got={}", 
                i, 
                token::token_str(test.0), 
                token::token_str(tok.tok_type)));
    };
};

@test fn test_next_token_other_signs() void = {
    let input = "!-/*5;
5 < 10 > 5;";

    let tests: [](token::token_type, str) = [
         (token::token_type::BANG, "!"),
         (token::token_type::MINUS, "-"),
         (token::token_type::SLASH, "/"),
         (token::token_type::ASTERISK, "*"),
         (token::token_type::INT, "5"),
         (token::token_type::SEMICOLON, ";"),
         (token::token_type::INT, "5"),
         (token::token_type::LT, "<"),
         (token::token_type::INT, "10"),
         (token::token_type::GT, ">"),
         (token::token_type::INT, "5"),
         (token::token_type::SEMICOLON, ";")
    ];

    let l = new(input);
    for (let i = 0z; i < len(tests); i += 1) {
        let tok = next_token(&l);

        let test = tests[i];
        assert(tok.tok_type == test.0, 
            fmt::asprintf("tests[{}] - tokentype wrong. expected={}, got={}", 
                i, 
                token::token_str(test.0), 
                token::token_str(tok.tok_type)));
    };
};

@test fn test_next_token_conditions() void = {
    let input = "
if (5 < 10) {
    return true;
} else {
    return false;
}    
    ";

    let tests: [](token::token_type, str) = [
         (token::token_type::IF, "if"),
         (token::token_type::LPAREN, "("),
         (token::token_type::INT, "5"),
         (token::token_type::LT, "<"),
         (token::token_type::INT, "10"),
         (token::token_type::RPAREN, ")"),
         (token::token_type::LBRACE, "{"),
         (token::token_type::RETURN, "return"),
         (token::token_type::TRUE, "true"),
         (token::token_type::SEMICOLON, ";"),
         (token::token_type::RBRACE, "}"),
         (token::token_type::ELSE, "else"),
         (token::token_type::LBRACE, "{"),
         (token::token_type::RETURN, "return"),
         (token::token_type::FALSE, "false"),
         (token::token_type::SEMICOLON, ";"),
         (token::token_type::RBRACE, "}"),
    ];

    let l = new(input);
    for (let i = 0z; i < len(tests); i += 1) {
        let tok = next_token(&l);

        let test = tests[i];
        assert(tok.tok_type == test.0, 
            fmt::asprintf("tests[{}] - tokentype wrong. expected={}, got={}", 
                i, 
                token::token_str(test.0), 
                token::token_str(tok.tok_type)));
    };
};

@test fn test_next_token_comparing() void = {
    let input = "
10 == 10;
10 != 9;   
    ";

    let tests: [](token::token_type, str) = [
         (token::token_type::INT, "10"),
         (token::token_type::EQ, "=="),
         (token::token_type::INT, "10"),
         (token::token_type::SEMICOLON, ";"),
         (token::token_type::INT, "10"),
         (token::token_type::NOT_EQ, "!="),
         (token::token_type::INT, "9"),
         (token::token_type::SEMICOLON, ";")
    ];

    let l = new(input);
    for (let i = 0z; i < len(tests); i += 1) {
        let tok = next_token(&l);

        let test = tests[i];
        assert(tok.tok_type == test.0, 
            fmt::asprintf("tests[{}] - tokentype wrong. expected={}, got={}", 
                i, 
                token::token_str(test.0), 
                token::token_str(tok.tok_type)));
    };
};
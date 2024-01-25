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

fn next_token(l: *lexer) token::token = {
    let tok = token::token { tok_type = token::token_type::ILLEGAL, literal = ' ' };

    switch (l.ch) {
        case '=' =>
            tok = token::new(token::token_type::ASSIGN, l.ch);
        case ';' =>
            tok = token::new(token::token_type::SEMICOLON, l.ch);
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
        case =>
            tok = token::new(token::token_type::EOF, '\0');
    };

    read_char(l);
    return tok;
};

@test fn test_next_token() void = {
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
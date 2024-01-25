export type token_type = enum {
    ILLEGAL,
    EOF,

    IDENT,
    INT,

    ASSIGN,
    PLUS,

    COMMA,
    SEMICOLON,

    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,

    FUNCTION,
    LET
};

export fn token_str(tok_type: token_type) str = {
    switch (tok_type) {
        case token_type::ILLEGAL =>
            return "ILLEGAL";
        case token_type::EOF =>
            return "EOF";
        case token_type::IDENT =>
            return "IDENT";
        case token_type::INT =>
            return "INT";
        case token_type::ASSIGN =>
            return "=";
        case token_type::PLUS =>
            return "+";
        case token_type::COMMA =>
            return ",";
        case token_type::SEMICOLON =>
            return ";";
        case token_type::LPAREN => 
            return "(";
        case token_type::RPAREN =>
            return ")";
        case token_type::LBRACE =>
            return "{";
        case token_type::RBRACE =>
            return "}";
        case token_type::FUNCTION =>
            return "FUNCTION";
        case token_type::LET =>
            return "LET";
    };
};

export type token = struct {
    tok_type: token_type,
    literal: rune
};

export fn new(tok_type: token_type, ch: rune) token = {
    return token { tok_type = tok_type, literal = ch };
};
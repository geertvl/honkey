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

export type token = struct {
    tok_type: token_type,
    literal: rune
};

export fn new(tok_type: token_type, ch: rune) token = {
    return token { tok_type = tok_type, literal = ch };
};
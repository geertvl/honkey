use strings;

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
    literal: str
};

export fn to_string(ch: rune) str = {
    let s: []rune = [ ch ];
    return strings::fromrunes(s); 
};

export fn new(tok_type: token_type, ch: rune) token = {
    return token { tok_type = tok_type, literal = to_string(ch) };
};

export type keyword = struct {
    identifier: str,
    tok_type: token_type
};

export let keywords: []keyword = [
    keyword { identifier = "fn", tok_type = token_type::FUNCTION },
    keyword { identifier = "let", tok_type = token_type::LET }
];

export fn lookup_ident(ident: str) token_type = {
    for (let i = 0z; i < len(keywords); i += 1) {
        let kw = keywords[i];
        if (kw.identifier == ident) {
            return kw.tok_type;
        };
    };

    return token_type::IDENT;
};

@test fn test_lookup_ident_found() void = {
    let ident = "let";

    let result = lookup_ident(ident);

    assert(result == token_type::LET);
};

@test fn test_lookup_ident_not_found() void = {
    let ident = "five";

    let result = lookup_ident(ident);

    assert(result == token_type::IDENT);
};
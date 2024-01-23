type token_type = enum {
    ASSIGN
};

type token = struct {
    ttype: token_type,
    literal: str
};
type lexer = struct {
    input: str,
    position: u8,
    read_position: u8,
    ch: u8
};

fn new(input: str) lexer = {
    return lexer { input = input, position = 0, read_position = 0, ch = 0 };
};

@test fn test_next_token() void = {
    let l = new("test");

    assert(l.input == "test", "input is correct");
};
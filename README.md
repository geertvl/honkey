# RATIONALE

An implementation of the Monkey Language in the Hare programming language. Just solely to learn and experiment with Hare.
Writing notes what is missing in the documentation of Hare. 

# Todo

- There is no language server for Hare.
- In markdown the code block for Hare code snippets are missing.

# Notes 

---
You can use a module in another module or simply one element by doing so.

module1
```hare
  export type token = struct {
    literal: str
  };

  export type token2 = struct {
    special_literal: str
  }
```

module2
```hare
  use module1::{token};

  let t = token { literal = "let" };
```

otherwise you need to fully specify, and it could be that you only one of the two.
---

In a switch, it is not assignable, and default value is the following:

```hare
    let t = switch(ch) {
        case "a" =>
            return 1;
        case "b" =>
            return 2;
        case =>
            return 9;
    };
```

---
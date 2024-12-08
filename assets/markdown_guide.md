# Markdown Syntax Guide

Markdown is a lightweight markup language for formatting text.

## Headings
Use `#`, `##`, `###`, etc. for headings:

```markdown
# Heading 1
## Heading 2
### Heading 3
```

Renders as:

# Heading 1  
## Heading 2  
### Heading 3

---

## Emphasis
Use `*` or `_` for italic, and `**` or `__` for bold:

```markdown
*italic* or _italic_  
**bold** or __bold__
```

Renders as:

*italic*  
**bold**

---

## Lists

### Unordered
Use `-`, `+`, or `*` for bullet points:

```markdown
- Item 1
- Item 2
  - Sub-item
```

### Ordered
Use numbers followed by periods:

```markdown
1. Item 1
2. Item 2
```

---

## Code
Wrap inline code with backticks `` `code` ``:

```markdown
Inline `code`
```

Renders as: Inline `code`

For blocks of code, use triple backticks:

```markdown
    ```rust
        fn main() {
            println!("Hello, Markdown in Rust!");
        }
    ```
```

appears as:
```rust
fn main() {
    println!("Hello, Markdown in Rust!");
}
```
---

## Popular Languages for Code Blocks
When adding code blocks, use the following identifiers:

1. `bash`
2. `cpp`
3. `csharp`
4. `css`
5. `dart`
6. `go`
7. `html`
8. `java`
9. `javascript`
10. `kotlin`
11. `markdown`
12. `objectivec`
13. `perl`
14. `php`
15. `python`
16. `ruby`
17. `rust`
18. `scala`
19. `sql`
20. `swift`

---

## Links

```markdown
[Link Text](https://example.com)
```

Renders as: [Link Text](https://example.com)

---

## Images

```markdown
![Alt Text](image_url)
```

---

## Blockquotes
Use `>`:

```markdown
> Blockquote
```

Renders as:

> Blockquote

---

## Tables
Create tables using `|` and `-`:

```markdown
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |
```

Renders as:

| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |

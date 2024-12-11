## Super Quick Guide
To insert code:
```html
<pre><code>
fn some_code(){
}
</code></pre>
```
The pre tag just makes it so that line spaces, newlines, etc are preserved.

# HTML Syntax Guide

HTML (HyperText Markup Language) is the standard language for creating web pages.

## Basic Structure
An HTML document begins with the `<!DOCTYPE>` declaration, followed by the `<html>` element.

```html
<!DOCTYPE html>
<html>
<head>
    <title>Page Title</title>
</head>
<body>
    <h1>Welcome to HTML!</h1>
    <p>This is a basic HTML structure.</p>
</body>
</html>
```

---

## Headings
HTML supports six levels of headings, from `<h1>` (largest) to `<h6>` (smallest):

```html
<h1>Main Heading</h1>
<h2>Subheading</h2>
<h3>Sub-subheading</h3>
```

Renders as:

<h1>Main Heading</h1>
<h2>Subheading</h2>
<h3>Sub-subheading</h3>

---

## Text Formatting

### Paragraphs and Line Breaks
```html
<p>This is a paragraph.</p>
<p>This is another paragraph.</p>
<p>Line 1<br>Line 2<br>Line 3</p>
```

Renders as:

<p>This is a paragraph.</p>
<p>This is another paragraph.</p>
<p>Line 1<br>Line 2<br>Line 3</p>

### Bold, Italic, and Underline
```html
<b>Bold text</b>
<i>Italic text</i>
<u>Underlined text</u>
```

Renders as:

<b>Bold text</b>  
<i>Italic text</i>  
<u>Underlined text</u>

---

## Links
Create hyperlinks using the `<a>` tag:

```html
<a href="https://example.com">Visit Example</a>
```

Renders as:

<a href="https://example.com">Visit Example</a>

---

## Images
Add images using the `<img>` tag:

```html
<img src="image_url.jpg" alt="Description of the image" width="300" height="200">
```

---

## Lists

### Unordered List
```html
<ul>
  <li>Item 1</li>
  <li>Item 2</li>
  <li>Item 3</li>
</ul>
```

Renders as:

<ul>
  <li>Item 1</li>
  <li>Item 2</li>
  <li>Item 3</li>
</ul>

### Ordered List
```html
<ol>
  <li>First item</li>
  <li>Second item</li>
  <li>Third item</li>
</ol>
```

Renders as:

<ol>
  <li>First item</li>
  <li>Second item</li>
  <li>Third item</li>
</ol>

---

## Tables
Create tables using the `<table>` tag, along with `<tr>`, `<th>`, and `<td>`:

```html
<table border="1">
  <tr>
    <th>Header 1</th>
    <th>Header 2</th>
  </tr>
  <tr>
    <td>Cell 1</td>
    <td>Cell 2</td>
  </tr>
</table>
```

Renders as:

<table border="1">
  <tr>
    <th>Header 1</th>
    <th>Header 2</th>
  </tr>
  <tr>
    <td>Cell 1</td>
    <td>Cell 2</td>
  </tr>
</table>

---

## Forms
Create user input forms using `<form>`:

```html
<form action="/submit" method="post">
  <label for="name">Name:</label>
  <input type="text" id="name" name="name">

  <label for="email">Email:</label>
  <input type="email" id="email" name="email">

  <input type="submit" value="Submit">
</form>
```

---

## Multimedia

### Embedding a Video
```html
<video width="320" height="240" controls>
  <source src="movie.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>
```

### Embedding Audio
```html
<audio controls>
  <source src="audio.mp3" type="audio/mpeg">
  Your browser does not support the audio element.
</audio>
```

---

## Semantic Elements
HTML5 includes semantic elements to describe the structure of a web page:

```html
<header>
  <h1>Website Header</h1>
</header>

<nav>
  <a href="#">Home</a>
  <a href="#">About</a>
</nav>

<main>
  <article>
    <h2>Article Title</h2>
    <p>This is an article.</p>
  </article>
</main>

<footer>
  <p>Website Footer</p>
</footer>
```

---

## Comments
Add comments in HTML using `<!-- -->`:

```html
<!-- This is a comment and will not be displayed in the browser -->
```

---

This guide covers common HTML elements and their usage. Explore these examples to build well-structured web pages!

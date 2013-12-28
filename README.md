markdown
========

Lasso 9 Markdown processor that avoids use of Regular Expressions which can be problematic in the Lasso 9 parser
if a mistake is made in the source syntax.

Processes Markdown Syntax as per [John Gruber's spec](http://daringfireball.net/projects/markdown/syntax)

The project is a work in progress - please see below.

Supports
--------
- Setext-style headers
- atx headers
- code blocks (with &, <, > encoding to html entities)
- ** & __ demark strong
- * demark em
- * & _ surrounded by spaces are protected.
- escaped backticks are protected
- text inline and surrounded by backticks is wrapped in `<code>...</code>`
	
TODO
----
- Links
- Images
- Lists

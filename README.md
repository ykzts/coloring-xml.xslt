# coloring-xml.xslt

XSLT 1.0 stylesheet that renders XML as readable, colorized HTML. Built for quick inspection and works well with modern browsers.

## Features

- Syntax highlighting with CSS variables (easy theming + dark mode)
- Collapsible elements
- Accessible focus styles for interactive tags
- Works offline (data URI for CSS/JS)

## Usage

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="application/xml" href="./coloring-xml.xslt"?>
<document xmlns="http://www.example.com/document">
  <!-- ... -->
</document>
```

Or

```shell
$ xsltproc coloring-xml.xslt document.xml > document.html
```

Or

Use the W3C XSLT Servlet:

- https://services.w3.org/xslt?xslfile=https%3A%2F%2Fraw.githubusercontent.com%2Fykzts%2Fcoloring-xml.xslt%2Fmaster%2Fcoloring-xml.xslt;xmlfile=https%3A%2F%2Fraw.githubusercontent.com%2Fykzts%2Fcoloring-xml.xslt%2Fmaster%2Fcoloring-xml.xslt

## Notes

- If you need external assets, host the CSS/JS and replace the data URI templates.

## License

[MIT License](LICENSE)

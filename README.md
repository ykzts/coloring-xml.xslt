# coloring-xml.xslt

Coloring to xml document using XSLT stylesheet! I love XSLT!!! XSLT is a greatest amazing specification from W3C!

[![Coloring](http://ec2.images-amazon.com/images/I/51fAXgKtqhL.jpg)](http://www.amazon.co.jp/dp/B005XOK9R2)

## Example for using

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="application/xml" href="./coloring-xml.xslt"?>
<document xmlns="http://www.example.com/document">
  <!-- ... -->
</document>
```

or

```shell
$ xsltproc coloring-xml.xslt document.xml > document.html
```

or

[using W3C XSLT Servlet](http://services.w3.org/xslt?xslfile=https%3A%2F%2Fraw.github.com%2Fykzts%2Fcoloring-xml.xslt%2Fmaster%2Fcoloring-xml.xslt;xmlfile=https%3A%2F%2Fraw.github.com%2Fykzts%2Fcoloring-xml.xslt%2Fmaster%2Fcoloring-xml.xslt)

## License

[MIT License](LICENSE)

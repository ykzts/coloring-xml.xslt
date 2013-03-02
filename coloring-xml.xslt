<?xml version="1.0" encoding="utf-8" standalone="no"?>
<?xml-stylesheet type="application/xml" href=""?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="no" media-type="text/html" indent="yes" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/">
    <html>
      <head>
        <style type="text/css"><![CDATA[
* { margin: 0; padding: 0 }
body { background-color: whiter }
ol { list-style: none }
ol ol { margin-left: 1em }
.xml-declaration .name { color: aqua }
.processing-instruction .name { color: aqua }
.tag .name { color: blue }
.attribute .name { color: maroon }
.attribute .value { color: green }
]]></style>
        <title>xml2html</title>
      </head>
      <body>
        <ol>
          <li>
            <span class="xml-declaration">
              <xsl:text>&lt;?</xsl:text>
              <span class="name">xml</span>
              <xsl:text> version="1.0"?&gt;</xsl:text>
            </span>
          </li>
          <xsl:apply-templates/>
        </ol>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="processing-instruction()">
    <li>
      <span class="processing-instruction">
        <xsl:text>&lt;?</xsl:text>
        <span class="name">
          <xsl:value-of select="name()"/>
        </span>
        <xsl:value-of select="concat(' ', .)"/>
        <xsl:text>?&gt;</xsl:text>
      </span>
    </li>
  </xsl:template>

  <xsl:template match="comment()">
    <li>
      <span class="comment">
        <xsl:text>&lt;!--</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>--&gt;</xsl:text>
      </span>
    </li>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template match="text()[string-length(.) &gt; 100]">
    <ol>
      <li>
        <xsl:value-of select="."/>
      </li>
    </ol>
  </xsl:template>

  <xsl:template match="*">
    <li>
      <xsl:call-template name="tag"/>
    </li>
  </xsl:template>

  <xsl:template name="tag">
    <span class="tag">
      <xsl:text>&lt;</xsl:text>
      <span class="name">
        <xsl:value-of select="name()"/>
      </span>
      <xsl:apply-templates select="@*"/>
      <xsl:if test="not(node())">
        <xsl:text>/</xsl:text>
      </xsl:if>
      <xsl:text>&gt;</xsl:text>
    </span>
    <xsl:if test="node()">
      <xsl:choose>
        <xsl:when test="*">
          <ol>
            <xsl:apply-templates/>
          </ol>
        </xsl:when>
        <xsl:when test="text()">
          <xsl:apply-templates select="text()"/>
        </xsl:when>
      </xsl:choose>
      <span class="tag">
        <xsl:text>&lt;/</xsl:text>
        <span class="name">
          <xsl:value-of select="name()"/>
        </span>
        <xsl:text>&gt;</xsl:text>
      </span>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:text> </xsl:text>
    <span class="attribute">
      <span class="name">
        <xsl:value-of select="name()"/>
      </span>
      <xsl:text>=</xsl:text>
      <span class="value">
        <xsl:value-of select="concat('&quot;', ., '&quot;')"/>
      </span>
    </span>
  </xsl:template>
</xsl:stylesheet>

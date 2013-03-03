<?xml version="1.0" encoding="utf-8" standalone="no"?>
<?xml-stylesheet type="application/xml" href=""?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="no" media-type="text/html" indent="no" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/">
    <html xml:lang="en">
      <head>
        <style type="text/css"><![CDATA[* { margin: 0; padding: 0 }
body { font-family: monospace; line-height: 1.5; background-color: white }
ol { list-style: none }
ol ol { margin-left: 1em }
a { color: inherit; text-decoration: underline }
.xml-declaration .name { color: aqua }
.processing-instruction .name { color: aqua }
.tag .name span { color: blue }
.attribute .name span { color: maroon }
.attribute .value { color: green }
.comment { color: silver }
.text { white-space: pre }
.character-reference { color: lime }]]></style>
        <title>
          <xsl:value-of select="concat(name(*), ' document')"/>
        </title>
      </head>
      <body>
        <ol>
          <li>
            <span class="xml-declaration">
              <xsl:text>&lt;?</xsl:text>
              <span class="name">xml</span>
              <xsl:text>&#160;</xsl:text>
              <xsl:call-template name="attribute">
                <xsl:with-param name="name">version</xsl:with-param>
                <xsl:with-param name="value">1.0</xsl:with-param>
              </xsl:call-template>
              <xsl:text>?&gt;</xsl:text>
            </span>
          </li>
          <xsl:apply-templates/>
        </ol>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="processing-instruction()">
    <li>
      <xsl:call-template name="processing-instruction"/>
    </li>
  </xsl:template>

  <xsl:template name="processing-instruction">
    <span class="processing-instruction">
      <xsl:text>&lt;?</xsl:text>
      <span class="name">
        <xsl:value-of select="name()"/>
      </span>
      <xsl:call-template name="processing-instruction-attributes">
        <xsl:with-param name="attributes" select="normalize-space(.)"/>
      </xsl:call-template>
      <xsl:text>?&gt;</xsl:text>
    </span>
  </xsl:template>

  <xsl:template name="processing-instruction-attributes">
    <xsl:param name="attributes"/>
    <xsl:if test="string-length($attributes) &gt; 0">
      <xsl:call-template name="processing-instruction-attribute">
        <xsl:with-param name="name" select="normalize-space(substring-before($attributes, '='))"/>
        <xsl:with-param name="value" select="substring-before(substring-after($attributes, '=&quot;'), '&quot;')"/>
      </xsl:call-template>
      <xsl:call-template name="processing-instruction-attributes">
        <xsl:with-param name="attributes" select="substring-after(substring-after($attributes, '=&quot;'), '&quot;')"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="processing-instruction-attribute">
    <xsl:param name="name"/>
    <xsl:param name="value"/>
    <xsl:text>&#160;</xsl:text>
    <xsl:call-template name="attribute">
      <xsl:with-param name="name" select="$name"/>
      <xsl:with-param name="value" select="$value"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="comment()">
    <li>
      <span class="comment">
        <xsl:text>&lt;!--</xsl:text>
        <xsl:call-template name="plain-text"/>
        <xsl:text>--&gt;</xsl:text>
      </span>
    </li>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:choose>
      <xsl:when test="preceding-sibling::* or following-sibling::*">
        <li>
          <xsl:call-template name="text-node"/>
        </li>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="text-node"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="text-node">
    <xsl:choose>
      <xsl:when test="string-length(.) &gt; 100">
        <xsl:call-template name="text-node-long"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="plain-text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="text-node-long">
    <ol>
      <li>
        <xsl:call-template name="plain-text"/>
      </li>
    </ol>
  </xsl:template>

  <xsl:template match="*">
    <li>
      <xsl:call-template name="element"/>
    </li>
  </xsl:template>

  <xsl:template name="element">
    <xsl:call-template name="tag"/>
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
      <xsl:call-template name="tag">
        <xsl:with-param name="is-close-tag" select="true()"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tag">
    <xsl:param name="prefix" select="substring-before(name(), ':')"/>
    <xsl:param name="is-close-tag" select="false()"/>
    <span class="tag">
      <xsl:text>&lt;</xsl:text>
      <xsl:if test="$is-close-tag">
        <xsl:text>/</xsl:text>
      </xsl:if>
      <span class="name">
        <xsl:if test="$prefix">
          <span class="prefix">
            <xsl:value-of select="$prefix"/>
          </span>
          <xsl:text>:</xsl:text>
        </xsl:if>
        <span class="local-name">
          <xsl:value-of select="local-name()"/>
        </span>
      </span>
      <xsl:if test="not($is-close-tag)">
        <xsl:apply-templates select="@*"/>
        <xsl:if test="not(node())">
          <xsl:text>/</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:text>&gt;</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:text>&#160;</xsl:text>
    <xsl:call-template name="attribute">
      <xsl:with-param name="name" select="name()"/>
      <xsl:with-param name="value" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="attribute">
    <xsl:param name="name"/>
    <xsl:param name="value"/>
    <xsl:param name="prefix" select="substring-before($name, ':')"/>
    <span class="attribute">
      <span class="name">
        <xsl:choose>
          <xsl:when test="$prefix">
            <span class="prefix">
              <xsl:value-of select="$prefix"/>
            </span>
            <xsl:text>:</xsl:text>
            <span class="local-name">
              <xsl:value-of select="substring-after($name, ':')"/>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <span calss="local-name">
              <xsl:value-of select="$name"/>
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </span>
      <xsl:text>=</xsl:text>
      <xsl:call-template name="attribute-value">
        <xsl:with-param name="name" select="$name"/>
        <xsl:with-param name="value" select="$value"/>
      </xsl:call-template>
    </span>
  </xsl:template>

  <xsl:template name="attribute-value">
    <xsl:param name="name"/>
    <xsl:param name="value"/>
    <span class="value">
      <xsl:text>&quot;</xsl:text>
      <xsl:choose>
        <xsl:when test="$value and $name = 'href' or substring-after($name, ':') = 'href' or starts-with($value, 'http://') or starts-with($value, 'https://')">
          <a href="{$value}">
            <xsl:call-template name="attribute-value-text">
              <xsl:with-param name="text" select="$value"/>
            </xsl:call-template>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="attribute-value-text">
            <xsl:with-param name="text" select="$value"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&quot;</xsl:text>
    </span>
  </xsl:template>

  <xsl:template name="attribute-value-text">
    <xsl:param name="text"/>
    <xsl:call-template name="replace-character">
      <xsl:with-param name="text" select="$text"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="plain-text">
    <span class="text">
      <xsl:call-template name="replace-character">
        <xsl:with-param name="text" select="."/>
      </xsl:call-template>
    </span>
  </xsl:template>

  <xsl:template name="replace-character">
    <xsl:param name="text"/>
    <xsl:choose>
      <xsl:when test="starts-with($text, '&amp;')">
        <xsl:call-template name="replace-character2">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="from" select="'&amp;'"/>
          <xsl:with-param name="to" select="'&amp;amp;'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="starts-with($text, '&lt;')">
        <xsl:call-template name="replace-character2">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="from" select="'&lt;'"/>
          <xsl:with-param name="to" select="'&amp;lt;'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="starts-with($text, '&gt;')">
        <xsl:call-template name="replace-character2">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="from" select="'&gt;'"/>
          <xsl:with-param name="to" select="'&amp;gt;'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="starts-with($text, '&quot;')">
        <xsl:call-template name="replace-character2">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="from" select="'&quot;'"/>
          <xsl:with-param name="to" select="'&amp;quot;'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="starts-with($text, '&#160;')">
        <xsl:call-template name="replace-character2">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="from" select="'&#160;'"/>
          <xsl:with-param name="to" select="'&amp;nbsp;'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="string-length($text) &gt; 0">
        <xsl:value-of select="substring($text, 1, 1)"/>
        <xsl:call-template name="replace-character">
          <xsl:with-param name="text" select="substring($text, 2)"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="replace-character2">
    <xsl:param name="text"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:if test="starts-with($text, $from)">
      <xsl:choose>
        <xsl:when test="starts-with($to, '&amp;') and substring($to, string-length($to), 1) = ';'">
          <span class="character-reference" title="{$from}">
            <xsl:value-of select="$to"/>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$to"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="replace-character">
        <xsl:with-param name="text" select="substring-after($text, $from)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>

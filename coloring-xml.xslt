<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<?xml-stylesheet type="application/xml" href=""?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="xhtml xsl" xml:lang="en">
  <xsl:param name="lang">
    <xsl:choose>
      <xsl:when test="/*/@xml:lang">
        <xsl:value-of select="/*/@xml:lang"/>
      </xsl:when>
      <xsl:when test="/*/@lang">
        <xsl:value-of select="/*/@lang"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>en</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="encoding">
    <xsl:call-template name="guess-encoding"/>
  </xsl:param>
  <xsl:param name="xmlfile">
    <!-- For W3C XSLT Servlet -->
  </xsl:param>
  <xsl:param name="original-uri">
    <xsl:choose>
      <xsl:when test="string-length($xmlfile) &gt; 0">
        <xsl:value-of select="$xmlfile"/>
      </xsl:when>
    </xsl:choose>
  </xsl:param>
  <xsl:variable name="upper-case">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
  <xsl:variable name="lower-case">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="lf" select="'&#10;'"/>
  <xsl:variable name="cr" select="'&#13;'"/>
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" media-type="application/xhtml+xml" indent="no" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

  <xsl:template name="guess-encoding">
    <xsl:variable name="html-encoding">
      <xsl:if test="/*[local-name() = 'html' and namespace-uri() = 'http://www.w3.org/1999/xhtml']">
        <xsl:call-template name="guess-encoding-html"/>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($html-encoding) &gt; 0">
        <xsl:value-of select="$html-encoding"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>UTF-8</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="guess-encoding-html">
    <xsl:variable name="meta-element" select="/xhtml:html/xhtml:head/xhtml:meta[@charset or translate(@http-equiv, $upper-case, $lower-case) = 'content-type'][last()]"/>
    <xsl:choose>
      <xsl:when test="$meta-element/@charset">
        <xsl:value-of select="$meta-element/@charset"/>
      </xsl:when>
      <xsl:when test="$meta-element/@http-equiv">
        <xsl:value-of select="substring-after($meta-element/@content, 'charset=')"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/">
    <html xml:lang="{$lang}" lang="{$lang}">
      <head>
        <xsl:if test="string-length($original-uri) &gt; 0">
          <base href="{$original-uri}"/>
        </xsl:if>
        <meta http-equiv="Content-Type" content="text/html; charset={$encoding}"/>
        <meta http-equiv="Content-Style-Type" content="text/css"/>
        <meta http-equiv="Content-Script-Type" content="application/javascript"/>
        <link rel="stylesheet" type="text/css">
          <xsl:attribute name="href">
            <xsl:call-template name="data-uri">
              <xsl:with-param name="content-type">text/css</xsl:with-param>
              <xsl:with-param name="text">
                <xsl:call-template name="main.css"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </link>
        <title>
          <xsl:value-of select="concat(name(*), ' document')"/>
        </title>
      </head>
      <body>
        <ol>
          <li>
            <xsl:call-template name="xml-declaration"/>
          </li>
          <xsl:apply-templates/>
        </ol>
        <script type="application/javascript">
          <xsl:attribute name="src">
            <xsl:call-template name="data-uri">
              <xsl:with-param name="content-type">application/javascript</xsl:with-param>
              <xsl:with-param name="text">
                <xsl:call-template name="site-script.js"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
        </script>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="xml-declaration">
    <xsl:variable name="attributes">
      <xsl:text>version=&quot;1.0&quot;</xsl:text>
      <xsl:if test="$encoding">
        <xsl:text> encoding=&quot;</xsl:text>
        <xsl:value-of select="$encoding"/>
        <xsl:text>&quot;</xsl:text>
      </xsl:if>
    </xsl:variable>
    <span class="xml-declaration">
      <xsl:text>&lt;?</xsl:text>
      <span class="name">xml</span>
      <xsl:call-template name="processing-instruction-attributes">
        <xsl:with-param name="attributes" select="$attributes"/>
      </xsl:call-template>
      <xsl:text>?&gt;</xsl:text>
    </span>
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
    <xsl:variable name="before-first-space">
      <xsl:choose>
        <xsl:when test="contains(substring-before($attributes, '&quot;'), ' ')">
          <xsl:value-of select="substring-before($attributes, ' ')"/>
        </xsl:when>
        <xsl:when test="substring-before($attributes, '&quot; ')">
          <xsl:value-of select="substring-before($attributes, '&quot;')"/>
          <xsl:text>&quot;</xsl:text>
          <xsl:value-of select="substring-before(substring-after($attributes, '&quot;'), '&quot;')"/>
          <xsl:text>&quot;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$attributes"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="after-first-space">
      <xsl:if test="string-length($before-first-space) &gt; 0">
        <xsl:value-of select="substring-after($attributes, concat($before-first-space, ' '))"/>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="string-length($before-first-space) &gt; 0">
      <xsl:call-template name="processing-instruction-attribute">
        <xsl:with-param name="attribute" select="$before-first-space"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="string-length($after-first-space) &gt; 0">
      <xsl:call-template name="processing-instruction-attributes">
        <xsl:with-param name="attributes" select="$after-first-space"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="processing-instruction-attribute">
    <xsl:param name="attribute"/>
    <xsl:variable name="name" select="substring-before($attribute, '=&quot;')"/>
    <xsl:text>&#160;</xsl:text>
    <xsl:choose>
      <xsl:when test="$name and substring($attribute, string-length($attribute), 1) = '&quot;'">
        <xsl:call-template name="attribute">
          <xsl:with-param name="name" select="$name"/>
          <xsl:with-param name="value" select="substring-before(substring-after($attribute, concat($name, '=&quot;')), '&quot;')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <span class="string">
          <xsl:value-of select="$attribute"/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="comment()">
    <li>
      <span class="comment">
        <xsl:text>&lt;!--</xsl:text>
        <xsl:choose>
          <xsl:when test="contains(., $lf) or contains(., $cr)">
            <xsl:call-template name="plain-text-lines">
              <xsl:with-param name="text" select="."/>
              <xsl:with-param name="escape" select="false()"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="plain-text">
              <xsl:with-param name="text" select="."/>
              <xsl:with-param name="escape" select="false()"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
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
        <xsl:choose>
          <xsl:when test="(contains(., $lf) or contains(., $cr)) and (contains(., '&lt;') or contains(., '&gt;') or contains(., '&amp;') or contains(., '&quot;'))">
            <ol>
              <li>
                <span class="section">
                  <xsl:text>&lt;![</xsl:text>
                  <span class="name">CDATA</span>
                  <xsl:text>[</xsl:text>
                </span>
              </li>
              <li>
                <xsl:call-template name="text-node">
                  <xsl:with-param name="escape" select="false()"/>
                </xsl:call-template>
              </li>
              <li>
                <span class="section">
                  <xsl:text>]]&gt;</xsl:text>
                </span>
              </li>
            </ol>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="text-node"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="text-node">
    <xsl:param name="text" select="."/>
    <xsl:param name="escape" select="true()"/>
    <xsl:choose>
      <xsl:when test="contains($text, $lf) or contains($text, $cr)">
        <xsl:call-template name="text-node-multiple-lines">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="escape" select="$escape"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="string-length($text) &gt; 100">
        <xsl:call-template name="text-node-long">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="escape" select="$escape"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="plain-text">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="escape" select="$escape"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="text-node-multiple-lines">
    <xsl:param name="text" select="."/>
    <xsl:param name="escape" select="true()"/>
    <ol>
      <li>
        <xsl:call-template name="plain-text-lines">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="escape" select="$escape"/>
        </xsl:call-template>
      </li>
    </ol>
  </xsl:template>

  <xsl:template name="text-node-long">
    <xsl:param name="text" select="."/>
    <xsl:param name="escape" select="true()"/>
    <ol>
      <li>
        <xsl:call-template name="plain-text">
          <xsl:with-param name="text" select="$text"/>
          <xsl:with-param name="escape" select="$escape"/>
        </xsl:call-template>
      </li>
    </ol>
  </xsl:template>

  <xsl:template match="*">
    <li>
      <xsl:call-template name="element"/>
    </li>
  </xsl:template>

  <xsl:template name="element">
    <xsl:variable name="many-attributes" select="count(@*) &gt;= 5"/>
    <xsl:if test="@id">
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:call-template name="tag">
      <xsl:with-param name="many-attributes" select="$many-attributes"/>
    </xsl:call-template>
    <xsl:if test="node()">
      <xsl:choose>
        <xsl:when test="text()[not(preceding-sibling::* or following-sibling::*)]">
          <xsl:choose>
            <xsl:when test="$many-attributes">
              <xsl:call-template name="text-node-long">
                <xsl:with-param name="text" select="text()"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="text()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <ol>
            <xsl:apply-templates/>
          </ol>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="tag">
        <xsl:with-param name="is-close-tag" select="true()"/>
        <xsl:with-param name="many-attributes" select="$many-attributes"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tag">
    <xsl:param name="is-close-tag" select="false()"/>
    <xsl:param name="many-attributes" select="false()"/>
    <xsl:variable name="element-name">
      <xsl:choose>
        <xsl:when test="$many-attributes">
          <xsl:text>div</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>span</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$element-name}">
      <xsl:attribute name="class">tag</xsl:attribute>
      <xsl:text>&lt;</xsl:text>
      <xsl:if test="$is-close-tag">
        <xsl:text>/</xsl:text>
      </xsl:if>
      <xsl:call-template name="name">
        <xsl:with-param name="name" select="name()"/>
      </xsl:call-template>
      <xsl:if test="not($is-close-tag)">
        <xsl:choose>
          <xsl:when test="$many-attributes">
            <ol>
              <xsl:apply-templates select="@*" mode="many-attributes"/>
            </ol>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="@*"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(node())">
          <xsl:text>/</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:text>&gt;</xsl:text>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:text>&#160;</xsl:text>
    <xsl:call-template name="html-attribute"/>
  </xsl:template>

  <xsl:template match="@*" mode="many-attributes">
    <li>
      <xsl:call-template name="html-attribute"/>
    </li>
  </xsl:template>

  <xsl:template name="html-attribute">
    <xsl:call-template name="attribute">
      <xsl:with-param name="name" select="name()"/>
      <xsl:with-param name="value" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="name">
    <xsl:param name="name"/>
    <xsl:variable name="prefix" select="substring-before($name, ':')"/>
    <xsl:variable name="namespace-uri" select="namespace-uri()"/>
    <span class="name">
      <xsl:choose>
        <xsl:when test="$prefix">
          <span class="prefix">
            <xsl:if test="$namespace-uri">
              <xsl:attribute name="title">
                <xsl:value-of select="$namespace-uri"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$prefix"/>
          </span>
          <xsl:text>:</xsl:text>
          <span class="local-name">
            <xsl:value-of select="substring-after($name, ':')"/>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <span class="local-name">
            <xsl:if test="$namespace-uri">
              <xsl:attribute name="title">
                <xsl:value-of select="$namespace-uri"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$name"/>
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <xsl:template name="attribute">
    <xsl:param name="name"/>
    <xsl:param name="value"/>
    <span class="attribute">
      <xsl:call-template name="name">
        <xsl:with-param name="name" select="$name"/>
      </xsl:call-template>
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
    <xsl:variable name="is-href" select="$name = 'href' or substring-after($name, ':') = 'href'"/>
    <xsl:variable name="is-src" select="$name = 'src' or substring-after($name, ':') = 'src'"/>
    <xsl:variable name="value-is-uri" select="starts-with($value, 'http://') or starts-with($value, 'https://')"/>
    <span class="value">
      <xsl:text>&quot;</xsl:text>
      <xsl:choose>
        <xsl:when test="$value and $is-href or $is-src or $value-is-uri">
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
    <xsl:call-template name="escape">
      <xsl:with-param name="text" select="$text"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="plain-text">
    <xsl:param name="text" select="."/>
    <xsl:param name="escape" select="true()"/>
    <span class="text">
      <xsl:choose>
        <xsl:when test="$escape">
          <xsl:call-template name="escape">
            <xsl:with-param name="text" select="$text"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$text"/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>

  <xsl:template name="plain-text-lines">
    <xsl:param name="text" select="."/>
    <xsl:param name="escape" select="true()"/>
    <div class="text">
      <xsl:call-template name="plain-text-line">
        <xsl:with-param name="text" select="$text"/>
        <xsl:with-param name="escape" select="$escape"/>
      </xsl:call-template>
    </div>
  </xsl:template>

  <xsl:template name="plain-text-line">
    <xsl:param name="text" select="."/>
    <xsl:param name="escape" select="true()"/>
    <xsl:variable name="crlf-position" select="string-length(substring-before($text, concat($cr, $lf)))"/>
    <xsl:variable name="lf-position" select="string-length(substring-before($text, $lf))"/>
    <xsl:variable name="cr-position" select="string-length(substring-before($text, $cr))"/>
    <xsl:variable name="first-newline">
      <xsl:choose>
        <xsl:when test="contains($text, concat($cr, $lf)) and (($lf-position = 0 and $cr-position = 0) or ($crlf-position &lt; $lf-position and $crlf-position &lt; $cr-position))">
          <xsl:value-of select="concat($cr, $lf)"/>
        </xsl:when>
        <xsl:when test="contains($text, $lf) and (($crlf-position = 0 and $cr-position = 0) or ($lf-position &lt; $crlf-position and $lf-position &lt; $cr-position))">
          <xsl:value-of select="$lf"/>
        </xsl:when>
        <xsl:when test="contains($text, $lf) and (($crlf-position = 0 and $lf-position = 0) or ($cr-position &lt; $crlf-position and $cr-position &lt; $lf-position))">
          <xsl:value-of select="$cr"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="before-first-newline">
      <xsl:choose>
        <xsl:when test="string-length($first-newline) &gt; 0">
          <xsl:value-of select="substring-before($text, $first-newline)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$text"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="after-first-newline">
      <xsl:if test="$before-first-newline != $text">
        <xsl:value-of select="substring-after($text, $first-newline)"/>
      </xsl:if>
    </xsl:variable>
    <div class="text-line">
      <xsl:choose>
        <xsl:when test="string-length($before-first-newline) &gt; 0">
          <xsl:call-template name="plain-text">
            <xsl:with-param name="text" select="$before-first-newline"/>
            <xsl:with-param name="escape" select="$escape"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>&#160;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </div>
    <xsl:if test="string-length($after-first-newline) &gt; 0">
      <xsl:call-template name="plain-text-line">
        <xsl:with-param name="text" select="$after-first-newline"/>
        <xsl:with-param name="escape" select="$escape"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="character-reference">
    <xsl:param name="text"/>
    <xsl:choose>
      <xsl:when test="contains($text, '&amp;')">
        <xsl:value-of select="substring-before($text, '&amp;')"/>
        <span class="character-reference">
          <xsl:text>&amp;</xsl:text>
          <xsl:value-of select="substring-before(substring-after($text, '&amp;'), ';')"/>
          <xsl:text>;</xsl:text>
        </span>
        <xsl:call-template name="character-reference">
          <xsl:with-param name="text" select="substring-after(substring-after($text, '&amp;'), ';')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="data-uri">
    <xsl:param name="content-type">text/plain</xsl:param>
    <xsl:param name="charset">UTF-8</xsl:param>
    <xsl:param name="text" select="''"/>
    <xsl:variable name="encoded-text">
      <xsl:call-template name="percent-encoding">
        <xsl:with-param name="text" select="$text"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="concat('data:', $content-type, ';charset=', $charset, ',', $encoded-text)"/>
  </xsl:template>

  <xsl:template name="escape">
    <xsl:param name="text"/>
    <xsl:variable name="escaped-text">
      <xsl:call-template name="replace-character">
        <xsl:with-param name="text">
          <xsl:call-template name="replace-character">
            <xsl:with-param name="text">
              <xsl:call-template name="replace-character">
                <xsl:with-param name="text">
                  <xsl:call-template name="replace-character">
                    <xsl:with-param name="text">
                      <xsl:call-template name="replace-character">
                        <xsl:with-param name="text" select="$text"/>
                        <xsl:with-param name="from" select="'&amp;'"/>
                        <xsl:with-param name="to" select="'&amp;amp;'"/>
                      </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="from" select="'&lt;'"/>
                    <xsl:with-param name="to" select="'&amp;lt;'"/>
                  </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="from" select="'&gt;'"/>
                <xsl:with-param name="to" select="'&amp;gt;'"/>
              </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="from" select="'&quot;'"/>
            <xsl:with-param name="to" select="'&amp;quot;'"/>
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="from" select="'&#160;'"/>
        <xsl:with-param name="to" select="'&amp;#160;'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="character-reference">
      <xsl:with-param name="text" select="$escaped-text"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="percent-encoding">
    <xsl:param name="text" select="''"/>
    <xsl:call-template name="replace-character">
      <xsl:with-param name="text">
        <xsl:call-template name="replace-character">
          <xsl:with-param name="text">
            <xsl:call-template name="replace-character">
              <xsl:with-param name="text">
                <xsl:call-template name="replace-character">
                  <xsl:with-param name="text">
                    <xsl:call-template name="replace-character">
                      <xsl:with-param name="text">
                        <xsl:call-template name="replace-character">
                          <xsl:with-param name="text">
                            <xsl:call-template name="replace-character">
                              <xsl:with-param name="text">
                                <xsl:call-template name="replace-character">
                                  <xsl:with-param name="text">
                                    <xsl:call-template name="replace-character">
                                      <xsl:with-param name="text">
                                        <xsl:call-template name="replace-character">
                                          <xsl:with-param name="text">
                                            <xsl:call-template name="replace-character">
                                              <xsl:with-param name="text" select="$text"/>
                                              <xsl:with-param name="from" select="'%'"/>
                                              <xsl:with-param name="to" select="'%25'"/>
                                            </xsl:call-template>
                                          </xsl:with-param>
                                          <xsl:with-param name="from" select="' '"/>
                                          <xsl:with-param name="to" select="'%20'"/>
                                        </xsl:call-template>
                                      </xsl:with-param>
                                      <xsl:with-param name="from" select="$lf"/>
                                      <xsl:with-param name="to" select="'%0A'"/>
                                    </xsl:call-template>
                                  </xsl:with-param>
                                  <xsl:with-param name="from" select="'&quot;'"/>
                                  <xsl:with-param name="to" select="'%22'"/>
                                </xsl:call-template>
                              </xsl:with-param>
                              <xsl:with-param name="from" select="'$'"/>
                              <xsl:with-param name="to" select="'%24'"/>
                            </xsl:call-template>
                          </xsl:with-param>
                          <xsl:with-param name="from" select="'@'"/>
                          <xsl:with-param name="to" select="'%40'"/>
                        </xsl:call-template>
                      </xsl:with-param>
                      <xsl:with-param name="from" select="'\'"/>
                      <xsl:with-param name="to" select="'%5C'"/>
                    </xsl:call-template>
                  </xsl:with-param>
                  <xsl:with-param name="from" select="':'"/>
                  <xsl:with-param name="to" select="'%3A'"/>
                </xsl:call-template>
              </xsl:with-param>
              <xsl:with-param name="from" select="';'"/>
              <xsl:with-param name="to" select="'%3B'"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="from" select="'}'"/>
          <xsl:with-param name="to" select="'%7D'"/>
        </xsl:call-template>
      </xsl:with-param>
      <xsl:with-param name="from" select="'{'"/>
      <xsl:with-param name="to" select="'%7B'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="replace-character">
    <xsl:param name="text"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:choose>
      <xsl:when test="contains($text, $from)">
        <xsl:value-of select="concat(substring-before($text, $from), $to)"/>
        <xsl:call-template name="replace-character">
          <xsl:with-param name="text" select="substring-after($text, $from)"/>
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$to"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="main.css">
    <xsl:variable name="layout.css">
      <xsl:call-template name="data-uri">
        <xsl:with-param name="content-type" select="'text/css'"/>
        <xsl:with-param name="text">
          <xsl:call-template name="layout.css"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="color.css">
      <xsl:call-template name="data-uri">
        <xsl:with-param name="content-type" select="'text/css'"/>
        <xsl:with-param name="text">
          <xsl:call-template name="color.css"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:text>@charset &quot;UTF-8&quot;;</xsl:text>
    <xsl:value-of select="concat($lf, $lf)"/>
    <xsl:value-of select="concat('@import &quot;', $layout.css, '&quot;;', $lf)"/>
    <xsl:value-of select="concat('@import &quot;', $color.css, '&quot;;', $lf)"/>
  </xsl:template>

  <xsl:template name="layout.css"><![CDATA[@charset "UTF-8";

/* layout */
* {
  margin: 0;
  padding: 0;
  color: inherit;
}

body {
  font-family: monospace;
  line-height: 1.5;
  margin: .5em;
}

ol {
  list-style: none;
}

ol ol {
  margin-left: 1em;
}

li {
  white-space: nowrap;
}

a {
  text-decoration: underline;
}

.text {
  white-space: pre;
}

li.closed > .tag {
  display: inline;
}

li.closed > .tag:first-child:not(:only-child)::after {
  content: "...";
}

li.closed > :not(.tag) {
  display: none;
}]]></xsl:template>

  <xsl:template name="color.css"><![CDATA[@charset "UTF-8";

/* color */
body {
  background-color: white;
}

.xml-declaration .name {
  color: aqua;
}

.processing-instruction .name {
  color: aqua;
}

.processing-instruction .string {
  color: maroon;
}

.tag .name span {
  color: blue;
}

.attribute .name span {
  color: maroon;
}

.attribute .value {
  color: green;
}

.section .name {
  color: blue;
}

.comment {
  color: silver;
}

.character-reference {
  color: lime;
}]]></xsl:template>

  <xsl:template name="site-script.js"><![CDATA[(function(global, undefined) {
  'use strict';

  var window = global.window || {};
  var document = window.document;

  function SiteScript() {
    this.tags = [];
  }

  (function(proto) {
    proto.handleEvent = function handleEvent(event) {
      var type = event.type;
      if (type === 'DOMContentLoaded') {
        return this.domContentLoaded(event);
      }
    };

    proto.domContentLoaded = function domContentLoaded(event) {
      var nodes = document.querySelectorAll('.tag:not(:only-child)');
      var tags = [].map.call(nodes, function(node) {
        return new Tag(node);
      });
      this.tags = this.tags.concat(tags);
    };
  })(SiteScript.prototype);

  function Tag(node) {
    if (!((this.node = node) instanceof HTMLElement && (this.parentNode = node.parentNode) instanceof HTMLElement)) {
      throw new TypeError('This class has argument should contains `HTMLElement` object.');
    }
    if (!((this.classList = this.node.classList) instanceof DOMTokenList && (this.parentClassList = this.parentNode.classList) instanceof DOMTokenList)) {
      throw new TypeError('Should support a `classList` property.');
    }
    if (!this.classList.contains('tag')) {
      throw new TypeError('Node is should has class attribute contains of value is tag.');
    }
    this.node.addEventListener('click', this, false);
  }

  Tag.CLOSED_STATE_CLASS_NAME = 'closed';

  (function(proto) {
    Object.defineProperty(proto, 'closed', {
      configurable: true,
      get: function() {
        return this.parentClassList.contains(Tag.CLOSED_STATE_CLASS_NAME);
      },
      enumerable: true,
      set: function(state) {
        return this[!state ? 'open' : 'close']();
      }
    });

    proto.handleEvent = function handleEvent(event) {
      var type = event.type;
      if (type === 'click') {
        this.toggle();
      }
    };

    proto.close = function toggle() {
      if (!this.closed) {
        this.parentClassList.add(Tag.CLOSED_STATE_CLASS_NAME);
      }
    };

    proto.open = function open() {
      if (this.closed) {
        this.parentClassList.remove(Tag.CLOSED_STATE_CLASS_NAME);
      }
    };

    proto.toggle = function toggle() {
      this.parentClassList.toggle(Tag.CLOSED_STATE_CLASS_NAME);
    };
  })(Tag.prototype);

  function main() {
    window.addEventListener('DOMContentLoaded', new SiteScript(), false);
  }

  if (window === global) {
    main();
  }
})(this);]]></xsl:template>
</xsl:stylesheet>

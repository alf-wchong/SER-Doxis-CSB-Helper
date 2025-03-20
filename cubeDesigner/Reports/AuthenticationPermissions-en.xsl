<?xml version='1.0' encoding='utf-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/TR/REC-html40" version="1.0">
    <xsl:output method="html" encoding="UTF-8" indent="no"/>

    <xsl:template match="/">
        <html xmlns="http://www.w3.org/TR/REC-html40">
            <head>
                <title>DOXiS4 cubeDesigner Report</title>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></meta>
            </head>

            <body>
                <h1><xsl:value-of select="Report/@Type"/></h1>
                <strong>(<xsl:value-of select="Report/@Description"/>)</strong>

                <p>
                    <strong>Creation date / time</strong>:
                    <xsl:value-of select="substring-before(Report/@Date,'T')"/>
                    <xsl:text> / </xsl:text>
                    <xsl:value-of select="substring-after(Report/@Date,'T')"/>
                </p>

                <h2 style="color: cornflowerblue">Server</h2>
                <table borderColor="#a9a9a9" border="1" style="; border-collapse: collapse">
                    <tbody>
                        <xsl:choose>
                            <xsl:when test="/Report/Server/@CSBServerURL">
                                <tr>
                                    <td>
                                        <strong>URL</strong>
                                    </td>
                                    <td>
                                        <xsl:value-of select="/Report/Server/@CSBServerURL"/>
                                    </td>
                                </tr>
                            </xsl:when>
                            <xsl:otherwise>
                                <tr>
                                    <td>
                                        <strong>Archive Hostname</strong>
                                    </td>
                                    <td>
                                        <xsl:value-of select="/Report/Server/@ArchiveAddress"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>Archive Port Number</strong>
                                    </td>
                                    <td>
                                        <xsl:value-of select="/Report/Server/@ArchivePort"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>SERaTIO Hostname</strong>
                                    </td>
                                    <td>
                                        <xsl:value-of select="/Report/Server/@SeratioAddress"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>SERaTIO Port Number</strong>
                                    </td>
                                    <td>
                                        <xsl:value-of select="/Report/Server/@SeratioPort"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>Tenant</strong>
                                    </td>
                                    <td>
                                        <xsl:value-of select="/Report/Server/@System"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>Tenant ID</strong>
                                    </td>
                                    <td>
                                        <xsl:value-of select="/Report/Server/@GUID"/>
                                    </td>
                                </tr>
                            </xsl:otherwise>
                        </xsl:choose>
                    </tbody>
                </table>
                <h2 style="color: cornflowerblue">Rights Recipient</h2>
                <p>The rights of the following recipient were queried:</p>

                <p>
                    <strong>
                        <xsl:if test="Report/Person/@ID!=''">
                            <xsl:text>Person: </xsl:text>
                            <xsl:value-of select="Report/Person/@Name"/>
                            <xsl:text> - </xsl:text>
                            <xsl:value-of select="Report/Person/@ID"/>
                            <br/>
                        </xsl:if>
                        <xsl:if test="Report/Role/@ID!=''">
                            <xsl:text>Role: </xsl:text>
                            <xsl:value-of select="Report/Role/@Name"/>
                            <xsl:text> - </xsl:text>
                            <xsl:value-of select="Report/Role/@ID"/>
                            <br/>
                        </xsl:if>
                        <xsl:if test="Report/Unit/@ID!=''">
                            <xsl:text>Unit: </xsl:text>
                            <xsl:value-of select="Report/Unit/@Name"/>
                            <xsl:text> - </xsl:text>
                            <xsl:value-of select="Report/Unit/@ID"/>
                            <br/>
                        </xsl:if>
                    </strong>
                </p>

                <xsl:if test="Report/Authentication/AccessIdentifier/@GUID!=''">
                    <p>The following variants of rights assignment were considered for this recipient:</p>
                    <ul>
                        <xsl:for-each select="Report/Authentication/AccessIdentifier">
                            <li>
                                <xsl:value-of select="@Name"/>
                                <xsl:text> - </xsl:text>
                                <xsl:choose>
                                    <xsl:when test="@Type='Role'">
                                        <xsl:text>Role</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="@Type='Unit'">
                                        <xsl:text>Unit</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="@Type='Administrator'">
                                        <xsl:text>Administrator</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="@Type='Generic'">
                                        <xsl:text>Generic</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="@Type='Person'">
                                        <xsl:text>Person</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="@Type='Group'">
                                        <xsl:text>Group</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Type unknown</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="@GUID"/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>

                <h2 style="color: cornflowerblue">Classes</h2>
                <p>The rights overview is structured into classes as follows:</p>
                <ul>
                    <xsl:for-each select="Report/SecurityClass">
                        <xsl:sort select="./@Alias"/>
                        <li>
                            <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat('#',./@Alias)"/></xsl:attribute>
                                <xsl:value-of select="./@Alias"/>
                            </xsl:element>
                        </li>
                    </xsl:for-each>
                </ul>

                <p><strong>Note</strong>: If you follow the hyperlink to a class, you will find an object overview with hyperlinks at the beginning of the corresponding section.</p>
                <xsl:for-each select="Report/SecurityClass">
                    <xsl:sort select="./@Alias"/>

                    <h2 style="color: cornflowerblue">
                        <xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="./@Alias"/></xsl:attribute>
                            <xsl:text>Class "</xsl:text>
                            <xsl:value-of select="./@Alias"/>
                            <xsl:text>"</xsl:text>
                        </xsl:element>
                    </h2>

                    <p>This class contains the following objects:</p>

                    <ul>
                        <xsl:for-each select="Object">
                            <xsl:sort select="./@Alias"/>
                            <li>
                                <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat('#OBJ_',../@Name,'_',./@Name)"/></xsl:attribute>
                                    <xsl:value-of select="./@Alias"/>
                                </xsl:element>
                            </li>

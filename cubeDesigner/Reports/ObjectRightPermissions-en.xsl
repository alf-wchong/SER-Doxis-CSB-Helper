<?xml version='1.0' encoding='utf-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/TR/REC-html40" version="1.0">
    <xsl:output method="html" encoding="UTF-8" indent="no"/>

    <xsl:template match="/">

        <html>
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

                <h2 style="color: cornflowerblue">Object</h2>
                <ul>
                    <li>
                        <strong>Class: </strong>
                        <xsl:value-of select="Report/SecurityClass/@Alias"/>
                    </li>
                    <li>
                        <strong>Object: </strong>
                        <xsl:value-of select="Report/SecurityClass/Object/@Alias"/>
                    </li>
                    <li>
                        <strong>Owner: </strong>
                        <xsl:value-of select="Report/SecurityClass/Object/@OwnerType"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="Report/SecurityClass/Object/@OwnerID"/>
                        <xsl:text> - </xsl:text>
                        <xsl:value-of select="Report/SecurityClass/Object/@OwnerName"/>
                        <strong> - Namespace:Name: </strong>
                        <xsl:value-of select="@NamespaceWithName"/>
                        <strong> - Namespace ID: </strong> 
                        <xsl:value-of select="@NamespaceGUID"/>
                    </li>
                </ul>

                <h2 style="color: cornflowerblue">Rights</h2>
                <p>The following rights were evaluated:</p>
                <ul>
                    <xsl:for-each select="Report/SecurityClass/Object/Right">
                        <xsl:sort select="./@Alias"/>
                        <li>
                            <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat('#',./@ID)"/></xsl:attribute>
                                <xsl:value-of select="@Alias"/>
                                <xsl:text> - </xsl:text>
                                <xsl:choose>
                                    <xsl:when test="@Type='Allow'">
                                        <xsl:text>Allow</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="@Type='Deny'">
                                        <xsl:text>Deny</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="@Type='Delegate'">
                                        <xsl:text>Delegate</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Type unknown or undefined</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                        </li>
                    </xsl:for-each>
                </ul>


                <xsl:for-each select="Report/SecurityClass/Object/Right">
                    <xsl:sort select="./@Alias"/>
                    <h3 style="color:darkgray">
                        <xsl:element name="a"><xsl:attribute name="name">
                            <xsl:value-of select="./@ID"/>
                        </xsl:attribute></xsl:element>
                        <xsl:value-of select="@Alias"/>
                        <xsl:text> - </xsl:text>
                        <xsl:choose>
                            <xsl:when test="@Type='Allow'">
                                <xsl:text>Allow</xsl:text>
                            </xsl:when>
                            <xsl:when test="@Type='Deny'">
                                <xsl:text>Deny</xsl:text>
                            </xsl:when>
                            <xsl:when test="@Type='Delegate'">
                                <xsl:text>Delegate</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>Type unknown or undefined</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </h3>
                    <p>The following list shows which persons can exercise this right and how they must be logged in.</p>
                    <ul>
                        <xsl:for-each select="Authentications">
                            <xsl:sort select="./@Name"/>
                            <li>
                                <strong>
                                    <xsl:text>Person: </xsl:text>
                                    <xsl:value-of select="@Name"/>
                                    <xsl:text> - </xsl:text>
                                    <xsl:value-of select="@PersonID"/>
                                </strong>
                                <ul>
                                    <xsl:for-each select="Authentication">
                                        <xsl:sort select="./Role/@Name"/>
                                        <li>
                                            <xsl:choose>
                                                <xsl:when test="./Role/@ID!=''">
                                                    <xsl:text>Role: </xsl:text>
                                                    <xsl:value-of select="./Role/@Name"/>
                                                    <xsl:text> - </xsl:text>
                                                    <xsl:value-of select="./Role/@ID"/>
                                                    <xsl:text> / Unit: </xsl:text>
                                                    <xsl:value-of select="./Unit/@Name"/>
                                                    <xsl:text> - </xsl:text>
                                                    <xsl:value-of select="./Unit/@ID"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:text>Login without Role/Unit</xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </li>
                                    </xsl:for-each>
                                </ul>

                            </li>
                        </xsl:for-each>
                    </ul>

                </xsl:for-each>

            </body>
        </html>

    </xsl:template>
</xsl:stylesheet>

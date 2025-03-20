<?xml version='1.0' encoding='utf-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/TR/REC-html40" version="1.0">
<xsl:output method="html" encoding="UTF-8" indent="no"/>

<xsl:template match="/">
<html xmlns="http://www.w3.org/TR/REC-html40">
	<head>
	   	<title>Doxis cubeDesigner Report</title>
    	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></meta>
    </head>

	<body>
            	<h1><xsl:value-of select="Report/@Type"/></h1>
		<strong>(<xsl:value-of select="Report/@Description"/>)</strong>

		<p>
			<strong>Creation Date / Time</strong>: 
			<xsl:value-of select="substring-before(Report/@Date,'T')"/>
			<xsl:text> / </xsl:text>
			<xsl:value-of select="substring-after(Report/@Date,'T')"/>
		</p>

		<!-- Table with server properties -->
		<p><strong>Server:</strong></p>
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
		
		<h2 style="color: cornflowerblue">Contents</h2>
		<p>The rights overview is structured into the following classes:</p>
		<ul>
			<xsl:for-each select="Report/SecurityClass">
			<xsl:sort select="./@Alias"/>
			<li>
				<xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat('#',./@Name)"/></xsl:attribute>
					<xsl:value-of select="./@Alias"/>
				</xsl:element>
			</li>
			</xsl:for-each>
		</ul>
		
		<p><strong>Note:</strong> If you follow the hyperlink to a class, you will find an object overview with hyperlinks at the beginning of the corresponding section.</p>
		<xsl:for-each select="Report/SecurityClass">
			<xsl:sort select="./@Alias"/>
			
			<h2 style="color: cornflowerblue">
				<xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="./@Name"/></xsl:attribute>
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
						<xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat('#OBJ_',./@ID,'_',../@Name)"/></xsl:attribute>
							<xsl:value-of select="./@Alias"/>
						</xsl:element>
					</li>
				</xsl:for-each>
			</ul>			
			
			<xsl:for-each select="Object">
				<xsl:sort select="@Alias"/>
				<h3 style="color: orange">
					<xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="concat('OBJ_',./@ID,'_',../@Name)"/></xsl:attribute>
						<xsl:text>Object "</xsl:text>
						<xsl:value-of select="./@Alias"/>
						<xsl:text>" in Class "</xsl:text>
						<xsl:value-of select="../@Alias"/>
						<xsl:text>"</xsl:text>
					</xsl:element>
				</h3>
				<p>
					<strong>Object ID: </strong>
					<xsl:value-of select="@ID"/>
					<xsl:text> - </xsl:text>
					<strong>Owner: </strong> 
					<xsl:choose>
						<xsl:when test="@OwnerName!=''">
							<xsl:value-of select="@OwnerName"/>
						</xsl:when>						
						<xsl:otherwise>
							<xsl:text>not defined</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="@OwnerType='Role'">
							<xsl:text> - Role</xsl:text>
						</xsl:when>
						<xsl:when test="@OwnerType='Unit'">
							<xsl:text> - Unit</xsl:text>
						</xsl:when>
						<xsl:when test="@OwnerType='Person'">
							<xsl:text> - Person</xsl:text>
						</xsl:when>
						<xsl:when test="@OwnerType='Group'">
							<xsl:text> - Group</xsl:text>
						</xsl:when>						
					</xsl:choose>
					<xsl:if test="@OwnerID!=''">
						<xsl:text> </xsl:text>
						<xsl:value-of select="@OwnerID"/>
					</xsl:if>
          <strong> - Namespace: </strong>
          <xsl:value-of select="@NamespaceWithName"/>
          <strong> - Namespace ID: </strong>
          <xsl:value-of select="@NamespaceGUID"/>
        </p>

        <p>This object has the following rights holders:</p>

        <ul>
            <xsl:for-each select="AccessIdentifier">
                <xsl:sort select="./@Alias"/>
                <li>
                    <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat('#ACC_',../../@Name,'_',../@ID,'_',./@Name)"/></xsl:attribute>
                        <xsl:value-of select="./@Alias"/>
					    <xsl:choose>
							<xsl:when test="@Type='Role'">
								<xsl:text> - Role </xsl:text>
							</xsl:when>
							<xsl:when test="@Type='Unit'">
								<xsl:text> - Unit </xsl:text>
							</xsl:when>
							<xsl:when test="@Type='Person'">
								<xsl:text> - Person </xsl:text>
							</xsl:when>
							<xsl:when test="@Type='Group'">
								<xsl:text> - Group </xsl:text>
							</xsl:when>
							<xsl:when test="@Type='Generic'">
								<xsl:text> - Generic </xsl:text>
							</xsl:when>						
							<xsl:otherwise>
								<xsl:text> - Type not defined </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:value-of select="./@ID"/>
                    </xsl:element>
                </li>
            </xsl:for-each>
        </ul>			

				<xsl:for-each select="AccessIdentifier">
					<xsl:sort select="./@Alias"/>
					<xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="concat('ACC_',../../@Name,'_',../@ID,'_',./@Name)"/></xsl:attribute>
					<h4 style="color:darkgray">Rights Holder: 
						<xsl:value-of select="./@Alias"/>
						<xsl:choose>
							<xsl:when test="@Type='Role'">
								<xsl:text> - Role </xsl:text>
							</xsl:when>
							<xsl:when test="@Type='Unit'">
								<xsl:text> - Unit </xsl:text>
							</xsl:when>
							<xsl:when test="@Type='Person'">
								<xsl:text> - Person </xsl:text>
							</xsl:when>
							<xsl:when test="@Type='Group'">
								<xsl:text> - Group </xsl:text>
							</xsl:when>
							<xsl:when test="@Type='Generic'">
								<xsl:text> - Generic </xsl:text>
							</xsl:when>						
							<xsl:otherwise>
								<xsl:text> - Type not defined </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:value-of select="./@ID"/>
					</h4>
					</xsl:element>
					<table borderColor="#a9a9a9" border="1" style="; border-collapse: collapse" cellpadding="2">
						<tbody>
							<tr><th align="left">Right</th><th align="left">Allow</th><th align="left">Deny</th><th align="left">Delegate</th></tr>
								<xsl:for-each select="Right/@ID">
									<tr>
										<td>
											<xsl:value-of select="../@Alias"/>
										</td>
										<td>
											<xsl:value-of select="../@Allow"/>
										</td>
										<td>
											<xsl:value-of select="../@Deny"/>
										</td>
										<td>
											<xsl:value-of select="../@Delegate"/>
										</td>
									</tr>
								</xsl:for-each>
						</tbody>
					</table>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:for-each>

	</body>
</html>	
</xsl:template>

</xsl:stylesheet>

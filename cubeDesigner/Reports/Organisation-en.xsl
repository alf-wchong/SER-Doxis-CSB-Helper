<?xml version='1.0' encoding='utf-8'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/TR/REC-html40" version="1.0">
<xsl:output method="html" encoding="UTF-8" indent="no"/>
<xsl:key name="PersonID" match="/Report/Persons/Person" use="@ID"/>
<xsl:key name="GroupID" match="/Report/Groups/Group" use="@ID"/>
<xsl:key name="UnitID" match="/Report/Units/Unit" use="@ID"/>

<xsl:template match="/">
    <html xmlns="http://www.w3.org/TR/REC-html40"><head>
            <title>Doxis cubeDesigner Report</title>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"></meta>
    </head>
        <body>
            <p><!-- Report Header -->
                    <h1><xsl:value-of select="Report/@Type"/></h1>
                <strong>(<xsl:value-of select="Report/@Description"/>)</strong>

                <p>
                    <strong>Creation date / time</strong>: 
                    <xsl:value-of select="substring-before(Report/@Date,'T')"/>
                    <xsl:text> / </xsl:text>
                    <xsl:value-of select="substring-after(Report/@Date,'T')"/>
                </p><!-- Table of Contents -->
                <h2 style="color: cornflowerblue">Contents</h2>
                <p/>
                <ul>
                    <li><a href="#Server">Server</a></li>
                    <li><a href="#Organigramm">Organization Chart</a></li>
                    <li>
                        <a href="#Gruppenmitglieder">Group Members</a>
                    </li>
                    <li>
                        <a href="#Einheiten">Units</a>
                    </li>
                    <li><a href="#Rollen">Roles</a></li>
                    <li>
                        <a href="#Gruppen">Groups</a>
                    </li>
                    <li><a href="#Personen">Persons</a></li>
                    <ul>
                        <li><a href="#Personen_Allg">General Properties</a></li>
                        <li><a href="#PW_Regel">Standard Password Rules</a></li>
                        <li><a href="#Personen_PW">Password Properties</a></li>
                    </ul>
                </ul>
                
                <!-- Table with server properties -->
                <h2 style="color: cornflowerblue">
                    <xsl:element name="a"><xsl:attribute name="name">Server</xsl:attribute></xsl:element>Server
                </h2>
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
                                        <strong>Client</strong>
                                    </td>
                                    <td>
                                        <xsl:value-of select="/Report/Server/@System"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <strong>Client ID</strong>
                                    </td>
                                    <td>
                                        <xsl:value-of select="/Report/Server/@GUID"/>
                                    </td>
                                </tr>
                            </xsl:otherwise>
                        </xsl:choose>
                    </tbody>
                </table>
                <!-- Organization Chart -->
                <h2 style="color: cornflowerblue">
                    <xsl:element name="a"><xsl:attribute name="name">Organigramm</xsl:attribute></xsl:element>Organization Chart
                </h2>
                <xsl:apply-templates select="/Report/Organisation" mode="render"/>
                <!-- the remaining code for the organization chart is at the end of the stylesheet -->
                <!-- Group Members -->
                <h2 style="color: cornflowerblue">
                    <xsl:element name="a">
                        <xsl:attribute name="name">Gruppenmitglieder</xsl:attribute>
                    </xsl:element>Group Members
                </h2>
                <xsl:apply-templates select="/Report/GroupOrganisation" mode="render2"/>
                <!-- the remaining code for the group members is at the end of the stylesheet -->
                <!-- Table with units -->
                <h2 style="color: cornflowerblue">
                    <xsl:element name="a"><xsl:attribute name="name">Einheiten</xsl:attribute></xsl:element>Units
                </h2>
                <table borderColor="#a9a9a9" border="1" style="; border-collapse: collapse">
                    <tbody>
                        <tr>
                            <th align="left">ID</th>
                            <th align="left">Name (sorted)</th>
                            <th align="left">Description</th>
                            <th align="left">Rights</th>
                            <th align="left">Owner</th>
                            <th align="left">Manager</th>
                            <th align="left">Workbasket</th>
                            <th align="left">Orga Transmitter ID</th>
                        </tr>
                        <xsl:for-each select="Report/Units/Unit">
                            <xsl:sort select="@Name"/>
                            <tr>
                                <td><!-- Bookmark for entries in the units table -->
                                    <xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="concat(@ID,'_UN')"/></xsl:attribute>
                                        <xsl:value-of select="@ID"/>
                                    </xsl:element>
                                </td>
                                <td>
                                    <xsl:value-of select="@Name"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@Description"/>
                                </td>
                                <xsl:choose>
                                    <xsl:when test="@HasInstanceRights=1">
                                        <td>True</td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td>False</td>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <td>
                                    <xsl:value-of select="key('PersonID',@OwnerGUID)/@Name"/>
                                </td>
                                <td>
                                    <xsl:value-of select="key('PersonID',@ManagerGUID)/@Name"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@WorkbasketGUID"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@OrgaTransmitterID"/>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>
                <!-- Table with roles -->
                <h2 style="color: cornflowerblue">
                    <xsl:element name="a"><xsl:attribute name="name">Rollen</xsl:attribute></xsl:element>Roles
                </h2>
                <table borderColor="#a9a9a9" border="1" style="; border-collapse: collapse">
                    <tbody>
                        <tr>
                            <th align="left">ID</th>
                            <th align="left">Name (sorted)</th>
                            <th align="left">in Unit</th>
                            <th align="left">Description</th>
                            <th align="left">Rights</th>
                            <th align="left">Owner</th>
                            <th align="left">Position</th>
                            <th align="left">Workbasket</th>
                            <th align="left">Orga Transmitter ID</th>
                        </tr>
                        <xsl:for-each select="Report/Roles/Role">
                            <xsl:sort select="@Name"/>
                            <tr>
                                <td><!-- Bookmark for entries in the roles table -->
                                    <xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="concat(@ID,'_RL')"/></xsl:attribute>
                                        <xsl:value-of select="@ID"/>
                                    </xsl:element>
                                </td>
                                <td>
                                    <xsl:value-of select="@Name"/>
                                </td>
                                <td>
                                    <xsl:variable name="RoleSearch" select="@Name" />
                                    <xsl:for-each select="//RoleRef">
                                        <xsl:if test="./@Name=$RoleSearch">
                                            <xsl:value-of select="../@Name" />
                                            <xsl:text> </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                </td>
                                <td>
                                    <xsl:value-of select="@Description"/>
                                </td>
                                <xsl:choose>
                                    <xsl:when test="@HasInstanceRights=1">
                                        <td>True</td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td>False</td>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <td>
                                    <xsl:value-of select="key('PersonID',@OwnerGUID)/@Name"/>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="contains(@Position,'Employee')">
                                            <xsl:text>Employee</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@Position,'Manager')">
                                            <xsl:text>Manager</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@Position,'Administrator')">
                                            <xsl:text>Administrator</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@Position"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td>
                                    <xsl:value-of select="@WorkbasketGUID"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@OrgaTransmitterID"/>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>
                <!-- Table with groups -->
                <h2 style="color: cornflowerblue">
                    <xsl:element name="a">
                        <xsl:attribute name="name">Gruppen</xsl:attribute>
                    </xsl:element>Groups
                </h2>
                <table borderColor="#a9a9a9" border="1" style="; border-collapse: collapse">
                    <tbody>
                        <tr>
                            <th align="left">ID</th>
                            <th align="left">Name (sorted)</th>
                            <th align="left">Type</th>
                            <th align="left">Description</th>
                            <th align="left">Rights</th>
                            <th align="left">Owner</th>
                            <th align="left">Manager</th>
                            <th align="left">Workbasket</th>
                            <th align="left">Orga Transmitter ID</th>
                        </tr>
                        <xsl:for-each select="Report/Groups/Group">
                            <xsl:sort select="@Name"/>
                            <tr>
                                <td>
                                    <!-- Bookmark for entries in the groups table -->
                                    <xsl:element name="a">
                                        <xsl:attribute name="name">
                                            <xsl:value-of select="concat(@ID,'_GR')"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="@ID"/>
                                    </xsl:element>
                                </td>
                                <td>
                                    <xsl:value-of select="@Name"/>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="contains(@Type,'Group')">
                                            <xsl:text>Group</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@Type,'Combination')">
                                            <xsl:text>Combination</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@Type"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td>
                                    <xsl:value-of select="@Description"/>
                                </td>
                                <xsl:choose>
                                    <xsl:when test="@HasInstanceRights=1">
                                        <td>True</td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td>False</td>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <td>
                                    <xsl:value-of select="key('PersonID',@OwnerGUID)/@Name"/>
                                </td>
                                <td>
                                    <xsl:value-of select="key('PersonID',@ManagerGUID)/@Name"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@WorkbasketGUID"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@OrgaTransmitterID"/>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table><!-- Persons section -->
                <h2 style="color: cornflowerblue">
                    <xsl:element name="a"><xsl:attribute name="name">Personen</xsl:attribute></xsl:element>Persons
                </h2><!-- Table General Properties -->
                <h3 style="color: orange">
                    <xsl:element name="a"><xsl:attribute name="name">Personen_Allg</xsl:attribute></xsl:element>General Properties
                </h3>
                <table borderColor="#a9a9a9" border="1" style="; border-collapse: collapse">
                    <tbody>
                        <tr>
                            <th align="left">ID</th>
                            <th align="left">Login Name (sorted)</th>
                            <th align="left">First Name</th>
                            <th align="left">Last Name</th>
                            <th align="left">Description</th>
                            <th align="left">Phone Number</th>
                            <th align="left">Position</th>
                            <th align="left">Owner</th>
                            <th align="left">Primary Unit or Group</th>
                            <th align="left">Authentication</th>
                            <th align="left">License Check</th>
                            <th align="left">Email</th>
                            <th align="left">Language</th>
                            <th align="left">Default Load Profile</th>
                            <th align="left">Default Save Profile</th>
                            <th align="left">Can act as</th>
                            <th align="left">Last Login</th>
                            <th align="left">Password Properties</th>
                        </tr>
                        <xsl:for-each select="Report/Persons/Person">
                            <xsl:sort select="@Name"/>
                            <tr>
                                <td><!-- Bookmark for entries in the persons table (general properties) -->
                                    <xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="concat(@ID,'_PE')"/></xsl:attribute>
                                        <xsl:value-of select="@ID"/>
                                    </xsl:element>
                                </td>
                                <td>
                                    <xsl:value-of select="@Name"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@Forename"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@Lastname"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@Description"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@PhoneNumber"/>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="contains(@Position,'Employee')">
                                            <xsl:text>Employee</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@Position,'Manager')">
                                            <xsl:text>Manager</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@Position,'Administrator')">
                                            <xsl:text>Administrator</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@Position"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td>
                                    <xsl:value-of select="key('PersonID',@OwnerGUID)/@Name"/>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="string-length(@PrimaryGroupGUID)>0">
                                            <xsl:value-of select="key('GroupID',@PrimaryGroupGUID)/@Name"/>
                                        </xsl:when>
                                        <xsl:when test="string-length(@PrimaryUnitGUID)>0">
                                            <xsl:value-of select="key('UnitID',@PrimaryUnitGUID)/@Name"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="contains(@AuthenticationMode,'Use default')">
                                            <xsl:text>Default</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@AuthenticationMode,'Kerberos')">
                                            <xsl:text>Access Token</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@AuthenticationMode,'KerberosOrPassword')">
                                            <xsl:text>Password or Access Token</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@AuthenticationMode,'Password')">
                                            <xsl:text>Password</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@AuthenticationMode,'External')">
                                            <xsl:text>Custom</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@AuthenticationMode,'ExternalOrPassword')">
                                            <xsl:text>Custom or Password</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@AuthenticationMode,'ExternalOrKerberosOrPassword')">
                                            <xsl:text>Custom, Access Token or Password</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@AuthenticationMode"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="contains(@LicenseType,'Normal')">
                                            <xsl:text>Concurrent Logins</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@LicenseType,'Named')">
                                            <xsl:text>Personal Licenses</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@LicenseType,'Technical')">
                                            <xsl:text>Technical Licenses</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@LicenseType,'Lightweight')">
                                            <xsl:text>Casual Users</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@LicenseType"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <td>
                                    <xsl:value-of select="@MailAddress"/>
                                </td>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="@DefaultLangID!='0'">
                                            <xsl:value-of select="@DefaultLangID"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </td>
                                <td>
                                    <xsl:value-of select="@DefaultRetrievalProfileGUID"/>
                                </td>
                                <td>
                                    <xsl:value-of select="@DefaultStorageProfileGUID"/>
                                </td>
                                <td>
                                    <xsl:for-each select="CanActAsUser/GUID">
                                        <xsl:value-of select="key('PersonID',.)/@Name"/>
                                        <xsl:text> </xsl:text>
                                    </xsl:for-each>
                                    <xsl:for-each select="CanActAsUnitMembers/GUID">
                                        <xsl:value-of select="key('UnitID',.)/@Name"/>
                                        <xsl:text> </xsl:text>
                                    </xsl:for-each>
                                    <xsl:for-each select="CanActAsGroupMembers/GUID">
                                        <xsl:value-of select="key('GroupID',.)/@Name"/>
                                        <xsl:text> </xsl:text>
                                    </xsl:for-each>
                                </td>
                                <td>
                                    <xsl:value-of select="@LastLoginTime"/>
                                </td>
                                <td><!-- Hyperlink to password table -->
                                    <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat('#',@ID,'_PW')"/></xsl:attribute>click here</xsl:element>
                                </td>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table><!-- Password Rules -->
                <h3 style="color: orange">
                    <xsl:element name="a"><xsl:attribute name="name">PW_Regel</xsl:attribute></xsl:element>Standard Password Rules
                </h3>
                <table borderColor="#a9a9a9" border="1" style="; border-collapse: collapse">
                    <tbody>
                        <tr>
                            <td>
                                <strong>Password Format</strong>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="/Report/DefaultSettings/@PasswordFormat=''">
                                        Not set                                        
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="/Report/DefaultSettings/@PasswordFormat"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <strong>Password Length</strong>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="/Report/DefaultSettings/@MinPasswordLength=0">Not set</xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="/Report/DefaultSettings/@MinPasswordLength"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <strong>Maximum Number of Rejected Logins</strong>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="/Report/DefaultSettings/@MaxLoginAttempts=0">Unlimited</xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="/Report/DefaultSettings/@MaxLoginAttempts"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <strong>Deactivation Rule</strong>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="/Report/DefaultSettings/@MaxInactivity='0'">
                                        Never deactivated
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <xsl:when test="contains(/Report/DefaultSettings/@MaxInactivityUnit,'Day')">
                                                <xsl:value-of select="concat(/Report/DefaultSettings/@MaxInactivity,' Day(s)')"/>
                                            </xsl:when>
                                            <xsl:when test="contains(/Report/DefaultSettings/@MaxInactivityUnit,'Month')">
                                                <xsl:value-of select="concat(/Report/DefaultSettings/@MaxInactivity,' Month(s)')"/>
                                            </xsl:when>
                                            <xsl:when test="contains(/Report/DefaultSettings/@MaxInactivityUnit,'Year')">
                                                <xsl:value-of select="concat(/Report/DefaultSettings/@MaxInactivity,' Year(s)')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="concat(/Report/DefaultSettings/@MaxInactivity,' ',/Report/DefaultSettings/@MaxInactivityUnit)"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <strong>Expiration Rule</strong>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="/Report/DefaultSettings/@PasswordExpireRule='Never expires'">Never expires</xsl:when>
                                    <xsl:when test="/Report/DefaultSettings/@PasswordExpireRule='Expires on unit count'">
                                        <xsl:choose>
                                            <xsl:when test="contains(/Report/DefaultSettings/@PasswordExpireUnit,'Day')">
                                                Expires in <xsl:value-of select="concat(/Report/DefaultSettings/@PasswordExpireCount,' Day(s)')"/>
                                            </xsl:when>
                                            <xsl:when test="contains(/Report/DefaultSettings/@PasswordExpireUnit,'Month')">
                                                Expires in <xsl:value-of select="concat(/Report/DefaultSettings/@PasswordExpireCount,' Month(s)')"/>
                                            </xsl:when>
                                            <xsl:when test="contains(/Report/DefaultSettings/@PasswordExpireUnit,'Year')">
                                                Expires in <xsl:value-of select="concat(/Report/DefaultSettings/@PasswordExpireCount,' Year(s)')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                Please check stylesheet
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                </xsl:choose>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <strong>Maximum Number of Password History Entries</strong>
                            </td>
                            <td>
                                <xsl:value-of select="/Report/DefaultSettings/@MaxPasswordHistoryEntries"/>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <strong>User Can Change Password</strong>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="Report/DefaultSettings/@AllowChangePassword=0">
                                        False
                                    </xsl:when>
                                    <xsl:when test="Report/DefaultSettings/@AllowChangePassword=1">True</xsl:when>
                                </xsl:choose>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <strong>Lifetime</strong>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="/Report/DefaultSettings/@LifeSpan='0'">
                                        Never expires
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <xsl:when test="contains(/Report/DefaultSettings/@LifeSpanUnit,'Day')">
                                                <xsl:value-of select="concat(/Report/DefaultSettings/@LifeSpan,' Day(s)')"/>
                                            </xsl:when>
                                            <xsl:when test="contains(/Report/DefaultSettings/@LifeSpanUnit,'Month')">
                                                <xsl:value-of select="concat(/Report/DefaultSettings/@LifeSpan,' Month(s)')"/>
                                            </xsl:when>
                                            <xsl:when test="contains(/Report/DefaultSettings/@LifeSpanUnit,'Year')">
                                                <xsl:value-of select="concat(/Report/DefaultSettings/@LifeSpan,' Year(s)')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="concat(/Report/DefaultSettings/@LifeSpan,' ',/Report/DefaultSettings/@LifeSpanUnit)"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <strong>Authentication</strong>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="contains(/Report/DefaultSettings/@AuthenticationMode,'Kerberos')">
                                        <xsl:text>Access Token</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(/Report/DefaultSettings/@AuthenticationMode,'KerberosOrPassword')">
                                        <xsl:text>Password or Access Token</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(/Report/DefaultSettings/@AuthenticationMode,'Password')">
                                        <xsl:text>Password</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(/Report/DefaultSettings/@AuthenticationMode,'External')">
                                        <xsl:text>Custom</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(/Report/DefaultSettings/@AuthenticationMode,'ExternalOrPassword')">
                                        <xsl:text>Custom or Password</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(/Report/DefaultSettings/@AuthenticationMode,'ExternalOrKerberosOrPassword')">
                                        <xsl:text>Custom, Access Token or Password</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="/Report/DefaultSettings/@AuthenticationMode"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <strong>Default Workbasket Permissions</strong>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="contains(/Report/DefaultSettings/@DefaultWorkbasketAutoAccessibility,'None')">
                                        <xsl:text>None</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(/Report/DefaultSettings/@DefaultWorkbasketAutoAccessibility,'Manager')">
                                        <xsl:text>Manager</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(/Report/DefaultSettings/@DefaultWorkbasketAutoAccessibility,'PrimaryGroup')">
                                        <xsl:text>Primary Group or Unit</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(/Report/DefaultSettings/@DefaultWorkbasketAutoAccessibility,'ManagerAndPrimaryGroup')">
                                        <xsl:text>Manager and Primary Group or Unit</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="/Report/DefaultSettings/@DefaultWorkbasketAutoAccessibility"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                    </tbody>
                </table><!-- Password Properties Table -->
                <h3 style="color: orange">
                    <xsl:element name="a"><xsl:attribute name="name">Personen_PW</xsl:attribute></xsl:element>Password Properties
                </h3>
                <table borderColor="#a9a9a9" border="1" style="; border-collapse: collapse">
                    <tbody>
                        <tr>
                            <th align="left">ID</th>
                            <th align="left">Login Name (sorted)</th>
                            <th align="left">Can Change Password</th>
                            <th align="left">Must Change Password</th>
                            <th align="left">Password Expiration Rule</th>
                            <th align="left">Password Format</th>
                            <th align="left">Password Length</th>
                            <th align="left">Password History Entries</th>
                            <th align="left">Account Status</th>
                            <th align="left">Maximum Number of Rejected Logins</th>
                            <th align="left">Deactivation</th>
                            <th align="left">Account Lifetime</th>
                        </tr>
                        <xsl:for-each select=".//Person">
                            <xsl:sort select="@Name"/>
                            <tr>
                                <td><!-- Bookmark for entries in the password table -->
                                    <xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="concat(@ID,'_PW')"/></xsl:attribute>
                                        <xsl:value-of select="@ID"/>
                                    </xsl:element>
                                </td>
                                <td>
                                    <xsl:value-of select="@Name"/>
                                </td>
                                <xsl:choose>
                                    <xsl:when test="@AllowChangePassword=1">
                                        <td>True</td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td>False</td>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="@ChangePasswordNextLogin=1">
                                        <td>True</td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td>False</td>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="@PasswordExpireRule='Never expires'">
                                        <td>Never expires</td>
                                    </xsl:when>
                                    <xsl:when test="@PasswordExpireRule='Expires on unit count'">
                                        <xsl:choose>
                                            <xsl:when test="contains(@PasswordExpireUnit,'Day')">
                                                <td>Expires in <xsl:value-of select="concat(@PasswordExpireCount,' Day(s)')"/></td>
                                            </xsl:when>
                                            <xsl:when test="contains(@PasswordExpireUnit,'Month')">
                                                <td>Expires in <xsl:value-of select="concat(@PasswordExpireCount,' Month(s)')"/></td>
                                            </xsl:when>
                                            <xsl:when test="contains(@PasswordExpireUnit,'Year')">
                                                <td>Expires in <xsl:value-of select="concat(@PasswordExpireCount,' Year(s)')"/></td>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <td>Please check stylesheet</td>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:when test="@PasswordExpireRule='Use default'">
                                        <td>Default</td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td>Please check stylesheet</td>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="@PasswordFormat=&apos;&lt;default&gt;&apos;">
                                        <td>Default</td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td><xsl:value-of select="@PasswordFormat"/></td>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="@MinPasswordLength=&apos;&lt;default&gt;&apos;">
                                        <td>Default</td>
                                    </xsl:when>
                                    <xsl:when test="@MinPasswordLength=0">
                                        <td>Unlimited</td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td><xsl:value-of select="@MinPasswordLength"/></td>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="@MaxPasswordHistoryEntries=&apos;&lt;default&gt;&apos;">
                                        <td>Default</td>
                                    </xsl:when>
                                    <xsl:when test="@MaxPasswordHistoryEntries=0">
                                        <td>Unlimited</td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td><xsl:value-of select="@MaxPasswordHistoryEntries"/></td>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <td>
                                    <xsl:choose>
                                        <xsl:when test="contains(@AccountStatus,'Active')">
                                            <xsl:text>Active</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@AccountStatus,'Blocked')">
                                            <xsl:text>Blocked</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="contains(@AccountStatus,'Disabled')">
                                            <xsl:text>Disabled</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@AccountStatus"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </td>
                                <xsl:choose>
                                    <xsl:when test="@MaxLoginAttempts=&apos;&lt;default&gt;&apos;">
                                        <td>Default</td>
                                    </xsl:when>
                                    <xsl:when test="@MaxLoginAttempts=&apos;&lt;unlimited&gt;&apos;">
                                        <td>Unlimited</td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <td><xsl:value-of select="@MaxLoginAttempts"/></td>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="@MaxInactivity=&apos;&lt;default&gt;&apos;">
                                        <td>Default</td>
                                    </xsl:when>
                                    <xsl:when test="@MaxInactivity='Never expires'">
                                        <td>Never deactivated</td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <xsl:when test="contains(@MaxInactivityUnit,'Day')">
                                                <td><xsl:value-of select="concat(@MaxInactivity,' Day(s)')"/></td>
                                            </xsl:when>
                                            <xsl:when test="contains(@MaxInactivityUnit,'Month')">
                                                <td><xsl:value-of select="concat(@MaxInactivity,' Month(s)')"/></td>
                                            </xsl:when>
                                            <xsl:when test="contains(@MaxInactivityUnit,'Year')">
                                                <td><xsl:value-of select="concat(@MaxInactivity,' Year(s)')"/></td>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <td><xsl:value-of select="concat(@MaxInactivity,' ',@MaxInactivityUnit)"/></td>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:choose>
                                    <xsl:when test="@LifeSpan='0'">
                                        <td>Unlimited</td>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:choose>
                                            <xsl:when test="contains(@LifeSpanUnit,'Day')">
                                                <td><xsl:value-of select="concat(@LifeSpan,' Day(s)')"/></td>
                                            </xsl:when>
                                            <xsl:when test="contains(@LifeSpanUnit,'Month')">
                                                <td><xsl:value-of select="concat(@LifeSpan,' Month(s)')"/></td>
                                            </xsl:when>
                                            <xsl:when test="contains(@LifeSpanUnit,'Year')">
                                                <td><xsl:value-of select="concat(@LifeSpan,' Year(s)')"/></td>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <td><xsl:value-of select="concat(@LifeSpan,' ',@LifeSpanUnit)"/></td>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </tr>
                        </xsl:for-each>
                    </tbody>
                </table>
            </p>
        </body>
    </html>
</xsl:template>

<!-- Start Organization Chart Code -->

    <xsl:template match="/Report/GroupOrganisation" mode="render2">
        <span>Members</span>
        <br/>
        <xsl:apply-templates mode="render2"/>
    </xsl:template>

    <xsl:template match="/Report/GroupOrganisation//GroupRef | /Report/GroupOrganisation//UnitRef | /Report/GroupOrganisation//PersonRef | /Report/GroupOrganisation//RoleRef" mode="render2">
        <xsl:call-template name="ascii-art-hierarchy"/>
        <br/>
        <xsl:call-template name="ascii-art-hierarchy"/>
        <span>___</span>
        <!--<span class="element">element</span>-->
        <!-- writes literal text to the output, in this case a non-breaking space-->
        <xsl:text>&#160;</xsl:text>
        <!-- Local name returns the name of a node without namespace -->
        <span>
            <xsl:choose>
                <xsl:when test="contains(local-name(),'GroupRef')">
                    <xsl:text>Group </xsl:text>
                </xsl:when>
                <xsl:when test="contains(local-name(),'UnitRef')">
                    <xsl:text>Unit </xsl:text>
                </xsl:when>
                <xsl:when test="contains(local-name(),'RoleRef')">
                    <xsl:text>Role </xsl:text>
                </xsl:when>
                <xsl:when test="contains(local-name(),'PersonRef')">
                    <xsl:text>Person </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Unknown </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="./@ID"/>
            <xsl:text> - </xsl:text>
            <xsl:value-of select="./@Name"/>
            <xsl:text> - </xsl:text>
            <xsl:choose>
                <xsl:when test="contains(local-name(),'GroupRef')">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('#',@ID,'_GR')"/>
                        </xsl:attribute>Details
                    </xsl:element>
                </xsl:when>
                <xsl:when test="contains(local-name(),'UnitRef')">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('#',@ID,'_UN')"/>
                        </xsl:attribute>Details
                    </xsl:element>
                </xsl:when>
                <xsl:when test="contains(local-name(),'RoleRef')">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('#',@ID,'_RL')"/>
                        </xsl:attribute>Details
                    </xsl:element>
                </xsl:when>
                <xsl:when test="contains(local-name(),'PersonRef')">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('#',@ID,'_PE')"/>
                        </xsl:attribute>Details
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        </span>
        <br/>
        <xsl:apply-templates mode="render2"/>
    </xsl:template>

    <xsl:template match="/Report/Organisation" mode="render">
        <span>Organization</span>
        <br/>
        <xsl:apply-templates mode="render"/>
    </xsl:template>

    <xsl:template match="/Report/Organisation//UnitRef | /Report/Organisation//PersonRef | /Report/Organisation//RoleRef" mode="render">
        <xsl:call-template name="ascii-art-hierarchy"/>
        <br/>
        <xsl:call-template name="ascii-art-hierarchy"/>
        <span>___</span><!--<span class="element">element</span>--><!-- writes literal text to the output, in this case a non-breaking space-->
        <xsl:text>&#160;</xsl:text><!-- Local name returns the name of a node without namespace -->
        <span>
            <xsl:choose>
                <xsl:when test="contains(local-name(),'UnitRef')">
                    <xsl:text>Unit </xsl:text>
                </xsl:when>
                <xsl:when test="contains(local-name(),'RoleRef')">
                    <xsl:text>Role </xsl:text>
                </xsl:when>
                <xsl:when test="contains(local-name(),'PersonRef')">
                    <xsl:text>Person </xsl:text>
                </xsl:when>
            </xsl:choose>
            <xsl:value-of select="./@ID"/>
            <xsl:text> - </xsl:text>
            <xsl:value-of select="./@Name"/>
            <xsl:text> - </xsl:text>
            <xsl:choose>
                <xsl:when test="contains(local-name(),'UnitRef')">
                    <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat('#',@ID,'_UN')"/></xsl:attribute>Details</xsl:element>
                </xsl:when>
                <xsl:when test="contains(local-name(),'RoleRef')">
                    <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat('#',@ID,'_RL')"/></xsl:attribute>Details</xsl:element>
                </xsl:when>
                <xsl:when test="contains(local-name(),'PersonRef')">
                    <xsl:element name="a"><xsl:attribute name="href"><xsl:value-of select="concat('#',@ID,'_PE')"/></xsl:attribute>Details</xsl:element>
                </xsl:when>
            </xsl:choose>
        </span>
        <br/>
        <xsl:apply-templates mode="render"/>
    </xsl:template>

    <!-- this template creates the tree view -->
    <xsl:template name="ascii-art-hierarchy">
        <xsl:for-each select="ancestor::*">
            <xsl:choose>
                <xsl:when test="following-sibling::node()">
                    <span>&#160;&#160;</span>|
                    <span>&#160;&#160;</span>
                    <xsl:text>&#160;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <span>    </span>
                    <span>  </span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:choose>
            <xsl:when test="parent::node() and ../child::node()">
                <span>&#160;&#160;</span>
                <xsl:text>|</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <span>   </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

<!-- End Organization Chart Code -->
    
</xsl:stylesheet>

# Configure OAuth-based Authentication for Doxis webCube (OIDC)

This walkthrough consolidates the relevant guidance from the included Doxis documents and turns it into a practical setup sequence for using **OAuth 2.0 / OpenID Connect (OIDC)** as the authentication method for **Doxis webCube**.

> **Important:** In the provided documentation, **user authentication** for Doxis is implemented with **OIDC (OpenID Connect)**, which is **built on OAuth 2.0**. The docs also mention **SMTP OAuth** for email delivery, but that is **not** the webCube user-authentication flow.

---

## Scope

This guide covers:

- Doxis CSB OIDC configuration
- Doxis webCube configuration to use OIDC for logon
- Optional settings for iframe/embedded logon
- Validation and testing

This guide does **not** cover:

- Detailed setup on a specific identity provider such as Microsoft Entra ID, Okta, Keycloak, etc.
- Exact callback URL values for every Doxis client variant, because the documentation states those URLs are client-specific

---

## 1. Confirm prerequisites

Before configuring OIDC, make sure the basic platform is in place.

### Required Doxis components

- **Doxis webCube 14.2.0**
- **Doxis CSB 12.0.0 or later**
- Full range of functions available with **Doxis CSB 14.3.0**
- **Doxis cubeDesigner** for broader suite administration where needed

### Supported application/runtime examples for webCube

- **Java 17**
- **Apache Tomcat 10.1**
- **JBoss EAP 8.0** or **WildFly 33+**

If webCube is not installed yet, deploy it first on Tomcat or JBoss/WildFly and verify you can open the administration console.

---

## 2. Understand the authentication model

Doxis uses **OIDC** for web authentication.

- OIDC is the authentication layer built on **OAuth 2.0**
- Doxis CSB acts as the **relying party / client**
- The identity provider authenticates the user
- Doxis CSB uses the **authorization code flow**
- The authorization code is exchanged at the token endpoint for an **ID token** or **access token** depending on the flow

In other words: to configure “OAuth authentication” for webCube logon, configure **OIDC in Doxis CSB** and then enable **OpenID Connect** as an authentication method in **webCube server profiles**.

---

## 3. Register Doxis CSB as an OIDC application on the identity provider

On your OIDC provider, register Doxis CSB (or the relevant Doxis CSB organization) as an application.

Configure it as follows:

1. Create an application for **Doxis CSB**.
2. Register it as a **confidential client**.
   - In Microsoft Entra ID, this corresponds to application type **Web**.
3. Use **authorization code** as the allowed grant type.
4. Choose one of these client-authentication methods:
   - **Client secret** (shared secret), or
   - **PKCE** if your provider supports and enables it explicitly
5. Register the required **callback / redirect URLs** for the Doxis clients you will use.
   - The documentation states these are **custom addresses** and that the structure depends on the specific Doxis client.
   - For webCube, use the callback URL expected by your Doxis OIDC configuration and ensure the same value is registered on the provider.
6. Record these values from the provider:
   - **Client ID**
   - **Client secret** (if using secret-based client auth)
   - **Discovery URL** (preferred if available), typically:
     - `https://provider_base_url/.well-known/openid-configuration`

> Recommendation: Use the provider **discovery URL** whenever possible, because the newer Doxis flow can retrieve provider metadata automatically.

---

## 4. Provide OIDC provider metadata to Doxis CSB

Doxis CSB must trust the OIDC provider before logon can work.

You have **two supported options**.

### Option A: Use the discovery endpoint (preferred)

Configure the provider’s **discovery endpoint** in the Doxis CSB OIDC SSO configuration.

Benefits:

- Doxis CSB retrieves provider metadata automatically
- No manual metadata export/import is required

### Option B: Import OIDC metadata manually

If discovery URL usage is not desired, export the provider metadata file and import it with `csbcmd`:

```bash
csbcmd oidc.metadata.import --file /path/to/provider-metadata.json
```

Use this if:

- Your provider gives you a metadata file directly
- You want a manual/import-based trust setup

---

## 5. Configure OIDC SSO in the Doxis CSB organization

In **Doxis Admin Client**, configure the target organization for OIDC.

### Navigation

1. Log on to the target organization with **Doxis Admin Client**.
2. Open:
   - **Configuration**
   - **Configuration of services**
3. In the services list, click **OpenID Connect SSO**.

### Configure these key settings

#### Client ID of the relying party

Enter the **Client ID** created when Doxis CSB was registered on the OIDC provider.

#### Audience of the access tokens

Configure the expected **audience**.

- In the older flow, Doxis validates **ID tokens** whose audience contains the client ID.
- In the newer flow, Doxis validates **access tokens** whose audience contains the configured recipient.

If old and new flows are used in parallel, align the audience carefully. The docs state that in such mixed cases the audience must be set consistently across Doxis CSB, clients, and provider.

#### Secret client key (encrypted)

Choose one of these:

- Store the **client secret** from the provider, or
- Leave this empty and use **PKCE** instead

Use PKCE only if it is explicitly enabled on the OIDC provider.

#### Discovery endpoint

If you are using automatic metadata retrieval, enter the provider discovery URL, for example:

```text
https://provider_base_url/.well-known/openid-configuration
```

If this field is configured, Doxis uses the **automatic** metadata method.

### Additional OIDC-related alignment

The documentation also notes that the OIDC SSO configuration determines:

- how the user is identified (for example, logon name vs. email address)
- how the provider transmits that user identity information
- the callback URLs to which the user is redirected after provider authentication

Make sure those values match what your provider is actually sending.

---

## 6. Install and verify Doxis webCube

If webCube is not already installed, deploy it first.

### Tomcat example

- Install Java and Apache Tomcat
- Deploy `Tomcat/webcube.war` using **Tomcat Manager**
- Confirm the application shows as running

### JBoss/WildFly example

- Extract `JBoss/webcube.zip` into `JBOSS_HOME/standalone/deployments`
- Ensure the `webcube.war` deployment starts successfully

After deployment, verify that the **webCube administration console** is reachable:

```text
http://Host_Appserver:Port_Appserver/webcube/admin
```

---

## 7. Create or edit the webCube server profile

Once Doxis CSB is OIDC-enabled, enable OIDC for the relevant webCube logon profile.

### Navigation in webCube administration console

1. Open the **webCube administration console**.
2. Go to:
   - **Configuration**
   - **Server profiles**
3. Either:
   - create a **New server profile**, or
   - edit an existing profile

### Configure the basic Doxis CSB connection

Fill in the server profile fields, including:

- **Server profile** name
- **Doxis CSB server name**
- **Doxis CSB server port**
- **SSL** if required
- Optional load-balancing / TAF settings if your environment uses multiple CSB nodes

### Enable OpenID Connect as the authentication method

Under **Authentication methods**:

- enable **OpenID Connect**
- ensure **at least one** authentication method is enabled

You may also keep **Password** enabled during rollout for fallback access.

Then:

1. Click **Save**
2. Click **Apply**

At this point, the server profile can offer **OpenID Connect** as a logon method.

---

## 8. Configure the logon experience in webCube

Users can log on interactively with OIDC once the server profile is configured.

The documentation states the logon page can offer:

- **Log on** for password authentication
- **Log on with SAML**
- **Log on using Kerberos**
- **Log on using OpenID Connect**

If you want webCube URLs to force OIDC directly, use the `oidclogin=1` URL parameter together with the target server profile and organization.

Example pattern:

```text
http://Host_Appserver:Port_Appserver/webcube/...?...&server=SERVER_PROFILE&system=ORGANIZATION&oidclogin=1
```

This forces authentication through OpenID Connect and overwrites any active OIDC session.

---

## 9. Optional: enable OIDC for embedded/iframe scenarios

If webCube is used inside an **iframe** (for example, embedded portals or Microsoft Teams-style scenarios), additional cookie settings are required.

### Required cookie settings

In `context.xml`, set:

```xml
<Context path="">
  <CookieProcessor
    className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
    sameSiteCookies="none" />
  <Manager pathname="" />
</Context>
```

In `web.xml`, set cookies to secure:

```xml
<session-config>
  <cookie-config>
    <http-only>true</http-only>
    <secure>true</secure>
  </cookie-config>
</session-config>
```

### Important

- `sameSiteCookies="none"` is required for OIDC in iframe scenarios
- When using `sameSiteCookies="none"`, **HTTPS is required**

---

## 10. Restart services where needed

After significant authentication changes, restart affected components as needed:

- **Doxis CSB** / web application server if required by your environment
- **Doxis webCube** application server after configuration changes affecting deployed behavior

This is especially important after:

- new deployment
- JVM / container changes
- cookie/security configuration changes
- trust/metadata changes if your environment does not refresh them dynamically

---

## 11. Test the end-to-end OIDC logon

Perform a clean test in a browser session with no stale cookies.

### Test procedure

1. Open the normal webCube logon page.
2. Select the correct **server profile** and **organization**.
3. Click **Log on using OpenID Connect**.
4. Confirm the browser is redirected to the OIDC provider.
5. Authenticate on the provider.
6. Confirm the browser returns to webCube and the session opens successfully.

### Direct URL test

Also test with an OIDC-forcing URL using `oidclogin=1`.

### Embedded test

If applicable, test the iframe scenario over **HTTPS**.

---

## 12. Rollout recommendation

A safe rollout path is:

1. Configure OIDC in **Doxis CSB** first
2. Keep **Password** enabled temporarily in webCube server profiles
3. Test with admin and pilot users
4. Validate redirect, audience, claims, and callback behavior
5. Switch users to **OpenID Connect** as the primary method
6. Optionally remove password-based logon later if your policy allows it

---

## Troubleshooting checklist

### Redirect to provider does not happen

Check:

- OIDC is enabled in the **webCube server profile**
- the correct **server profile** and **organization** are selected
- `oidclogin=1` URL uses valid `server` and `system` values

### Redirect happens, but logon fails after return

Check:

- **Client ID** matches between provider and Doxis CSB
- **audience** is configured consistently
- **client secret** is correct, or **PKCE** is enabled correctly
- **callback URLs** match exactly on both sides
- provider metadata is available through **discovery URL** or imported metadata

### Iframe/embedded logon fails

Check:

- `sameSiteCookies="none"`
- `secure=true`
- full **HTTPS** usage end to end

### Users still see password-only behavior

Check:

- browser cookies from older sessions
- correct server profile activation
- whether the profile actually has **OpenID Connect** selected

---

## Minimal implementation summary

If you only want the shortest possible path, do this:

1. Register **Doxis CSB** on the OIDC provider as a **confidential client** using **authorization code flow**.
2. Record **Client ID**, **Client Secret** (or enable **PKCE**), and **Discovery URL**.
3. In **Doxis Admin Client** for the organization, configure **OpenID Connect SSO** with:
   - Client ID
   - Audience
   - Secret client key or PKCE
   - Discovery endpoint
4. In **webCube administration**, create/edit the **server profile** and enable **OpenID Connect** under **Authentication methods**.
5. Save, apply, restart if needed, and test logon.

---

## Source basis used for this walkthrough

- [**Doxis CSB 14.3.0 Installation Guide**](https://services.sergroup.com/documentation/#/view/PD_CSB_Short/14.3.0/en-us/IG_Doxis_CSB/WEBHELP/index.html)
  - OIDC overview, authorization code flow, discovery URL, PKCE, metadata import, and organization-level OIDC SSO configuration
- [**Doxis webCube 14.2.0 Administrator Guide**](https://services.sergroup.com/documentation/#/view/PD_webCube/14.2.0/en-us/AG_Doxis_webCube/WEBHELP/index.html)
  - server profiles, authentication methods, OIDC login forcing via URL, iframe cookie settings
- [**Doxis webCube 14.2.0 Installation Guide**](https://services.sergroup.com/documentation/#/view/PD_webCube/14.2.0/en-us/IG_Doxis_webCube/WEBHELP/index.html)
  - installation/deployment prerequisites and application server setup context


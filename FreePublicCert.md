# Local HTTPS Development on WSL2 (Fedora) Using DuckDNS + Let’s Encrypt

This guide explains how to obtain a **real, publicly trusted SSL certificate for free** and use it locally with:

* Windows 11
* WSL2 (Fedora 42)
* NGINX
* Docker services behind NGINX
* DuckDNS (free domain)
* Let’s Encrypt (free certificates)

No money required.

---

# Architecture Overview

```
Browser (Windows)
    ↓
127.0.0.1 (via hosts file)
    ↓
WSL2 (Fedora)
    ↓
NGINX (SSL termination)
    ↓
Docker containers
```

We use:

* **DuckDNS** to obtain a real public domain
* **Let’s Encrypt (DNS challenge)** to issue a trusted certificate
* **Windows hosts file override** to route traffic locally

---

# 1️⃣ Register a Free Domain (DuckDNS)

1. Go to: [https://www.duckdns.org](https://www.duckdns.org)
2. Log in
3. Create a domain, e.g.:

```
YourSubDomain.duckdns.org
```

4. Copy your **DuckDNS token** (shown on the dashboard)

---

# 2️⃣ Install Certbot in Fedora (WSL2)

Inside WSL:

```bash
sudo dnf install certbot -y
```

Verify:

```bash
certbot --version
```

---

# 3️⃣ Create DuckDNS Auth Script (DNS Challenge Automation)

Create directory:

```bash
mkdir -p ~/duckdns
```

Create authentication script:

```bash
nano ~/duckdns/auth.sh
```

Paste:

```bash
#!/bin/bash

DOMAIN="YourSubDomain"
TOKEN="YOUR_DUCKDNS_TOKEN"

curl -s "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&txt=$CERTBOT_VALIDATION&clear=false"
sleep 30
```

Replace:

```
YOUR_DUCKDNS_TOKEN
```

Make executable:

```bash
chmod +x ~/duckdns/auth.sh
```

---

# 4️⃣ Create Cleanup Script

```bash
nano ~/duckdns/cleanup.sh
```

Paste:

```bash
#!/bin/bash

DOMAIN="YourSubDomain"
TOKEN="YOUR_DUCKDNS_TOKEN"

curl -s "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&txt=&clear=true"
```

Make executable:

```bash
chmod +x ~/duckdns/cleanup.sh
```

---

# 5️⃣ Request a Real Let’s Encrypt Certificate

Run:

```bash
sudo certbot certonly \
  --manual \
  --preferred-challenges dns \
  --manual-auth-hook ~/duckdns/auth.sh \
  --manual-cleanup-hook ~/duckdns/cleanup.sh \
  -d YourSubDomain.duckdns.org \
  -d '*.YourSubDomain.duckdns.org'
```

If successful, you will see:

```
Successfully received certificate.
```

Certificates are stored at:

```
/etc/letsencrypt/live/YourSubDomain.duckdns.org/
```

Important files:

```
fullchain.pem
privkey.pem
```

These are publicly trusted certificates.

---

# 6️⃣ Override DNS Locally (Windows Hosts File)

Open Notepad **as Administrator**.

Edit:

```
C:\Windows\System32\drivers\etc\hosts
```

Add:

```
127.0.0.1 YourSubDomain.duckdns.org
```

Save the file.

Verify:

```powershell
ping YourSubDomain.duckdns.org
```

It should resolve to:

```
127.0.0.1
```

---

# 7️⃣ Configure NGINX for SSL Termination

Example NGINX server block:

```nginx
server {
    listen 443 ssl;
    server_name YourSubDomain.duckdns.org;

    ssl_certificate     /etc/letsencrypt/live/YourSubDomain.duckdns.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/YourSubDomain.duckdns.org/privkey.pem;

    location / {
        proxy_pass http://localhost:8080;
    }
}
```

Reload NGINX:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

# 8️⃣ Automatic Renewal

Test renewal:

```bash
sudo certbot renew --dry-run
```

Add cron job:

```bash
sudo crontab -e
```

Add:

```
0 3 * * * certbot renew --quiet
```

Certificates are valid for 90 days and will renew automatically.

---

# Why This Works

* DuckDNS provides a real public domain.
* Let’s Encrypt validates domain ownership via DNS challenge.
* After issuance, we override DNS locally using the Windows hosts file.
* The browser sees:

  * A valid domain
  * A trusted certificate
  * A secure HTTPS connection
* Traffic never leaves your machine.

---

# Final Result

You now have:

* ✅ Real publicly trusted SSL
* ✅ Zero cost
* ✅ Local development routing
* ✅ Clean NGINX SSL termination
* ✅ No router configuration
* ✅ No port forwarding
* ✅ No self-signed certificates

---

# Summary

| Component          | Purpose                         |
| ------------------ | ------------------------------- |
| DuckDNS            | Free public domain              |
| Let’s Encrypt      | Free trusted SSL certificate    |
| Certbot            | Certificate automation          |
| Windows hosts file | Local DNS override              |
| NGINX              | SSL termination + reverse proxy |
| WSL2               | Linux dev environment           |

---

This setup mirrors production HTTPS behavior while remaining entirely local and free.

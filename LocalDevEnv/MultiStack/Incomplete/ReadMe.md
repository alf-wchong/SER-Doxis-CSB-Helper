## Updated Architecture (Traefik-Based, Multi-Stack Ready)

NGINX replaced with a **shared Traefik ingress layer** and enables **multiple isolated Compose stacks** to run concurrently without port conflicts.

### Key changes

* **Single shared Traefik instance**

  * Only component exposing ports `80/443`
* **All application stacks run without exposed ports**
* **Routing via hostnames (subdomains)**
* **Automatic service discovery via Docker labels**
* **Per-stack isolation via Compose project names**
* **No port collisions, no config duplication**

---

# New `docker-compose.yml` (Application Stack)

This file is **stack-safe and fully parallelizable**.

```yaml
version: "3.9"

services:
  ##############################################################
  # PostgreSQL (Internal Only)
  ##############################################################
  dx4-postgres:
    image: postgres:15
    restart: unless-stopped
    environment:
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${DB_NAME:-dx4}
    volumes:
      - dx4PostgresData:/var/lib/postgresql/data
    networks:
      backend:
        aliases:
          - dx4postgres
          - dx4-postgres
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d dx4"]
      interval: 10s
      timeout: 5s
      retries: 5

  ##############################################################
  # Elasticsearch (Internal Only)
  ##############################################################
  dx4-elastic:
    image: dx4-elastic:latest
    restart: unless-stopped
    env_file:
      - dx4-csb.env
    networks:
      backend:
        aliases:
          - dx4elastic
    volumes:
      - dx4ElasticData:/home/doxis4/dx4ElasticData
    healthcheck:
      test: ["CMD", "wget", "--no-proxy", "-O", "/dev/null", "http://localhost:9200/_cluster/health"]
      interval: 30s
      timeout: 5s
      retries: 5

  ##############################################################
  # DX4 Core
  ##############################################################
  dx4-csb:
    image: dx4-csb:latest
    restart: unless-stopped
    env_file:
      - dx4-csb.env
    networks:
      backend:
        aliases:
          - dx4csb
      traefik:
    depends_on:
      dx4-postgres:
        condition: service_healthy
      dx4-elastic:
        condition: service_healthy
    volumes:
      - dx4Shared:/home/doxis4/shared
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.csb.rule=Host(`csb.${BASE_DOMAIN}`)"
      - "traefik.http.routers.csb.entrypoints=websecure"
      - "traefik.http.routers.csb.tls=true"
      - "traefik.http.services.csb.loadbalancer.server.port=8080"

  dx4-admin:
    image: dx4-admin:14.3.1_vnc
    restart: unless-stopped
    env_file:
      - dx4-csb.env
    environment:
      GEOMETRY: "1600x900"
      DEPTH: "24"
      ADMINCLIENT_DIR: "/home/doxis4/DOXiS4SoapAdminClient"
      ADMINCLIENT_CMD: "./DOXiS4CSBAdminClient"
      NOVNC_PORT: "6080"
      VNC_PORT: "5900"
    networks:
      backend:
        aliases:
          - dx4admin
      traefik:
    depends_on:
      - dx4-csb
    volumes:
      - dx4Shared:/home/doxis4/shared
    labels:
      - "traefik.enable=true"

      # Admin API
      - "traefik.http.routers.admin.rule=Host(`admin.${BASE_DOMAIN}`)"
      - "traefik.http.routers.admin.entrypoints=websecure"
      - "traefik.http.routers.admin.tls=true"
      - "traefik.http.services.admin.loadbalancer.server.port=9080"

      # Admin Client (noVNC)
      - "traefik.http.routers.adminclient.rule=Host(`adminclient.${BASE_DOMAIN}`)"
      - "traefik.http.routers.adminclient.entrypoints=websecure"
      - "traefik.http.routers.adminclient.tls=true"
      - "traefik.http.services.adminclient.loadbalancer.server.port=6080"

  dx4-agent:
    image: dx4-agent:latest
    restart: unless-stopped
    env_file:
      - dx4-csb.env
    networks:
      backend:
        aliases:
          - dx4agent
      traefik:
    depends_on:
      - dx4-csb
    volumes:
      - dx4Shared:/home/doxis4/shared
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.agent.rule=Host(`agent.${BASE_DOMAIN}`)"
      - "traefik.http.routers.agent.entrypoints=websecure"
      - "traefik.http.routers.agent.tls=true"
      - "traefik.http.services.agent.loadbalancer.server.port=8070"

  dx4-storage:
    image: dx4-storage:latest
    restart: unless-stopped
    env_file:
      - dx4-csb.env
    networks:
      backend:
        aliases:
          - dx4storage
      traefik:
    depends_on:
      - dx4-csb
    volumes:
      - dx4Shared:/home/doxis4/shared
      - dx4Storage:/home/doxis4/dx4Storage
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.storage.rule=Host(`storage.${BASE_DOMAIN}`)"
      - "traefik.http.routers.storage.entrypoints=websecure"
      - "traefik.http.routers.storage.tls=true"
      - "traefik.http.services.storage.loadbalancer.server.port=8080"

  dx4-fulltext:
    image: dx4-fulltext:latest
    restart: unless-stopped
    env_file:
      - dx4-csb.env
    networks:
      backend:
        aliases:
          - dx4ft
      traefik:
    depends_on:
      - dx4-csb
    volumes:
      - dx4Shared:/home/doxis4/shared
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.fulltext.rule=Host(`fulltext.${BASE_DOMAIN}`)"
      - "traefik.http.routers.fulltext.entrypoints=websecure"
      - "traefik.http.routers.fulltext.tls=true"
      - "traefik.http.services.fulltext.loadbalancer.server.port=3099"

  dx4-webcube:
    image: dx4-webcube:14.3.1
    restart: unless-stopped
    env_file:
      - dx4-webcube.env
    networks:
      backend:
        aliases:
          - dx4webcube
      traefik:
    volumes:
      - dx4Shared:/home/doxis4/shared
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.webcube.rule=Host(`${BASE_DOMAIN}`)"
      - "traefik.http.routers.webcube.entrypoints=websecure"
      - "traefik.http.routers.webcube.tls=true"
      - "traefik.http.services.webcube.loadbalancer.server.port=8080"

  dx4-businessstudio:
    image: dx4-businessstudio:14.2.1
    restart: unless-stopped
    env_file:
      - dx4-businessstudio.env
    networks:
      backend:
        aliases:
          - dx4businessstudio
          - dx4-businessstudio
      traefik:
    depends_on:
      dx4-csb:
        condition: service_healthy
    volumes:
      - dx4Shared:/home/doxis4/shared
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.businessstudio.rule=Host(`businessstudio.${BASE_DOMAIN}`)"
      - "traefik.http.routers.businessstudio.entrypoints=websecure"
      - "traefik.http.routers.businessstudio.tls=true"
      - "traefik.http.services.businessstudio.loadbalancer.server.port=8080"

  pgadmin:
    image: dpage/pgadmin4:8
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@${BASE_DOMAIN}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD}
    volumes:
      - pgadminData:/var/lib/pgadmin
    networks:
      backend:
      traefik:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.pgadmin.rule=Host(`pgadmin.${BASE_DOMAIN}`)"
      - "traefik.http.routers.pgadmin.entrypoints=websecure"
      - "traefik.http.routers.pgadmin.tls=true"
      - "traefik.http.services.pgadmin.loadbalancer.server.port=80"

  cerebro:
    image: lmenezes/cerebro
    restart: unless-stopped
    environment:
      CEREBRO_PORT: 9000
    networks:
      backend:
      traefik:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.cerebro.rule=Host(`cerebro.${BASE_DOMAIN}`)"
      - "traefik.http.routers.cerebro.entrypoints=websecure"
      - "traefik.http.routers.cerebro.tls=true"
      - "traefik.http.services.cerebro.loadbalancer.server.port=9000"

volumes:
  dx4Shared:
  dx4PostgresData:
  dx4ElasticData:
  pgadminData:
  dx4Storage:

networks:
  backend:
  traefik:
    external: true```

---

# New `traefik-compose.yml` (Shared Ingress Layer)

Run **once globally**, not per stack.

```yaml
version: "3.9"

services:
  traefik:
    image: traefik:v3.0
    command:
      - "--api.dashboard=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.le.acme.tlschallenge=true"
      - "--certificatesresolvers.le.acme.email=${ACME_EMAIL}"
      - "--certificatesresolvers.le.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./letsencrypt:/letsencrypt
    networks:
      - traefik

networks:
  traefik:
    name: traefik
```

---

# Updated Markdown (Key Sections Only)

## Architecture Summary (Updated)

```
Windows Browser
    │
    │ Hosts file / DNS
    ▼
Traefik (Ports 80/443, TLS termination)
    │
    ├── Stack A (dx4a)
    │     ├── dx4-csb
    │     ├── dx4-admin
    │     └── ...
    │
    └── Stack B (dx4b)
          ├── dx4-csb
          ├── dx4-admin
          └── ...
```

---

## Design Principles (Updated)

* Only **Traefik exposes ports**
* All stacks are **fully isolated via Compose project names**
* No container uses `container_name`
* No service exposes host ports
* Routing is **hostname-based via Traefik labels**
* Shared external network: `traefik`
* Internal network per stack: `backend`

---

## Runtime Changes

### Hosts file

You now need per-stack domains:

```
127.0.0.1 csb.stacka.dx4localdev.duckdns.org
127.0.0.1 csb.stackb.dx4localdev.duckdns.org
```

And set:

```
BASE_DOMAIN=stacka.dx4localdev.duckdns.org
BASE_DOMAIN=stackb.dx4localdev.duckdns.org
```

---

## Operational Commands (Updated)

### 1. Start Traefik (once)

```bash
docker compose -f traefik-compose.yml up -d
```

---

### 2. Start Stack A

```bash
docker compose \
  --env-file .env.stackA \
  -p dx4a up -d
```

---

### 3. Start Stack B

```bash
docker compose \
  --env-file .env.stackB \
  -p dx4b up -d
```

---

## Security Model (Updated)

* Single ingress point (Traefik)
* Automatic TLS via ACME
* No exposed internal services
* Network isolation per stack
* Label-based routing (no static config drift)

---

## Design Decisions (Updated)

| Decision                 | Rationale                                       |
| ------------------------ | ----------------------------------------------- |
| Traefik over NGINX       | Dynamic config, no per-stack config duplication |
| No exposed ports         | Eliminates collisions                           |
| External ingress network | Enables shared routing                          |
| Env-based domains        | Clean multi-stack routing                       |
| Label-based routing      | Declarative, version-controlled                 |

---

## Result (Updated)

* Multiple parallel stacks without port conflicts
* Zero config duplication for routing
* Automatic TLS management
* Cleaner, scalable architecture
* Fully Compose-native solution

---

## Notes / Assumptions

* You must create the external network once:

```bash
docker network create traefik
```

* DNS must resolve all subdomains to `127.0.0.1`

---


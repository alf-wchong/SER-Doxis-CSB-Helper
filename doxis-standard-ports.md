# Doxis Standard Ports — Non-Containerized (Classic) Deployment

Reference table of default network ports used by a traditional (non-Docker/non-Kubernetes) Doxis
ECM deployment: CSB core platform plus commonly deployed satellite products (webCube, mobileCube,
Business Studio, Storage Service, Fulltext Service/Elasticsearch, Agent Service, FIPS, ERPCS,
DCES, safeLock, Imaging Service, WebDAV Connector for ILM, Gateway Server, ITA-Server, RDBMS).

> **Note:** Almost every port below is configurable at install time. These are the documented
> **defaults** — treat them as the "out of the box" values only, and confirm against your own
> installation configuration before opening firewall rules.

## Core platform ports

| Component | Port | Protocol | Description |
|---|---|---|---|
| CSB / webCube / Business Studio app server (JBoss/WildFly) | 8080 / 8443 | HTTP / HTTPS | Main application server port (`AH` variable) — hosts CSB, webCube, Business Studio, DX4 Java/COM API, SOAP & REST webservices, Template Designer, BPMN2 Modeler, Machine Learning, and the License Service SOAP endpoint. All of these share this single port; none has a dedicated port of its own. |
| CSB / webCube app server (Apache Tomcat variant) | 8080 / 8443 | HTTP / HTTPS | Same role as above when Tomcat is used as the servlet container instead of JBoss/WildFly. |
| Admin Service (Superadmin / org-admin console backend) | 9080 | HTTP, JMS | Backend used by the Admin Client in both superadmin and org-admin mode. |
| Storage Service | 8080 / 8443 | HTTP / HTTPS | Document storage tier; commonly co-located with CSB and sharing its port, but can run on a dedicated host/port. |
| FIPS (File Import Service) | 3089 | HTTP | Import service used by the Admin Client and CSB. |
| Agent Service | 8070 (admin) / 8080 (`csb.port`) | HTTP | 8070 is the port the Admin Client/CSB use to reach the Agent Service; 8080 (`csb.port`) is the Agent Service's own connection back to the app server. |
| Fulltext Service — admin/control channel | 3099 | HTTP | Control channel used by CSB and the Admin Client to manage the Fulltext Service. |
| Fulltext Service — Elasticsearch REST API | 9200 | HTTP | Elasticsearch REST endpoint used by CSB. |
| Fulltext Service — Elasticsearch cluster transport | 9300 | Binary (ES transport) | Node-to-node traffic between Elasticsearch cluster members. |
| RDBMS — Oracle | 1521 | JDBC/TCP | Standard Oracle listener default. |
| RDBMS — DB2 | 50000 / 50001 | JDBC/TCP | Per the CSB Installation Guide's database port table. |
| RDBMS — SQL Server | 1433* | JDBC/TCP | *Documented in the CSB Installation Guide as "1443", which conflicts with SQL Server's real-world default of 1433 — verify against your actual `sqlservr.exe` listener config before relying on this. |

## Satellite product / component ports

| Component | Port | Protocol | Description |
|---|---|---|---|
| ITA-Server (`itav` process, legacy WORM storage) | 2000 (Windows) / 30900 (UNIX) | TCP | Communication port for the legacy ITA-Server archive process. |
| ITA Admin Console | 8080 (Tomcat) / 9080 (IBM WebSphere) | HTTP | Administration UI for ITA-Server. |
| DCES (Doxis Classification & Extraction Service) | 42020 | HTTP/HTTPS | Default admin/service port; the service will not start in standard mode without a configured connection. |
| Imaging Service | 8082 | HTTP | Default `basePort` for the HTML5 viewer backend. |
| ERPCS (ERP Connection Service) | 8080 | HTTP | Own dedicated Tomcat instance; admin UI at `/derpcs`. |
| WebDAV Connector for ILM (inbound) | 8080 | HTTP | Own dedicated Tomcat instance. |
| WebDAV Connector for ILM → CSB (outbound) | 8080 / 8443 | HTTP/HTTPS | Points at the target CSB server's app-server port. |
| mobileCube Gateway | 8080 | HTTP | Own dedicated Tomcat instance (generic installer default). |
| Gateway Server | Own installer-default Tomcat port (not separately fixed) | HTTP/HTTPS | Inter-process communication between Gateway Server processes uses gRPC with no fixed port — this traffic must not be firewalled or altered. |
| Gateway Server — email notifications | 25 (default, configurable) | SMTP | Outbound notification email. |

## safeLock (WORM / tamper-proof storage appliance)

safeLock is the only Doxis component with its own dedicated "Port matrix" chapter in its documentation:

| Port(s) | Protocol | Description |
|---|---|---|
| 22 | SSH | SSH access, if enabled via the safeLock web interface. |
| 25 | SMTP | Sending email notifications (default, configurable). |
| 587 | SMTPS | Sending email notifications, secure (default, configurable). |
| 443 | HTTPS | Access to the safeLock web interface (HTTP/80 is no longer supported as of 14.1.0+). |
| 111, 2049 | NFS (TCP/UDP) | Access to network shares from a UNIX system. |
| 139, 445 | CIFS/SMB (Samba) | Access to network shares from a Windows system. |
| 4369, 5672, 15672, 25672 | RabbitMQ | Internal messaging between safeLock components (cluster/internal use). |
| 6556 | Check_MK | Monitoring of the safeLock system. |
| 8088 | TCP | Trust relationship between two safeLock systems (mirroring/replication pairing). |
| 18080 | HTTP/HTTPS (configurable) | Doxis Storage Service instance integrated inside safeLock. |

## Known gaps (not documented / use with caution)

- No single cross-product firewall document exists; the CSB Installation Guide's "Ports and protocols" chapter is the only consolidated multi-component table (safeLock is the one exception with its own dedicated matrix).
- No fixed default port is documented for Gateway Server's own inbound HTTP(S) listener beyond the generic Tomcat installer default.
- No WildFly management-console port (commonly 9990/9993 in vanilla WildFly) is documented anywhere in Doxis docs — only the application HTTP(S) listener is covered.
- HCP (Hitachi Content Platform) configuration port is referenced as a variable in the CSB Ports chapter, but no concrete default value is documented.
- SMTP port is generally a site-configured value (25 plain / 587 submission) rather than a fixed Doxis-wide default.

## Sources

1. [Doxis CSB Installation Guide — "Ports and protocols"](https://services.sergroup.com/documentation/api/documentations/2/576/1844/WEBHELP/APP_CSB/topics/ref_BeforeInstall_Ports.html)
2. Doxis CSB User Guide (`UG_Doxis_CSB.pdf`) — Admin Service, ITA-Server, Agent Service ports
3. [Doxis safeLock User Guide — "Port matrix"](https://services.sergroup.com/documentation/api/documentations/1/542/1711/WEBHELP/APP_SafeLockTriCSS/topics/ref_port_matrix.html)
4. Doxis Classification & Extraction Service Installation Guide (port 42020); also ServiceNow KB0010231 (EN) / KB0010206 (DE)
5. [Doxis Imaging Service Installation Guide](https://services.sergroup.com/documentation/api/documentations/25/253/738/WEBHELP/APP_ImagingService/topics/ref_DOXiS4_ImagingService_ConfigurationOptions.html)
6. Doxis ERP Connection Service Installation Guide
7. Doxis WebDAV Connector for ILM Installation Guide / Docker Image Guide
8. Doxis Mobile (mobileCube) Installation Guide
9. Doxis Web (webCube) Installation Guide
10. Doxis Gateway Server Installation Guide / Administrator Guide (15.0.0)
11. Doxis Invoice (Order/Invoice Master Control Plus) Installation Guide

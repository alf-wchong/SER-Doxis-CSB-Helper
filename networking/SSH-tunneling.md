# Doxis SSH Tunneling from Windows 11 to RHEL Servers

## Purpose

Doxis services are deployed across four RHEL machines. Only SSH port `22` is open between the Windows 11 workstation and the RHEL servers, so access to Doxis service ports must be done through SSH local port forwarding.

All commands below are intended to be run from **PowerShell on Windows 11**.

## Server Layout

| Server | Role | SSH Target |
|---|---|---|
| x01 | Agent Service | `<user>@<hostPrefix>1<hostSuffix>` |
| x02 | CSB | `<user>@<hostPrefix>2<hostSuffix>` |
| x03 | webCube | `<user>@<hostPrefix>3<hostSuffix>` |
| x04 | Fulltext Service | `<user>@<hostPrefix>4<hostSuffix>` |

## Local Port Mapping

Because multiple servers use the same service ports, each remote port is mapped to a unique local port on Windows.

| Local URL on Win11 | Remote Server | Remote Port | Service |
|---|---:|---:|---|
| `http://localhost:18070` | x01 | `8070` | Agent Service admin access |
| `http://localhost:18080` | x01 | `8080` | Agent Service callback / service port |
| `http://localhost:28080` | x02 | `8080` | CSB HTTP |
| `http://localhost:29080` | x02 | `9080` | Admin Service |
| `http://localhost:23089` | x02 | `3089` | FIPS |
| `http://localhost:38080` | x03 | `8080` | webCube HTTP |
| `http://localhost:33099` | x04 | `3099` | Fulltext admin/control |
| `http://localhost:39200` | x04 | `9200` | Elasticsearch REST API |
| `http://localhost:39300` | x04 | `9300` | Elasticsearch transport |

## Recommended SSH Tunnel Commands

Run one PowerShell window per server. This keeps the setup manageable while allowing all services to be accessed at the same time.

| Server | PowerShell command |
|---|---|
| x01 Agent Service | `ssh -N -L 127.0.0.1:18070:127.0.0.1:8070 -L 127.0.0.1:18080:127.0.0.1:8080 <user>@<hostPrefix>1<hostSuffix>` |
| x02 CSB | `ssh -N -L 127.0.0.1:28080:127.0.0.1:8080 -L 127.0.0.1:29080:127.0.0.1:9080 -L 127.0.0.1:23089:127.0.0.1:3089 <user>@<hostPrefix>2<hostSuffix>` |
| x03 webCube | `ssh -N -L 127.0.0.1:38080:127.0.0.1:8080 <user>@<hostPrefix>3<hostSuffix>` |
| x04 Fulltext Service | `ssh -N -L 127.0.0.1:33099:127.0.0.1:3099 -L 127.0.0.1:39200:127.0.0.1:9200 -L 127.0.0.1:39300:127.0.0.1:9300 <user>@<hostPrefix>4<hostSuffix>` |

## Usage Notes

The `-N` option tells SSH not to start a remote shell. The SSH session exists only to carry tunnel traffic.

The `-L` option defines a local port forward:

```text
-L <local-bind-address>:<local-port>:<remote-bind-address>:<remote-port>

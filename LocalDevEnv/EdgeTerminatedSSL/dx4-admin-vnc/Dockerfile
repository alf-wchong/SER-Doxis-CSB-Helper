FROM dx4-admin:14.3.1

USER root

# Install a minimal GUI stack + VNC + noVNC (via websockify)
# - Xvfb: virtual X display
# - fluxbox: lightweight WM so Swing windows behave
# - x11vnc: VNC server
# - novnc + websockify: browser client + websocket proxy
# - fonts: Swing text renders properly
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    xvfb x11vnc fluxbox \
    novnc websockify \
    xterm \
    fonts-dejavu fonts-liberation \
 && rm -rf /var/lib/apt/lists/*

COPY start-admin-vnc.sh /usr/local/bin/start-admin-vnc.sh
RUN chmod +x /usr/local/bin/start-admin-vnc.sh \
 && chown root:root /usr/local/bin/start-admin-vnc.sh

# noVNC web UI (served by websockify)
EXPOSE 6080

USER doxis4

ENTRYPOINT ["/usr/local/bin/start-admin-vnc.sh"]

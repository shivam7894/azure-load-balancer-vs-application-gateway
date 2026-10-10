#!/bin/bash
set -eux

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx python3

cat >/var/www/html/index.html <<EOF
<html><body>
<h1>Azure LB vs Application Gateway Backend</h1>
<p>Host: $(hostname)</p>
<p>Port 80: Load Balancer demo endpoint</p>
<p>Port 8081: Product backend for Application Gateway</p>
<p>Port 8082: Order backend for Application Gateway</p>
</body></html>
EOF

mkdir -p /opt/demo

cat >/opt/demo/server.py <<'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer
import os, sys, json

port=int(sys.argv[1])
role=sys.argv[2]

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = {
            "status": "UP",
            "backend": os.uname().nodename,
            "role": role,
            "port": port,
            "path": self.path
        }
        data=json.dumps(body).encode()
        self.send_response(200)
        self.send_header("Content-Type","application/json")
        self.send_header("Content-Length",str(len(data)))
        self.end_headers()
        self.wfile.write(data)
    def log_message(self, fmt, *args):
        print(fmt % args)

HTTPServer(("0.0.0.0", port), Handler).serve_forever()
PY

cat >/etc/systemd/system/product-demo.service <<EOF
[Unit]
After=network.target
[Service]
ExecStart=/usr/bin/python3 /opt/demo/server.py 8081 product-service
Restart=always
[Install]
WantedBy=multi-user.target
EOF

cat >/etc/systemd/system/order-demo.service <<EOF
[Unit]
After=network.target
[Service]
ExecStart=/usr/bin/python3 /opt/demo/server.py 8082 order-service
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now product-demo.service
systemctl enable --now order-demo.service

cat >/var/www/html/health <<EOF
UP
EOF

systemctl enable --now nginx

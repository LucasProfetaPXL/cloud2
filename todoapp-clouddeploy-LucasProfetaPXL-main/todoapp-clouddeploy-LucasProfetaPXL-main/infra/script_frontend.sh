#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# 1. Install dependencies
apt-get update -y
apt-get install -y git nginx curl ca-certificates gnupg

# 2. (optioneel) Node installeren voor frontend build
install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" > /etc/apt/sources.list.d/nodesource.list
apt-get update -y && apt-get install -y nodejs

# 3. Haal code & build
rm -rf /opt/app
git clone --depth=1 https://github.com/3TIN-CloudExpert/todoapp-clouddeploy-LucasProfetaPXL.git /opt/app
cd /opt/app/frontend
if [ -f package-lock.json ]; then npm ci; else npm install; fi
npm run build

# 4. Kopieer build naar Nginx root
DEST=/var/www/html
SRC=""
[ -d dist ] && SRC=dist
[ -z "$SRC" ] && [ -d build ] && SRC=build
[ -z "$SRC" ] && { echo "Geen build map gevonden (dist/ of build/)"; exit 1; }

rm -rf "$DEST"/*
cp -r "$SRC"/* "$DEST"/

# 5. Basis nginx config
cat >/etc/nginx/sites-available/default <<'EOF'
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name _;
  root /var/www/html;
  index index.html;

  location / {
    try_files $uri /index.html;
  }

  location /healthz {
    return 200 "ok\n";
    add_header Content-Type text/plain;
  }
}
EOF

nginx -t
systemctl enable --now nginx

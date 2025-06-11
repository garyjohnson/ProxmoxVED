#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: YourNameHere
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Wavesonics/hammer-editor

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y unzip curl
msg_ok "Installed Dependencies"

msg_info "Installing hammer-editor"
RELEASE=$(curl -fsSL https://api.github.com/repos/Wavesonics/hammer-editor/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
curl -fsSL -o "${RELEASE}.zip" "https://github.com/Wavesonics/hammer-editor/releases/download/${RELEASE}/server.zip"
unzip -q "${RELEASE}.zip"
# Remove the v prefix to RELEASE if it exists
if [[ "${RELEASE}" == v* ]]; then
  RELEASE="${RELEASE:1}"
fi
mv "server-2/" "/opt/hammer-editor"
echo "${RELEASE}" >"/opt/hammer-editor_version.txt"
msg_ok "Installed hammer-editor"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/hammer-editor.service
[Unit]
Description=Hammer Editor Service
After=network.target

[Service]
WorkingDirectory=/opt/hammer-editor/
ExecStart=/opt/hammer-editor/bin/server
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now hammer-editor
msg_ok "Created Service"

motd_ssh
customize

msg_info "Cleaning up"
rm -f "${RELEASE}".zip
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"

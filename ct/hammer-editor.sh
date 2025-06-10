#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/garyjohnson/ProxmoxVED/refs/heads/hammer-editor/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: garyjohnson
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/Wavesonics/hammer-editor

APP="hammer-editor"
var_tags="${var_tags:-writing;editor}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-2}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/hammer-editor/ ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  RELEASE=$(curl -fsSL https://api.github.com/repos/Wavesonics/hammer-editor/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3) }')
  if [[ ! -d /opt/hammer-editor/ ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]] || [[ ! -f /opt/${APP}_version.txt ]]; then
    msg_info "Stopping $APP"
    systemctl stop hammer-editor
    msg_ok "Stopped $APP"

    msg_info "Creating Backup"
    tar -czf "/opt/${APP}_backup_$(date +%F).tar.gz" /opt/hammer-editor/
    mv /opt/hammer-editor/ /opt/hammer-editor-backup/
    msg_ok "Backup Created"

    msg_info "Updating $APP to v${RELEASE}"
    curl -fsSL -o "${RELEASE}.zip" "https://github.com/Wavesonics/hammer-editor/releases/downloads/${RELEASE}/server.zip"
    unzip -q "${RELEASE}.zip"
    mv "hammer-editor-${RELEASE}/" "/opt/hammer-editor"
    rm -f "${RELEASE}.zip"
    msg_ok "Updated $APP to v${RELEASE}"

    msg_info "Starting $APP"
    systemctl start hammer-editor
    msg_ok "Started $APP"

    msg_info "Cleaning Up"
    rm -rf /opt/hammer-editor-backup
    msg_ok "Cleanup Completed"

    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Update Successful"
  else
    msg_ok "No update required. ${APP} is already at v${RELEASE}"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}"

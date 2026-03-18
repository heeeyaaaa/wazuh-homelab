#!/bin/bash
# copy-configs.sh
# Copies Wazuh config files from the current directory to the correct locations
# Run from the directory containing your config files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WAZUH_DIR="$HOME/wazuh-docker/single-node"
CLUSTER_DIR="$WAZUH_DIR/config/wazuh_cluster"

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${GREEN}[+]${NC} $*"; }
error() { echo -e "${RED}[-]${NC} $*"; exit 1; }
step()  { echo -e "\n${CYAN}━━ $* ━━${NC}"; }

step "Checking paths"
[[ -d "$WAZUH_DIR" ]] || error "Wazuh docker dir not found: $WAZUH_DIR"

# Ask for username to substitute in config paths
read -rp "Enter your Linux username (used for home directory paths): " TARGET_USER
TARGET_HOME="/home/$TARGET_USER"
[[ -d "$TARGET_HOME" ]] || error "Home directory not found: $TARGET_HOME"

step "Copying manager configs"
mkdir -p "$CLUSTER_DIR/rules" "$CLUSTER_DIR/integrations" "$CLUSTER_DIR/sca"
sudo chown -R "$USER:$USER" "$CLUSTER_DIR"

cp "$SCRIPT_DIR/ossec.conf"                        "$CLUSTER_DIR/wazuh_manager.conf"
info "ossec.conf → wazuh_manager.conf"

cp "$SCRIPT_DIR/local_rules.xml"                   "$CLUSTER_DIR/rules/local_rules.xml"
info "local_rules.xml"

sudo cp "$SCRIPT_DIR/wazuh-command.rules" /etc/audit/rules.d/wazuh-command.rules
sudo chmod 640 /etc/audit/rules.d/wazuh-command.rules
sudo sed -i "s|/home/heeeyaaa/|$TARGET_HOME/|g" /etc/audit/rules.d/wazuh-command.rules
info "wazuh-command.rules → /etc/audit/rules.d/"

cp "$SCRIPT_DIR/dangerous-commands"                "$CLUSTER_DIR/rules/dangerous-commands"
info "dangerous-commands"

cp "$SCRIPT_DIR/sca_detect_linux_keylogger.yml"    "$CLUSTER_DIR/sca/sca_detect_linux_keylogger.yml"
info "sca_detect_linux_keylogger.yml"

cp "$SCRIPT_DIR/custom-discord"                    "$CLUSTER_DIR/integrations/custom-discord"
cp "$SCRIPT_DIR/custom-discord.py"                 "$CLUSTER_DIR/integrations/custom-discord.py"
chmod 750 "$CLUSTER_DIR/integrations/custom-discord"
chmod 750 "$CLUSTER_DIR/integrations/custom-discord.py"
info "custom-discord / custom-discord.py"

step "Copying agent config"
if [[ ! -d /var/ossec ]]; then
    error "Wazuh agent not installed — install it first: yay -S wazuh-agent"
fi
sudo cp "$SCRIPT_DIR/agent.conf" /var/ossec/etc/ossec.conf
sudo sed -i "s|/home/heeeyaaa/|$TARGET_HOME/|g" /var/ossec/etc/ossec.conf
sudo chown root:wazuh /var/ossec/etc/ossec.conf
sudo chmod 640 /var/ossec/etc/ossec.conf
info "agent.conf → /var/ossec/etc/ossec.conf"

step "Done"
echo ""
info "All configs copied successfully"
echo ""

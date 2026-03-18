# Wazuh Homelab

Config files for setting up Wazuh monitoring on a personal Linux instance using Docker.

> 📖 Full setup guide: [heeeyaaa.github.io/posts/wazuh-homelab](https://heeeyaaa.github.io/posts/wazuh-homelab/)

## Prerequisites
- Arch Linux (or any systemd-based distro)
- Docker + docker-compose
- auditd
- yay (for Wazuh agent AUR package)
- Discord server with a webhook URL

## Usage
1. Clone this repo into your home directory
2. Edit `ossec.conf` — replace `CHANGE_ME_INDEXER_PASSWORD` with your indexer password
3. Edit `ossec.conf` — replace `YOUR-DISCORD-WEBHOOK-URL` with your webhook URL
4. Run the setup script:
```bash
   bash copy-configs.sh
```

## Files
| File                             | Description                                      |
| -------------------------------- | ------------------------------------------------ |
| `copy-configs.sh`                | Places all config files in the correct locations |
| `ossec.conf`                     | Wazuh manager config                             |
| `agent.conf`                     | Wazuh agent config                               |
| `local_rules.xml`                | Custom detection rules                           |
| `wazuh-command.rules`            | Auditd monitoring rules                          |
| `dangerous-commands`             | Commands to watch for execution                  |
| `sca_detect_linux_keylogger.yml` | SCA keylogger detection policy                   |
| `custom-discord`                 | Discord integration wrapper                      |
| `custom-discord.py`              | Discord integration script                       |

## Note
The suppression rules in `local_rules.xml` are specific to my desktop setup. Review and adjust them for your system before use.
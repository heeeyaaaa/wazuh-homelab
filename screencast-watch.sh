#!/usr/bin/env bash
LOG="/var/log/screencast/events.log"
mkdir -p "$(dirname "$LOG")" 2>/dev/null
umask 022
prev_apps=""
while :; do
  dump=$(pw-dump 2>/dev/null)
  # is the hyprland portal actively streaming the screen?
  streaming=$(jq -r '[.[] | select(.info.props."media.name" // "" | startswith("xdph-streaming"))] | length' <<< "$dump" 2>/dev/null)
  if [ "${streaming:-0}" -gt 0 ]; then
    # consumer apps: video-input nodes that aren't the portal itself
    cur_apps=$(jq -r '.[] | select(.info.props."media.class" == "Stream/Input/Video")
                        | .info.props."node.name"
                        | select(. != null and (startswith("xdg-desktop-portal") | not))' <<< "$dump" 2>/dev/null \
               | sort -u | tr '\n' ',')
  else
    cur_apps=""
  fi
  if [ "$cur_apps" != "$prev_apps" ]; then
    ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    for a in ${cur_apps//,/ }; do
      case ",$prev_apps," in *",$a,"*) ;; *)
        printf '%s screencast: event=SCREENCAST_START app=%s host=%s\n' "$ts" "$a" "$(hostname)" >> "$LOG" ;;
      esac
    done
    for a in ${prev_apps//,/ }; do
      case ",$cur_apps," in *",$a,"*) ;; *)
        printf '%s screencast: event=SCREENCAST_STOP app=%s host=%s\n' "$ts" "$a" "$(hostname)" >> "$LOG" ;;
      esac
    done
    prev_apps="$cur_apps"
  fi
  sleep 2
done

#!/bin/bash

DOCKER_HOSTS_START="# >>> DOCKER CONTAINERS >>>"
DOCKER_HOSTS_END="# <<< DOCKER CONTAINERS <<<"
HOSTS_FILE="/etc/hosts"
TMP_FILE="/tmp/docker_hosts.$$"

echo "🔄 Updating Docker container host mappings in /etc/hosts..."
echo "⚙️  Using markers to clean up old entries and add new ones."

# Backup existing hosts file
sudo cp "$HOSTS_FILE" "${HOSTS_FILE}.bak"

# Extract non-Docker lines from /etc/hosts
sudo awk "/$DOCKER_HOSTS_START/{f=1;next} /$DOCKER_HOSTS_END/{f=0;next} !f" "$HOSTS_FILE" > "$TMP_FILE"

# Add Docker header
echo "$DOCKER_HOSTS_START" >> "$TMP_FILE"

# Add fresh Docker container entries
docker ps --format "{{.Names}}" | while read container; do
    ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container")
    hostname=$(docker inspect -f '{{.Config.Hostname}}' "$container")

    if [ -n "$ip" ]; then
        line=$(printf "%-15s %s # container: %s" "$ip" "$hostname" "$container")
        echo "$line" >> "$TMP_FILE"
        echo "📝 Added: $line"
    fi
done

# Add Docker footer
echo "$DOCKER_HOSTS_END" >> "$TMP_FILE"

# Replace the original /etc/hosts with updated one
sudo cp "$TMP_FILE" "$HOSTS_FILE"
rm "$TMP_FILE"

echo "✅ Docker container hostnames updated in /etc/hosts"

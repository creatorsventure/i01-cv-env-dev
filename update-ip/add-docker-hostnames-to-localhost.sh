#!/bin/bash

DOCKER_HOSTS_START="# >>> DOCKER CONTAINERS - HOST ROUTING >>>"
DOCKER_HOSTS_END="# <<< DOCKER CONTAINERS - HOST ROUTING <<<"
HOSTS_FILE="/etc/hosts"
TMP_FILE="/tmp/docker_hosts.$$"
LOCAL_IP="127.0.0.1"

echo "🧠 Hardcoding IP as: $LOCAL_IP"
echo "🔄 Updating /etc/hosts to map Docker hostnames to localhost..."

# Backup once
sudo cp "$HOSTS_FILE" "${HOSTS_FILE}.bak"

# Remove old entries
sudo awk "/$DOCKER_HOSTS_START/{f=1;next} /$DOCKER_HOSTS_END/{f=0;next} !f" "$HOSTS_FILE" > "$TMP_FILE"

# Start block
echo "$DOCKER_HOSTS_START" >> "$TMP_FILE"

# Add entries
docker ps --format "{{.Names}}" | while read container; do
    hostname=$(docker inspect -f '{{.Config.Hostname}}' "$container")

    if [ -n "$hostname" ]; then
        line=$(printf "%-15s %-30s # container: %s" "$LOCAL_IP" "$hostname" "$container")
        echo "$line" >> "$TMP_FILE"
        echo "📝 Added: $line"
    fi
done

# End block
echo "$DOCKER_HOSTS_END" >> "$TMP_FILE"

# Apply it
sudo cp "$TMP_FILE" "$HOSTS_FILE"
rm "$TMP_FILE"

echo "✅ /etc/hosts updated with Docker hostnames pointing to localhost."

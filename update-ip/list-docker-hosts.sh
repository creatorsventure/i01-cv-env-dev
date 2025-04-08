#!/bin/bash

echo "🔍 Listing Docker container name, hostname, and IP address..."
echo "--------------------------------------------------------------"

docker ps --format "{{.Names}}" | while read container; do
    ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container")
    hostname=$(docker inspect -f '{{.Config.Hostname}}' "$container")

    if [ -n "$ip" ]; then
        printf "🟢 %-20s (hostname: %-25s) => %s\n" "$container" "$hostname" "$ip"
        # Uncomment below to generate /etc/hosts-style output
        # echo "$ip    $hostname"
    else
        echo "❌ No IP found for $container"
    fi
done

echo "--------------------------------------------------------------"
echo "✅ Done"

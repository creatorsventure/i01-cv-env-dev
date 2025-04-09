# list-docker-hosts.ps1
# This script lists container names and their IP addresses (Docker for Windows)

$containers = docker ps --format "{{.Names}}"

foreach ($container in $containers) {
    $inspect = docker inspect $container | ConvertFrom-Json
    $ip = $inspect[0].NetworkSettings.Networks.Values | ForEach-Object { $_.IPAddress }
    Write-Output "$container : $ip"
}

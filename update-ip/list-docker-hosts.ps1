# list-docker-hosts.ps1
# This script lists container names and their IP addresses (Docker for Windows)

# list-docker-hosts.ps1

$containers = docker ps --format "{{.Names}}"

foreach ($container in $containers) {
    $inspect = docker inspect $container | ConvertFrom-Json
    $networks = $inspect[0].NetworkSettings.Networks
    foreach ($network in $networks.Keys) {
        $ip = $networks[$network].IPAddress
        Write-Output "$container ($network): $ip"
    }
}

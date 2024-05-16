param (
    [string]$channelName
)

$baseDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$itchEmbed = "$baseDir\export\itch-embed"
$htmlDir = "$baseDir\export\web"
$winDir = "$baseDir\export\win_64"
$linuxDir = "$baseDir\export\linux_64"
$androidDir = "$baseDir\export\android_64"

$dirs = @{
    "html" = $htmlDir
    "embed" = $itchEmbed
    "win_64" = $winDir
    "linux_64" = $linuxDir
    "android_64" = $androidDir
}

if ($dirs.ContainsKey($channelName)) {
    butler push $dirs[$channelName] "immac/touhou-tcg-maker:$channelName"
}
else {
    foreach ($dir in $dirs.Values) {
        $channel = $dirs.Keys | Where-Object { $dirs[$_] -eq $dir }
        butler push $dir "immac/touhou-tcg-maker:$channel"
    }
}

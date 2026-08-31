$url = 'https://animeclipsraw.fr/sung-jin-woo-voice/'
$html = Invoke-RestMethod -Uri $url
$pattern = 'https://animeclipsraw\.fr/download/[^"''\s<>]+'
$matches = [regex]::Matches($html, $pattern)
foreach ($m in $matches) {
    Write-Output $m.Value
}

$pattern2 = 'https://animeclipsraw\.fr/[^"''\s<>]+\.mp3'
$matches2 = [regex]::Matches($html, $pattern2)
foreach ($m in $matches2) {
    Write-Output $m.Value
}

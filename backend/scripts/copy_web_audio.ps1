$srcAudio = "d:\projects\Winter arc routine\public\audio"
$srcSounds = "d:\projects\Winter arc routine\public\sounds"
$webAudio = "d:\projects\Winter arc routine\mobile\web\audio"
$webSounds = "d:\projects\Winter arc routine\mobile\web\sounds"

if (!(Test-Path $webAudio)) { New-Item -ItemType Directory -Force -Path $webAudio | Out-Null }
if (!(Test-Path $webSounds)) { New-Item -ItemType Directory -Force -Path $webSounds | Out-Null }

Copy-Item "$srcAudio\*" $webAudio -Force
Copy-Item "$srcSounds\*" $webSounds -Force

Write-Host "✅ Copied all audio files to mobile/web/audio and mobile/web/sounds"

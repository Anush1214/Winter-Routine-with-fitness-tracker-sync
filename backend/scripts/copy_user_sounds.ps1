$f1 = "C:\Users\lapto\Downloads\mixkit-select-click-1109.wav"
$f2 = "C:\Users\lapto\Downloads\mixkit-quick-win-video-game-notification-269.wav"
$f3 = "C:\Users\lapto\Downloads\mixkit-sci-fi-interface-robot-click-901.wav"

$mobileSounds = "d:\projects\Winter arc routine\mobile\assets\sounds"
$webSounds = "d:\projects\Winter arc routine\public\sounds"

if (!(Test-Path $mobileSounds)) { New-Item -ItemType Directory -Force -Path $mobileSounds | Out-Null }
if (!(Test-Path $webSounds)) { New-Item -ItemType Directory -Force -Path $webSounds | Out-Null }

if (Test-Path $f1) {
    Copy-Item $f1 "$mobileSounds\click.wav" -Force
    Copy-Item $f1 "$webSounds\click.wav" -Force
    Write-Host "✅ Copied click.wav"
} else {
    Write-Host "❌ $f1 not found"
}

if (Test-Path $f2) {
    Copy-Item $f2 "$mobileSounds\win.wav" -Force
    Copy-Item $f2 "$webSounds\win.wav" -Force
    Write-Host "✅ Copied win.wav"
} else {
    Write-Host "❌ $f2 not found"
}

if (Test-Path $f3) {
    Copy-Item $f3 "$mobileSounds\robot_click.wav" -Force
    Copy-Item $f3 "$webSounds\robot_click.wav" -Force
    Write-Host "✅ Copied robot_click.wav"
} else {
    Write-Host "❌ $f3 not found"
}

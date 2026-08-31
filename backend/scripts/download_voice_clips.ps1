$mobileDir = "d:\projects\Winter arc routine\mobile\assets\audio"
$webDir = "d:\projects\Winter arc routine\public\audio"

New-Item -ItemType Directory -Force -Path $mobileDir | Out-Null
New-Item -ItemType Directory -Force -Path $webDir | Out-Null

$urls = @(
    "https://animeclipsraw.fr/wp-content/uploads/2024/02/sung-jin-woo-voice1.mp3",
    "https://animeclipsraw.fr/wp-content/uploads/2024/02/sung-jin-woo-voice2.mp3",
    "https://animeclipsraw.fr/wp-content/uploads/2024/02/sung-jin-woo-voice3.mp3",
    "https://animeclipsraw.fr/wp-content/uploads/2024/02/sung-jin-woo-voice4.mp3",
    "https://animeclipsraw.fr/wp-content/uploads/2024/02/sung-jin-woo-voice5.mp3",
    "https://animeclipsraw.fr/wp-content/uploads/2024/02/sung-jin-woo-voice6.mp3"
)

$index = 1
foreach ($u in $urls) {
    $outFileMobile = "$mobileDir\sung_jinwoo_voice$index.mp3"
    $outFileWeb = "$webDir\sung_jinwoo_voice$index.mp3"
    Write-Host "Downloading $u ..."
    Invoke-WebRequest -Uri $u -OutFile $outFileMobile -UserAgent "Mozilla/5.0"
    Copy-Item $outFileMobile $outFileWeb -Force
    $index++
}

Write-Host "✅ All authentic Sung Jin-Woo anime voice files downloaded successfully!"

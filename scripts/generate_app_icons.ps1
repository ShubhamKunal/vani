Add-Type -AssemblyName System.Drawing

$sourcePath = (Resolve-Path "assets\icons\vani_app_icon.png").Path
$srcBmp = [System.Drawing.Bitmap]::FromFile($sourcePath)

function Resize-And-Save($targetPath, $width, $height) {
    $destRect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
    $destImage = New-Object System.Drawing.Bitmap($width, $height)
    $destImage.SetResolution($srcBmp.HorizontalResolution, $srcBmp.VerticalResolution)
    $graphics = [System.Drawing.Graphics]::FromImage($destImage)
    $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.DrawImage($srcBmp, $destRect, 0, 0, $srcBmp.Width, $srcBmp.Height, [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.Dispose()
    
    $dir = [System.IO.Path]::GetDirectoryName($targetPath)
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    $destImage.Save($targetPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $destImage.Dispose()
    Write-Output "Generated: $targetPath ($width x $height)"
}

# Android mipmap icons
Resize-And-Save "android\app\src\main\res\mipmap-mdpi\ic_launcher.png" 48 48
Resize-And-Save "android\app\src\main\res\mipmap-hdpi\ic_launcher.png" 72 72
Resize-And-Save "android\app\src\main\res\mipmap-xhdpi\ic_launcher.png" 96 96
Resize-And-Save "android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png" 144 144
Resize-And-Save "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png" 192 192

# iOS icons
$iosDir = "ios\Runner\Assets.xcassets\AppIcon.appiconset"
Resize-And-Save "$iosDir\Icon-App-20x20@1x.png" 20 20
Resize-And-Save "$iosDir\Icon-App-20x20@2x.png" 40 40
Resize-And-Save "$iosDir\Icon-App-20x20@3x.png" 60 60
Resize-And-Save "$iosDir\Icon-App-29x29@1x.png" 29 29
Resize-And-Save "$iosDir\Icon-App-29x29@2x.png" 58 58
Resize-And-Save "$iosDir\Icon-App-29x29@3x.png" 87 87
Resize-And-Save "$iosDir\Icon-App-40x40@1x.png" 40 40
Resize-And-Save "$iosDir\Icon-App-40x40@2x.png" 80 80
Resize-And-Save "$iosDir\Icon-App-40x40@3x.png" 120 120
Resize-And-Save "$iosDir\Icon-App-60x60@2x.png" 120 120
Resize-And-Save "$iosDir\Icon-App-60x60@3x.png" 180 180
Resize-And-Save "$iosDir\Icon-App-76x76@1x.png" 76 76
Resize-And-Save "$iosDir\Icon-App-76x76@2x.png" 152 152
Resize-And-Save "$iosDir\Icon-App-83.5x83.5@2x.png" 167 167
Resize-And-Save "$iosDir\Icon-App-1024x1024@1x.png" 1024 1024

$srcBmp.Dispose()
Write-Output "App icon generation completed successfully!"


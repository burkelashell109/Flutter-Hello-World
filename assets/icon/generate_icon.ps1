# PowerShell script to create a simple app icon
# Creates a basic PNG image using .NET System.Drawing

Add-Type -AssemblyName System.Drawing

# Create bitmap
$bitmap = New-Object System.Drawing.Bitmap(1024, 1024)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

# Enable anti-aliasing
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Create brushes and pens
$backgroundBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(248, 249, 250))
$borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(222, 226, 230), 8)
$redBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 59, 48))
$blueBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 122, 255))

# Draw circular background
$graphics.FillEllipse($backgroundBrush, 32, 32, 960, 960)
$graphics.DrawEllipse($borderPen, 32, 32, 960, 960)

# Create fonts
try {
    $font = New-Object System.Drawing.Font("Arial", 180, [System.Drawing.FontStyle]::Bold)
} catch {
    $font = New-Object System.Drawing.Font("Microsoft Sans Serif", 180, [System.Drawing.FontStyle]::Bold)
}

# Draw "Hello" text
$helloText = "Hello"
$helloSize = $graphics.MeasureString($helloText, $font)
$helloX = 512 - ($helloSize.Width / 2)
$helloY = 350

# Rotate graphics for "Hello"
$graphics.TranslateTransform(512, 390)
$graphics.RotateTransform(-8)
$graphics.DrawString($helloText, $font, $redBrush, -($helloSize.Width / 2), -($helloSize.Height / 2))
$graphics.ResetTransform()

# Draw "World" text
$worldText = "World"
$worldSize = $graphics.MeasureString($worldText, $font)
$worldX = 512 - ($worldSize.Width / 2)
$worldY = 550

# Rotate graphics for "World"
$graphics.TranslateTransform(512, 580)
$graphics.RotateTransform(5)
$graphics.DrawString($worldText, $font, $blueBrush, -($worldSize.Width / 2), -($worldSize.Height / 2))
$graphics.ResetTransform()

# Save the image
$bitmap.Save("icon.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Clean up
$graphics.Dispose()
$bitmap.Dispose()
$backgroundBrush.Dispose()
$borderPen.Dispose()
$redBrush.Dispose()
$blueBrush.Dispose()
$font.Dispose()

Write-Host "Icon generated successfully as icon.png"

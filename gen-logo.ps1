Add-Type -AssemblyName System.Drawing
$outDir = 'c:\Users\hp\Desktop\web\images'

# ── Download Playfair Display Bold ──
$fontUrl = 'https://github.com/google/fonts/raw/main/ofl/playfairdisplay/PlayfairDisplay%5Bwght%5D.ttf'
$fontPath = Join-Path $env:TEMP 'PlayfairDisplay.ttf'
if (-not (Test-Path $fontPath)) {
    Write-Host 'Downloading Playfair Display font...'
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $fontUrl -OutFile $fontPath -UseBasicParsing
}
$pfc = New-Object System.Drawing.Text.PrivateFontCollection
$pfc.AddFontFile($fontPath)
$fontFamily = $pfc.Families[0]
Write-Host "Loaded font: $($fontFamily.Name)"

function New-Mr7li0Logo([int]$size, [bool]$circle=$false, $fontFamily) {
    $bmp = New-Object System.Drawing.Bitmap($size,$size,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $bg = [System.Drawing.ColorTranslator]::FromHtml('#020617')
    if ($circle) {
        $g.Clear([System.Drawing.Color]::Transparent)
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $path.AddEllipse(0,0,$size-1,$size-1)
        $g.SetClip($path)
        $g.Clear($bg)
        # ── Subtle purple radial glow ──
        $glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
        $glowR = [int]($size * 0.55)
        $cx = [int]($size / 2); $cy = [int]($size / 2)
        $glowRect = New-Object System.Drawing.Rectangle(($cx - $glowR),($cy - $glowR),($glowR*2),($glowR*2))
        $glowPath.AddEllipse($glowRect)
        $glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
        $glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(38,99,102,241)
        $glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0,99,102,241))
        $g.FillEllipse($glowBrush,$glowRect)
        $glowBrush.Dispose(); $glowPath.Dispose()
        $g.ResetClip()
        $path.Dispose()
    } else {
        $g.Clear($bg)
        # ── Subtle purple radial glow (rectangle) ──
        $glowPath2 = New-Object System.Drawing.Drawing2D.GraphicsPath
        $glowR2 = [int]($size * 0.55)
        $cx2 = [int]($size / 2); $cy2 = [int]($size / 2)
        $glowRect2 = New-Object System.Drawing.Rectangle(($cx2 - $glowR2),($cy2 - $glowR2),($glowR2*2),($glowR2*2))
        $glowPath2.AddEllipse($glowRect2)
        $glowBrush2 = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath2)
        $glowBrush2.CenterColor = [System.Drawing.Color]::FromArgb(38,99,102,241)
        $glowBrush2.SurroundColors = @([System.Drawing.Color]::FromArgb(0,99,102,241))
        $g.FillEllipse($glowBrush2,$glowRect2)
        $glowBrush2.Dispose(); $glowPath2.Dispose()
    }
    $rect = New-Object System.Drawing.RectangleF(0,0,$size,$size)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect,[System.Drawing.Color]::White,[System.Drawing.ColorTranslator]::FromHtml('#6366f1'),[System.Drawing.Drawing2D.LinearGradientMode]::Horizontal)
    $fontSize = [Math]::Floor($size * 0.22)
    $font = New-Object System.Drawing.Font($fontFamily,$fontSize,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Pixel)
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $sf.FormatFlags = [System.Drawing.StringFormatFlags]::NoWrap
    $g.DrawString('mr7li0',$font,$brush,$rect,$sf)
    $font.Dispose(); $brush.Dispose(); $sf.Dispose(); $g.Dispose()
    return $bmp
}

# 1) Large circular logo (no border)
$logo = New-Mr7li0Logo -size 1024 -circle $true -fontFamily $fontFamily
$logo.Save((Join-Path $outDir 'mr7li0-logo.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$logo.Dispose()
Write-Host 'Created mr7li0-logo.png'

# 2) Wide OG image (no border)
$wide = New-Object System.Drawing.Bitmap(1200,630,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$gw = [System.Drawing.Graphics]::FromImage($wide)
$gw.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gw.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$gw.Clear([System.Drawing.ColorTranslator]::FromHtml('#020617'))
# ── Purple glow for OG ──
$ogGlowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$ogGlowR = 300
$ogGlowRect = New-Object System.Drawing.Rectangle((600 - $ogGlowR),(315 - $ogGlowR),($ogGlowR*2),($ogGlowR*2))
$ogGlowPath.AddEllipse($ogGlowRect)
$ogGlowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($ogGlowPath)
$ogGlowBrush.CenterColor = [System.Drawing.Color]::FromArgb(38,99,102,241)
$ogGlowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0,99,102,241))
$gw.FillEllipse($ogGlowBrush,$ogGlowRect)
$ogGlowBrush.Dispose(); $ogGlowPath.Dispose()
$rect2 = New-Object System.Drawing.RectangleF(0,0,1200,630)
$brush2 = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect2,[System.Drawing.Color]::White,[System.Drawing.ColorTranslator]::FromHtml('#6366f1'),[System.Drawing.Drawing2D.LinearGradientMode]::Horizontal)
$font2 = New-Object System.Drawing.Font($fontFamily,120,[System.Drawing.FontStyle]::Bold,[System.Drawing.GraphicsUnit]::Pixel)
$sf2 = New-Object System.Drawing.StringFormat
$sf2.Alignment = [System.Drawing.StringAlignment]::Center
$sf2.LineAlignment = [System.Drawing.StringAlignment]::Center
$sf2.FormatFlags = [System.Drawing.StringFormatFlags]::NoWrap
$gw.DrawString('mr7li0',$font2,$brush2,$rect2,$sf2)
$font2.Dispose(); $brush2.Dispose(); $sf2.Dispose(); $gw.Dispose()
$wide.Save((Join-Path $outDir 'mr7li0-og.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$wide.Dispose()
Write-Host 'Created mr7li0-og.png'

# 3) Favicon sizes
$master = [System.Drawing.Image]::FromFile((Join-Path $outDir 'mr7li0-logo.png'))
foreach ($s in @(32,180,192,512)) {
    $b = New-Object System.Drawing.Bitmap($s,$s,[System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $gr = [System.Drawing.Graphics]::FromImage($b)
    $gr.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $gr.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $gr.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $gr.Clear([System.Drawing.Color]::Transparent)
    $gr.DrawImage($master,0,0,$s,$s)
    $gr.Dispose()
    $name = switch($s){ 32{'favicon-32.png'} 180{'apple-touch-icon.png'} 192{'favicon-192.png'} 512{'favicon-512.png'} }
    $b.Save((Join-Path $outDir $name),[System.Drawing.Imaging.ImageFormat]::Png)
    $b.Dispose()
    Write-Host "Created $name"
}
$master.Dispose()
$pfc.Dispose()
Write-Host 'All done!'

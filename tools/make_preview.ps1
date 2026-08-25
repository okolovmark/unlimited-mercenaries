$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$size = 512
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# background: dark vertical gradient
$rect = New-Object System.Drawing.Rectangle(0,0,$size,$size)
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::FromArgb(46,34,20), [System.Drawing.Color]::FromArgb(12,9,6), 90)
$g.FillRectangle($bgBrush, $rect)

# subtle radial glow behind emblem
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddEllipse(96, 130, 320, 320)
$glow = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
$glow.CenterColor = [System.Drawing.Color]::FromArgb(70, 212, 175, 55)
$glow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 212, 175, 55))
$g.FillEllipse($glow, 96, 130, 320, 320)

$gold = [System.Drawing.Color]::FromArgb(212,175,55)
$goldDim = [System.Drawing.Color]::FromArgb(150,120,45)
$goldPen = New-Object System.Drawing.Pen($gold, 3)
$thinPen = New-Object System.Drawing.Pen($goldDim, 1)

# double frame
$g.DrawRectangle($goldPen, 10, 10, $size-21, $size-21)
$g.DrawRectangle($thinPen, 20, 20, $size-41, $size-41)

# corner diamonds
$goldBrush = New-Object System.Drawing.SolidBrush($gold)
$corners = @()
$corners += ,(10,10)
$corners += ,(501,10)
$corners += ,(10,501)
$corners += ,(501,501)
foreach ($c in $corners) {
    $cx = [int]$c[0]; $cy = [int]$c[1]
    $pts = @(
        (New-Object System.Drawing.PointF($cx, ($cy-9))),
        (New-Object System.Drawing.PointF(($cx+9), $cy)),
        (New-Object System.Drawing.PointF($cx, ($cy+9))),
        (New-Object System.Drawing.PointF(($cx-9), $cy))
    )
    $g.FillPolygon($goldBrush, $pts)
}

$black = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200,0,0,0))
$grayBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(170,150,130))
$fmt = New-Object System.Drawing.StringFormat
$fmt.Alignment = [System.Drawing.StringAlignment]::Center

function Draw-Text([string]$text, [System.Drawing.Font]$font, [System.Drawing.Brush]$brush, [single]$y) {
    $g.DrawString($text, $font, $black, [single]($size/2 + 3), [single]($y + 3), $fmt)
    $g.DrawString($text, $font, $brush, [single]($size/2), [single]$y, $fmt)
}

$titleFont1 = New-Object System.Drawing.Font("Georgia", 42, [System.Drawing.FontStyle]::Bold)
$titleFont2 = New-Object System.Drawing.Font("Georgia", 33, [System.Drawing.FontStyle]::Bold)
$emblemFont = New-Object System.Drawing.Font("Georgia", 150, [System.Drawing.FontStyle]::Bold)
$smallFont  = New-Object System.Drawing.Font("Georgia", 20, [System.Drawing.FontStyle]::Bold)
$tinyFont   = New-Object System.Drawing.Font("Georgia", 13, [System.Drawing.FontStyle]::Regular)

Draw-Text "UNLIMITED" $titleFont1 $goldBrush 42
Draw-Text "MERCENARIES" $titleFont2 $goldBrush 110

# separator ornament
$g.DrawLine($goldPen, 90, 172, 210, 172)
$g.DrawLine($goldPen, 302, 172, 422, 172)
$pts = @(
    (New-Object System.Drawing.PointF(256, 163)),
    (New-Object System.Drawing.PointF(268, 172)),
    (New-Object System.Drawing.PointF(256, 181)),
    (New-Object System.Drawing.PointF(244, 172))
)
$g.FillPolygon($goldBrush, $pts)

# emblem: infinity
Draw-Text ([string][char]0x221E) $emblemFont $goldBrush 158

# bottom captions
Draw-Text "PLAYER  ONLY" $smallFont $goldBrush 412
$g.DrawString("Total War: WARHAMMER III", $tinyFont, $grayBrush, [single]($size/2), [single]458, $fmt)

$out = "C:\Users\okolo\Downloads\unlimited-mercenaries\preview.png"
$g.Dispose()
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "saved $out ($((Get-Item $out).Length) bytes)"

Add-Type -AssemblyName System.Drawing
$png = [System.Drawing.Image]::FromFile('c:\Users\hp\Desktop\web\images\favicon-32.png')
$bmp = New-Object System.Drawing.Bitmap($png, 32, 32)
$ms = New-Object System.IO.MemoryStream
$bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
$pngBytes = $ms.ToArray()

$ico = New-Object System.IO.FileStream('c:\Users\hp\Desktop\web\favicon.ico', [System.IO.FileMode]::Create)
$bw = New-Object System.IO.BinaryWriter($ico)

# ICO header
$bw.Write([UInt16]0)              # reserved
$bw.Write([UInt16]1)              # type: icon
$bw.Write([UInt16]1)              # count: 1 image

# ICO directory entry
$bw.Write([byte]32)               # width
$bw.Write([byte]32)               # height
$bw.Write([byte]0)                # color palette
$bw.Write([byte]0)                # reserved
$bw.Write([UInt16]1)              # color planes
$bw.Write([UInt16]32)             # bits per pixel
$bw.Write([UInt32]$pngBytes.Length) # image size
$bw.Write([UInt32]22)             # offset to image data

# Image data (PNG)
$bw.Write($pngBytes)
$bw.Flush()
$ico.Close()
$bmp.Dispose()
$png.Dispose()
$ms.Dispose()
Write-Host 'favicon.ico created'

#requires -Version 5.1

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$MetaUrl = 'https://downloads.jhakorn.com/bootstrap/current.json'
$AllowedDownloadHost = 'downloads.jhakorn.com'
$AllowedDownloadPath = '/bootstrap/'
$ExpectedRootThumbprint = 'D216D164EEEB23FE33D1ADD4EA0A2AE083CCA72B'
$ExpectedPublisherThumbprint = 'CD5AD19E302516095CEFF000DE36946F3BC68F11'
$TemporaryRoot = [System.IO.Path]::GetTempPath()
$BootstrapDirectory = $null

function Test-JhakornCertificate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StoreName,

        [Parameter(Mandatory = $true)]
        [string]$Thumbprint
    )

    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $StoreName, 'LocalMachine'
    try {
        $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
        return @($store.Certificates | Where-Object { $_.Thumbprint -eq $Thumbprint }).Count -gt 0
    }
    finally {
        $store.Close()
    }
}

function Assert-JhakornRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $normalized = $Path.Replace('\', '/')
    $segments = @($normalized.Split('/') | Where-Object { $_ -ne '' })
    if (
        [string]::IsNullOrWhiteSpace($normalized) -or
        [System.IO.Path]::IsPathRooted($Path) -or
        $normalized.StartsWith('/') -or
        $segments -contains '..'
    ) {
        throw "Ruta no permitida en ${Context}: $Path"
    }

    return $normalized
}

function Resolve-JhakornChildPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,

        [Parameter(Mandatory = $true)]
        [string]$RelativePath,

        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $normalized = Assert-JhakornRelativePath -Path $RelativePath -Context $Context
    $rootFullPath = [System.IO.Path]::GetFullPath($Root)
    $rootPrefix = $rootFullPath.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    $platformRelativePath = $normalized.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $rootFullPath $platformRelativePath))

    if (-not $candidate.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Ruta fuera del directorio permitido en ${Context}: $RelativePath"
    }

    return $candidate
}

function Expand-JhakornArchiveSafely {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArchivePath,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($ArchivePath)
    try {
        foreach ($entry in $archive.Entries) {
            $entryName = [string]$entry.FullName
            if ([string]::IsNullOrEmpty($entryName)) {
                continue
            }

            [void](Resolve-JhakornChildPath -Root $DestinationPath -RelativePath $entryName -Context 'el ZIP')
        }
    }
    finally {
        $archive.Dispose()
    }

    Expand-Archive -LiteralPath $ArchivePath -DestinationPath $DestinationPath -Force
}

try {
    Write-Host ''
    Write-Host '========================================='
    Write-Host '       WPI JHAKORN - INICIANDO'
    Write-Host '========================================='
    Write-Host ''

    Write-Host '[1/8] Consultando version actual...'
    $metadata = Invoke-RestMethod -Uri $MetaUrl

    $version = [string]$metadata.version
    $downloadUrl = [string]$metadata.url
    $expectedZipHash = [string]$metadata.sha256

    if ($version -notmatch '^\d+\.\d+\.\d+$') {
        throw "Version invalida recibida: $version"
    }

    $downloadUri = $null
    if (-not [System.Uri]::TryCreate($downloadUrl, [System.UriKind]::Absolute, [ref]$downloadUri)) {
        throw "URL de descarga invalida: $downloadUrl"
    }

    $decodedDownloadPath = [System.Uri]::UnescapeDataString($downloadUri.AbsolutePath).Replace('\', '/')
    $downloadSegments = @($decodedDownloadPath.Split('/') | Where-Object { $_ -ne '' })
    if (
        $downloadUri.Scheme -ne 'https' -or
        $downloadUri.Host -ne $AllowedDownloadHost -or
        (-not $downloadUri.IsDefaultPort -and $downloadUri.Port -ne 443) -or
        -not [string]::IsNullOrEmpty($downloadUri.UserInfo) -or
        -not $decodedDownloadPath.StartsWith($AllowedDownloadPath, [System.StringComparison]::Ordinal) -or
        $downloadSegments -contains '..'
    ) {
        throw "URL de descarga no permitida: $downloadUrl"
    }

    if ($expectedZipHash -notmatch '^[A-Fa-f0-9]{64}$') {
        throw 'SHA256 invalido en current.json.'
    }
    $expectedZipHash = $expectedZipHash.ToUpperInvariant()
    Write-Host "      Version: $version"

    Write-Host '[2/8] Preparando archivos temporales...'
    $BootstrapDirectory = Join-Path $TemporaryRoot ('JHAKORN-WPI-' + $version + '-' + [Guid]::NewGuid().ToString('N'))
    $zipPath = Join-Path $BootstrapDirectory 'WPI-JHAKORN.zip'
    $extractPath = Join-Path $BootstrapDirectory 'WPI'
    $manifestPath = Join-Path $extractPath 'SHA256SUMS.txt'
    [void](New-Item -ItemType Directory -Path $BootstrapDirectory)

    Write-Host '[3/8] Descargando WPI...'
    Invoke-WebRequest -Uri $downloadUri.AbsoluteUri -OutFile $zipPath

    Write-Host '[4/8] Verificando integridad del paquete...'
    $actualZipHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actualZipHash -ne $expectedZipHash) {
        throw "SHA256 del paquete incorrecto. Esperado=$expectedZipHash; obtenido=$actualZipHash."
    }
    Write-Host '      SHA256 del ZIP: OK'

    Write-Host '[5/8] Extrayendo WPI...'
    Expand-JhakornArchiveSafely -ArchivePath $zipPath -DestinationPath $extractPath
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        throw 'El paquete no contiene SHA256SUMS.txt.'
    }

    Write-Host '[6/8] Verificando archivos internos...'
    $manifestEntries = 0
    foreach ($lineFromManifest in Get-Content -LiteralPath $manifestPath) {
        $line = $lineFromManifest.TrimEnd("`r")
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }
        if ($line -notmatch '^([A-Fa-f0-9]{64}) [ *](.+)$') {
            throw "Linea invalida en SHA256SUMS.txt: $line"
        }

        $expectedFileHash = $Matches[1].ToUpperInvariant()
        $relativePath = Assert-JhakornRelativePath -Path $Matches[2] -Context 'SHA256SUMS.txt'
        $targetPath = Resolve-JhakornChildPath -Root $extractPath -RelativePath $relativePath -Context 'SHA256SUMS.txt'
        if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
            throw "Falta un archivo del manifiesto: $relativePath"
        }

        $actualFileHash = (Get-FileHash -LiteralPath $targetPath -Algorithm SHA256).Hash.ToUpperInvariant()
        if ($actualFileHash -ne $expectedFileHash) {
            throw "SHA256 incorrecto: $relativePath"
        }
        $manifestEntries++
    }

    if ($manifestEntries -eq 0) {
        throw 'SHA256SUMS.txt no contiene archivos.'
    }
    Write-Host "      Archivos verificados: $manifestEntries"

    Write-Host '[7/8] Comprobando confianza JHAKORN...'
    $trustScript = Join-Path $extractPath 'Bootstrap\Preparar-Confianza-JHAKORN.ps1'
    if (-not (Test-Path -LiteralPath $trustScript -PathType Leaf)) {
        throw 'No se encontro Preparar-Confianza-JHAKORN.ps1.'
    }

    $rootTrusted = Test-JhakornCertificate -StoreName 'Root' -Thumbprint $ExpectedRootThumbprint
    $publisherTrusted = Test-JhakornCertificate -StoreName 'TrustedPublisher' -Thumbprint $ExpectedPublisherThumbprint
    if (-not $rootTrusted -or -not $publisherTrusted) {
        Write-Host '      La confianza JHAKORN debe instalarse.'
        Write-Host '      Windows solicitara permisos de administrador.'
        $elevatedProcess = Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList @(
            '-NoLogo'
            '-NoProfile'
            '-ExecutionPolicy', 'Bypass'
            '-File', ('"{0}"' -f $trustScript)
            '-NoLaunch'
        ) -PassThru -Wait -ErrorAction Stop

        if ($elevatedProcess.ExitCode -ne 0) {
            throw "La instalacion de confianza finalizo con codigo $($elevatedProcess.ExitCode)."
        }
    }
    else {
        Write-Host '      Confianza JHAKORN ya instalada; no se solicitara elevacion.'
    }

    $rootTrusted = Test-JhakornCertificate -StoreName 'Root' -Thumbprint $ExpectedRootThumbprint
    $publisherTrusted = Test-JhakornCertificate -StoreName 'TrustedPublisher' -Thumbprint $ExpectedPublisherThumbprint
    if (-not $rootTrusted -or -not $publisherTrusted) {
        throw 'La confianza JHAKORN no quedo instalada correctamente.'
    }

    Write-Host '[8/8] Verificando y abriendo WPI JHAKORN...'
    Write-Host ''
    & $trustScript
    Write-Host ''
    Write-Host 'WPI JHAKORN finalizo correctamente.'
}
catch {
    Write-Host ''
    Write-Host '========================================='
    Write-Host '          WPI JHAKORN - ERROR'
    Write-Host '========================================='
    Write-Host ''
    Write-Host $_.Exception.Message
    Write-Host ''
    throw
}
finally {
    if ($null -ne $BootstrapDirectory -and (Test-Path -LiteralPath $BootstrapDirectory)) {
        try {
            Remove-Item -LiteralPath $BootstrapDirectory -Recurse -Force -ErrorAction Stop
        }
        catch {
            Write-Warning "No se pudo limpiar la carpeta temporal '$BootstrapDirectory': $($_.Exception.Message)"
        }
    }
}

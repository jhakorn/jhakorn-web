#requires -Version 5.1
<#
.SYNOPSIS
    Fuente de desarrollo del bootstrap publico de WPI JHAKORN para la familia v2.2.x.

.NOTES
    Este archivo no esta publicado. Tras aprobar, firmar y empaquetar una
    version compatible de WPI v2.2.x, su contenido podra sustituir de forma
    controlada scripts/wpi.ps1 en el repositorio de Cloudflare Pages.
#>
[CmdletBinding()]
param([switch]$LibraryOnly)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$script:MetaUrl = 'https://downloads.jhakorn.com/bootstrap/current.json'
$script:AllowedDownloadHost = 'downloads.jhakorn.com'
$script:AllowedDownloadPath = '/bootstrap/'
$script:ExpectedRootThumbprint = 'D216D164EEEB23FE33D1ADD4EA0A2AE083CCA72B'
$script:ExpectedPublisherThumbprint = 'CD5AD19E302516095CEFF000DE36946F3BC68F11'

function Get-JhakornBootstrapWorkspacePlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ProgramDataPath,
        [Parameter(Mandatory = $true)][System.Security.Principal.SecurityIdentifier]$UserSid,
        [Parameter(Mandatory = $true)][string]$Version,
        [string]$RunId = ([Guid]::NewGuid().ToString('N'))
    )

    if ([string]::IsNullOrWhiteSpace($ProgramDataPath) -or -not [System.IO.Path]::IsPathRooted($ProgramDataPath)) {
        throw "ProgramData no es una ruta absoluta valida: $ProgramDataPath"
    }
    if ($Version -notmatch '^\d+\.\d+\.\d+$') { throw "Version invalida para la zona provisional: $Version" }
    if ($RunId -notmatch '^[A-Fa-f0-9]{32}$') { throw "Identificador invalido para la zona provisional: $RunId" }

    $programDataRoot = [System.IO.Path]::GetFullPath($ProgramDataPath).TrimEnd('\', '/')
    $stagingBase = Join-Path $programDataRoot 'JHAKORN\WPI\Bootstrap\Staging'
    $userBase = Join-Path $stagingBase $UserSid.Value
    $workspaceRoot = Join-Path $userBase ($Version + '-' + $RunId.ToLowerInvariant())
    $expectedPrefix = $programDataRoot + [System.IO.Path]::DirectorySeparatorChar
    if (-not $workspaceRoot.StartsWith($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'La zona provisional calculada queda fuera de ProgramData.'
    }
    [pscustomobject]@{
        PSTypeName='Wpi.BootstrapWorkspacePlan'
        ProgramDataRoot=$programDataRoot
        StagingBase=$stagingBase
        UserBase=$userBase
        Ruta=$workspaceRoot
        UserSid=$UserSid.Value
        Version=$Version
        RunId=$RunId.ToLowerInvariant()
    }
}

function New-JhakornBootstrapWorkspace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Version,
        [string]$ProgramDataPath = $env:ProgramData,
        [System.Security.Principal.SecurityIdentifier]$UserSid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User,
        [string]$RunId = ([Guid]::NewGuid().ToString('N'))
    )

    $plan = Get-JhakornBootstrapWorkspacePlan -ProgramDataPath $ProgramDataPath -UserSid $UserSid -Version $Version -RunId $RunId
    $currentPath = $plan.ProgramDataRoot
    foreach ($segment in @('JHAKORN','WPI','Bootstrap','Staging',$plan.UserSid)) {
        $currentPath = Join-Path $currentPath $segment
        if (Test-Path -LiteralPath $currentPath) {
            $item = Get-Item -LiteralPath $currentPath -Force -ErrorAction Stop
            if (-not $item.PSIsContainer) { throw "La ruta provisional contiene un elemento que no es carpeta: $currentPath" }
            if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw "La ruta provisional contiene un punto de reanalisis no permitido: $currentPath"
            }
        }
        else {
            [void](New-Item -ItemType Directory -Path $currentPath -ErrorAction Stop)
        }
    }
    if (Test-Path -LiteralPath $plan.Ruta) { throw "La zona provisional ya existe y no se reutilizara: $($plan.Ruta)" }

    [void](New-Item -ItemType Directory -Path $plan.Ruta -ErrorAction Stop)
    try {
        $workspaceItem = Get-Item -LiteralPath $plan.Ruta -Force -ErrorAction Stop
        if (($workspaceItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "La zona provisional es un punto de reanalisis no permitido: $($plan.Ruta)"
        }

        $administratorsSid = New-Object System.Security.Principal.SecurityIdentifier -ArgumentList 'S-1-5-32-544'
        $systemSid = New-Object System.Security.Principal.SecurityIdentifier -ArgumentList 'S-1-5-18'
        $inheritance = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
        $acl = New-Object System.Security.AccessControl.DirectorySecurity
        $acl.SetAccessRuleProtection($true, $false)
        $acl.SetOwner($UserSid)
        foreach ($identity in @($UserSid,$administratorsSid,$systemSid)) {
            $rule = New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList @(
                $identity,
                [System.Security.AccessControl.FileSystemRights]::FullControl,
                $inheritance,
                [System.Security.AccessControl.PropagationFlags]::None,
                [System.Security.AccessControl.AccessControlType]::Allow
            )
            [void]$acl.AddAccessRule($rule)
        }
        Set-Acl -LiteralPath $plan.Ruta -AclObject $acl -ErrorAction Stop

        $effectiveAcl = Get-Acl -LiteralPath $plan.Ruta -ErrorAction Stop
        if (-not $effectiveAcl.AreAccessRulesProtected) { throw 'No se pudo proteger la ACL de la zona provisional.' }
        $requiredSids = @($UserSid.Value,$administratorsSid.Value,$systemSid.Value)
        $grantedSids = @($effectiveAcl.Access | Where-Object {
            $_.AccessControlType -eq [System.Security.AccessControl.AccessControlType]::Allow -and
            ($_.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::FullControl) -eq [System.Security.AccessControl.FileSystemRights]::FullControl
        } | ForEach-Object { $_.IdentityReference.Translate([System.Security.Principal.SecurityIdentifier]).Value })
        foreach ($requiredSid in $requiredSids) {
            if ($requiredSid -notin $grantedSids) { throw "Falta acceso requerido en la zona provisional para SID $requiredSid." }
        }
        return $plan
    }
    catch {
        if (Test-Path -LiteralPath $plan.Ruta) {
            Remove-Item -LiteralPath $plan.Ruta -Recurse -Force -ErrorAction SilentlyContinue
        }
        throw
    }
}

function Test-JhakornBootstrapAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-JhakornExecutionPolicyPlan {
    [CmdletBinding()]
    param(
        [AllowEmptyString()][string]$MachinePolicy = 'Undefined',
        [AllowEmptyString()][string]$UserPolicy = 'Undefined',
        [AllowEmptyString()][string]$CurrentUser = 'Undefined',
        [AllowEmptyString()][string]$LocalMachine = 'Undefined'
    )

    $machine = if ([string]::IsNullOrWhiteSpace($MachinePolicy)) { 'Undefined' } else { $MachinePolicy }
    $user = if ([string]::IsNullOrWhiteSpace($UserPolicy)) { 'Undefined' } else { $UserPolicy }
    $gpoDefined = $machine -ne 'Undefined' -or $user -ne 'Undefined'
    [pscustomobject]@{
        PSTypeName='Wpi.BootstrapExecutionPolicyPlan'
        Permitido=(-not $gpoDefined)
        MachinePolicy=$machine
        UserPolicy=$user
        CurrentUser=$CurrentUser
        LocalMachine=$LocalMachine
        PoliticaProceso='Bypass temporal restaurado'
        ModificaProcesoTemporal=$true
        ModificaCurrentUser=$false
        ModificaLocalMachine=$false
        Mensaje=if ($gpoDefined) {
            "Existe una politica de grupo explicita (MachinePolicy=$machine; UserPolicy=$user). El bootstrap no intentara omitirla. Consulte al administrador."
        } else {
            'No existe una GPO de ExecutionPolicy; se usara Bypass en Process solo durante la finalizacion y se restaurara despues.'
        }
    }
}

function Get-JhakornPrivilegePlan {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][bool]$IsAdministrator)
    [pscustomobject]@{
        PSTypeName='Wpi.BootstrapPrivilegePlan'
        IsAdministrator=$IsAdministrator
        Permitido=$IsAdministrator
        DescargaPermitida=$IsAdministrator
        UseRunAs=$false
        UacRequests=0
        ContinueInCurrentProcess=$IsAdministrator
        Mensaje=if ($IsAdministrator) {
            'La consola ya esta elevada; el bootstrap continuara en este mismo proceso.'
        } else {
            'Abra Windows PowerShell 5.1 como administrador y vuelva a ejecutar: irm jhakorn.com/wpi | iex'
        }
    }
}

function Test-JhakornBootstrapCertificate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$StoreName,
        [Parameter(Mandatory = $true)][string]$Thumbprint
    )
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store -ArgumentList $StoreName, 'LocalMachine'
    try {
        $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)
        return @($store.Certificates | Where-Object { $_.Thumbprint -eq $Thumbprint }).Count -gt 0
    }
    finally { $store.Close() }
}

function Assert-JhakornBootstrapRelativePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Context
    )
    $normalized = $Path.Replace('\', '/')
    $segments = @($normalized.Split('/') | Where-Object { $_ -ne '' })
    if (
        [string]::IsNullOrWhiteSpace($normalized) -or
        [System.IO.Path]::IsPathRooted($Path) -or
        $normalized.StartsWith('/') -or
        $normalized -match '^[A-Za-z]:' -or
        $segments -contains '..'
    ) { throw "Ruta no permitida en ${Context}: $Path" }
    return $normalized
}

function Resolve-JhakornBootstrapChildPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string]$Context
    )
    $normalized = Assert-JhakornBootstrapRelativePath -Path $RelativePath -Context $Context
    $rootFullPath = [System.IO.Path]::GetFullPath($Root)
    $rootPrefix = $rootFullPath.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $candidate = [System.IO.Path]::GetFullPath((Join-Path $rootFullPath $normalized.Replace('/', [System.IO.Path]::DirectorySeparatorChar)))
    if (-not $candidate.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Ruta fuera del directorio permitido en ${Context}: $RelativePath"
    }
    return $candidate
}

function Expand-JhakornBootstrapArchive {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ArchivePath,
        [Parameter(Mandatory = $true)][string]$DestinationPath
    )
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($ArchivePath)
    try {
        foreach ($entry in $archive.Entries) {
            if (-not [string]::IsNullOrEmpty([string]$entry.FullName)) {
                [void](Resolve-JhakornBootstrapChildPath -Root $DestinationPath -RelativePath ([string]$entry.FullName) -Context 'el ZIP')
            }
        }
    }
    finally { $archive.Dispose() }
    Expand-Archive -LiteralPath $ArchivePath -DestinationPath $DestinationPath -Force
}

function Assert-JhakornBootstrapManifest {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)][string]$Root)
    $rootPath = [System.IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    $manifestPath = Join-Path $rootPath 'SHA256SUMS.txt'
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw 'El paquete no contiene SHA256SUMS.txt.' }
    $manifestBytes = [System.IO.File]::ReadAllBytes($manifestPath)
    if ($manifestBytes.Length -ge 3 -and $manifestBytes[0] -eq 0xEF -and $manifestBytes[1] -eq 0xBB -and $manifestBytes[2] -eq 0xBF) {
        throw 'SHA256SUMS.txt contiene BOM UTF-8.'
    }
    $strictUtf8 = New-Object System.Text.UTF8Encoding -ArgumentList $false, $true
    $declared = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $entryCount = 0
    foreach ($manifestLine in [System.IO.File]::ReadAllLines($manifestPath, $strictUtf8)) {
        $line = $manifestLine.TrimEnd([char]13)
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line -notmatch '^([A-Fa-f0-9]{64}) [ *](.+)$') { throw "Linea invalida en SHA256SUMS.txt: $line" }
        $expectedHash = $Matches[1].ToUpperInvariant()
        $relativePath = Assert-JhakornBootstrapRelativePath -Path $Matches[2] -Context 'SHA256SUMS.txt'
        if (-not $declared.Add($relativePath)) { throw "Ruta duplicada en SHA256SUMS.txt: $relativePath" }
        $targetPath = Resolve-JhakornBootstrapChildPath -Root $rootPath -RelativePath $relativePath -Context 'SHA256SUMS.txt'
        if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) { throw "Falta un archivo del manifiesto: $relativePath" }
        $actualHash = (Get-FileHash -LiteralPath $targetPath -Algorithm SHA256).Hash.ToUpperInvariant()
        if ($actualHash -ne $expectedHash) { throw "SHA256 incorrecto: $relativePath" }
        $entryCount++
    }
    if ($entryCount -eq 0) { throw 'SHA256SUMS.txt no contiene archivos.' }
    foreach ($file in @(Get-ChildItem -LiteralPath $rootPath -Recurse -File | Where-Object { $_.FullName -ne $manifestPath })) {
        $relativePath = $file.FullName.Substring($rootPath.Length + 1).Replace('\', '/')
        if (-not $declared.Contains($relativePath)) { throw "Archivo no incluido en SHA256SUMS.txt: $relativePath" }
    }
    return $entryCount
}

function Assert-JhakornBootstrapMetadata {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Metadata)
    $version = [string]$Metadata.version
    $downloadUrl = [string]$Metadata.url
    $expectedHash = [string]$Metadata.sha256
    if ($version -notmatch '^\d+\.\d+\.\d+$') { throw "Version invalida recibida: $version" }
    $downloadUri = $null
    if (-not [System.Uri]::TryCreate($downloadUrl, [System.UriKind]::Absolute, [ref]$downloadUri)) { throw "URL de descarga invalida: $downloadUrl" }
    $decodedPath = [System.Uri]::UnescapeDataString($downloadUri.AbsolutePath).Replace('\', '/')
    $segments = @($decodedPath.Split('/') | Where-Object { $_ -ne '' })
    if (
        $downloadUri.Scheme -ne 'https' -or
        -not $downloadUri.Host.Equals($script:AllowedDownloadHost, [System.StringComparison]::OrdinalIgnoreCase) -or
        (-not $downloadUri.IsDefaultPort -and $downloadUri.Port -ne 443) -or
        -not [string]::IsNullOrEmpty($downloadUri.UserInfo) -or
        -not $decodedPath.StartsWith($script:AllowedDownloadPath, [System.StringComparison]::Ordinal) -or
        $segments -contains '..'
    ) { throw "URL de descarga no permitida: $downloadUrl" }
    if ($expectedHash -notmatch '^[A-Fa-f0-9]{64}$') { throw 'SHA256 invalido en current.json.' }
    return [pscustomobject]@{ Version=$version; Uri=$downloadUri; Hash=$expectedHash.ToUpperInvariant() }
}

function Invoke-JhakornBootstrapCompletionInCurrentProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ContinuationScript,
        [Parameter(Mandatory = $true)][string]$PackagePath,
        [Parameter(Mandatory = $true)][string]$PackageHash,
        [Parameter(Mandatory = $true)][string]$Version
    )
    if (-not (Test-Path -LiteralPath $ContinuationScript -PathType Leaf)) { throw "No existe el continuador verificado: $ContinuationScript" }

    # El archivo ya esta cubierto por el SHA-256 exterior y por el manifiesto
    # interior. Bypass se limita al scope Process de esta consola y se restaura
    # incluso ante error; nunca modifica CurrentUser, LocalMachine ni una GPO.
    $previousProcessPolicy = Get-ExecutionPolicy -Scope Process
    try {
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
        . $ContinuationScript -LibraryOnly
        return Invoke-JhakornBootstrapCompletion -PackagePath $PackagePath -ExpectedPackageHash $PackageHash -Version $Version
    }
    finally {
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy $previousProcessPolicy -Force
    }
}

function Invoke-JhakornPublicBootstrap {
    $workspaceRoot = $null
    $privilegePlan = Get-JhakornPrivilegePlan -IsAdministrator (Test-JhakornBootstrapAdministrator)
    if (-not $privilegePlan.Permitido) {
        Write-Warning $privilegePlan.Mensaje
        return
    }

    try {
        Write-Host 'Iniciando WPI JHAKORN...'

        $policyList = @(Get-ExecutionPolicy -List)
        $policyByScope = @{}
        foreach ($entry in $policyList) { $policyByScope[[string]$entry.Scope] = [string]$entry.ExecutionPolicy }
        $policyPlan = Get-JhakornExecutionPolicyPlan -MachinePolicy $policyByScope['MachinePolicy'] -UserPolicy $policyByScope['UserPolicy'] -CurrentUser $policyByScope['CurrentUser'] -LocalMachine $policyByScope['LocalMachine']
        if (-not $policyPlan.Permitido) { throw $policyPlan.Mensaje }

        $metadata = Invoke-RestMethod -Uri $script:MetaUrl
        $validatedMetadata = Assert-JhakornBootstrapMetadata -Metadata $metadata

        if ([string]::IsNullOrWhiteSpace($env:ProgramData)) { throw 'ProgramData no esta disponible.' }
        $workspace = New-JhakornBootstrapWorkspace -Version $validatedMetadata.Version -ProgramDataPath $env:ProgramData
        $workspaceRoot = $workspace.Ruta
        $zipPath = Join-Path $workspaceRoot 'WPI-JHAKORN.zip'
        $extractPath = Join-Path $workspaceRoot 'Verificacion'

        Invoke-WebRequest -Uri $validatedMetadata.Uri.AbsoluteUri -OutFile $zipPath

        $actualZipHash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToUpperInvariant()
        if ($actualZipHash -ne $validatedMetadata.Hash) { throw "SHA256 del paquete incorrecto. Esperado=$($validatedMetadata.Hash); obtenido=$actualZipHash." }

        [void](New-Item -ItemType Directory -Path $extractPath -ErrorAction Stop)
        Expand-JhakornBootstrapArchive -ArchivePath $zipPath -DestinationPath $extractPath

        [void](Assert-JhakornBootstrapManifest -Root $extractPath)
        $continuationScript = Join-Path $extractPath 'Bootstrap\Completar-Bootstrap-JHAKORN.ps1'
        if (-not (Test-Path -LiteralPath $continuationScript -PathType Leaf)) {
            throw 'El paquete no contiene Bootstrap\Completar-Bootstrap-JHAKORN.ps1; se requiere un Core v2.2.1 compatible.'
        }

        $completion = Invoke-JhakornBootstrapCompletionInCurrentProcess -ContinuationScript $continuationScript -PackagePath $zipPath -PackageHash $validatedMetadata.Hash -Version $validatedMetadata.Version
        if ($null -eq $completion -or -not $completion.Iniciado) { throw 'El continuador no confirmo el inicio independiente de WPI.' }
        Write-Host 'WPI JHAKORN iniciado correctamente.'
    }
    catch {
        throw "WPI JHAKORN no pudo iniciarse: $($_.Exception.Message)"
    }
    finally {
        if ($null -ne $workspaceRoot -and (Test-Path -LiteralPath $workspaceRoot)) {
            try { Remove-Item -LiteralPath $workspaceRoot -Recurse -Force -ErrorAction Stop }
            catch { Write-Warning "No se pudo limpiar la zona provisional '$workspaceRoot': $($_.Exception.Message)" }
        }
    }
}

if (-not $LibraryOnly) { Invoke-JhakornPublicBootstrap }

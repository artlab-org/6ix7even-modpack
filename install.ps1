# 6ix7even MC modpack install script (Windows PowerShell)
# Usage:
#   irm https://raw.githubusercontent.com/artlab-org/6ix7even-modpack/main/install.ps1 | iex
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Launcher auto -Clean
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Launcher sklauncher -Version 26.3
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Launcher multimc -Instance "6ix7even"
#   powershell -ExecutionPolicy Bypass -File install.ps1 -Launcher official

# Default params (overridable via CLI flags)
param(
    [ValidateSet("auto","official","sklauncher","multimc","prism","custom")]
    [string]$Launcher = "auto",
    [string]$Version = "26.3",
    [switch]$Clean = $false,
    [string]$Dir = "",
    [string]$Instance = ""
)

# ====== Bootstrap: TLS 1.2 + User-Agent + piped-execution overrides ======
# Windows PowerShell 5.1 (powershell.exe) negotiates TLS 1.0 by default and
# fails against raw.githubusercontent.com / api.modrinth.com with
#   'The request was aborted: Could not create SSL/TLS secure channel.'
try {
    [Net.ServicePointManager]::SecurityProtocol = `
        [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
} catch {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}

# Modrinth's edge rejects the default PowerShell User-Agent.
$script:HttpUserAgent = '6ix7even-mc-installer/1.0 (+https://github.com/artlab-org/6ix7even-modpack)'

# When piped (irm | iex) PowerShell drops the param() block, so the CLI flags
# are IGNORED. Env vars are the reliable way to pass them in that mode.
if ($env:MC_LAUNCHER) { $Launcher  = $env:MC_LAUNCHER }
if ($env:MC_VERSION)  { $Version   = $env:MC_VERSION }
if ($env:MC_DIR)      { $Dir      = $env:MC_DIR }
if ($env:MC_INSTANCE) { $Instance = $env:MC_INSTANCE }
$ErrorActionPreference = "Stop"
$REPO_URL = "https://raw.githubusercontent.com/artlab-org/6ix7even-modpack/main"

Write-Host ""
Write-Host "=== 6ix7even MC modpack installer ===" -ForegroundColor Cyan
Write-Host "Launcher: $Launcher | MC version: $Version | Clean: $Clean"
if ($env:MC_LAUNCHER -or $env:MC_VERSION -or $env:MC_DIR -or $env:MC_INSTANCE) {
    Write-Host "(overrides applied from env vars)" -ForegroundColor DarkGray
}
Write-Host ""

# ====== Detect launcher and find mods directory ======

function Find-ModsDir {
    param([string]$Launcher, [string]$Version, [string]$CustomDir, [string]$Instance)

    # If user provides a custom dir, use it
    if ($CustomDir) {
        if (Test-Path $CustomDir) {
            return $CustomDir
        }
        Write-Host "Custom dir not found: $CustomDir" -ForegroundColor Red
        exit 1
    }

    $appdata = $env:APPDATA

    switch ($Launcher) {

        "official" {
            # Mojang official launcher
            $dir = Join-Path $appdata ".minecraft\mods"
            return $dir
        }

        "sklauncher" {
            # SKLauncher stores versions in versions\<version>\.fabric\mods\ or versions\<version>\mods\
            # The MC version subfolder may have multiple profiles (vanilla/fabric)
            $versionsDir = Join-Path $appdata ".minecraft\versions"
            if (-not (Test-Path $versionsDir)) {
                Write-Host "SKLauncher .minecraft\versions not found" -ForegroundColor Red
                exit 1
            }

            # Find the fabric version folder for our MC version
            # SKLauncher names them like "Fabric-Loader-0.19.5-26.3" or just "26.3-fabric"
            $candidates = Get-ChildItem -Path $versionsDir -Directory | Where-Object {
                $_.Name -like "*${Version}*" -or $_.Name -like "*${Version}*fabric*" -or $_.Name -like "*fabric*${Version}*"
            }
            if ($candidates.Count -eq 0) {
                Write-Host "No Fabric profile for MC $Version found in $versionsDir" -ForegroundColor Red
                Write-Host "Available versions:"
                Get-ChildItem -Path $versionsDir -Directory | ForEach-Object { Write-Host "  $($_.Name)" }
                Write-Host ""
                Write-Host "Create a Fabric Loader profile for MC $Version in SKLauncher, then re-run this script." -ForegroundColor Yellow
                exit 1
            }

            if ($candidates.Count -gt 1) {
                Write-Host "Multiple Fabric profiles found for MC $Version :" -ForegroundColor Yellow
                $candidates | ForEach-Object { Write-Host "  $($_.Name)" }
                Write-Host "Using the first one: $($candidates[0].Name)" -ForegroundColor Yellow
            }

            $profileDir = $candidates[0].FullName
            # SKLauncher puts mods in <profileDir>\mods\ OR <profileDir>\.fabric\mods\
            foreach ($sub in @("mods", ".fabric\mods")) {
                $test = Join-Path $profileDir $sub
                if (Test-Path (Split-Path $test -Parent)) {
                    # We create it if doesn't exist
                    New-Item -ItemType Directory -Path $test -Force | Out-Null
                    return $test
                }
            }
            # Fallback: mods/ at the root of the version dir
            return (Join-Path $profileDir "mods")
        }

        "multimc" {
            # MultiMC/Prism : instances\<name>\.minecraft\mods\
            if (-not $Instance) {
                Write-Host "MultiMC requires -Instance <name> parameter" -ForegroundColor Red
                exit 1
            }
            $instanceDir = Join-Path (Join-Path $appdata "..\..\..\MultiMC\instances") $Instance
            # Resolve ../ relative paths
            $instanceDir = [System.IO.Path]::GetFullPath($instanceDir)
            $dir = Join-Path $instanceDir ".minecraft\mods"
            if (-not (Test-Path $instanceDir)) {
                Write-Host "MultiMC instance not found: $instanceDir" -ForegroundColor Red
                exit 1
            }
            return $dir
        }

        "prism" {
            # Prism Launcher : PrismLauncher\instances\<name>\.minecraft\mods\
            $instancesRoot = Join-Path $appdata "..\..\..\PrismLauncher\instances"
            $instancesRoot = [System.IO.Path]::GetFullPath($instancesRoot)
            if (-not $Instance) {
                Write-Host "Prism requires -Instance <name> parameter" -ForegroundColor Red
                exit 1
            }
            $dir = Join-Path (Join-Path $instancesRoot $Instance) ".minecraft\mods"
            if (-not (Test-Path (Split-Path $dir -Parent))) {
                Write-Host "Prism instance not found: $dir" -ForegroundColor Red
                exit 1
            }
            return $dir
        }

        "custom" {
            if (-not $CustomDir) {
                Write-Host "Custom mode requires -Dir <path>" -ForegroundColor Red
                exit 1
            }
            if (-not (Test-Path $CustomDir)) {
                New-Item -ItemType Directory -Path $CustomDir -Force | Out-Null
            }
            return $CustomDir
        }

        "auto" {
            # Auto-detect based on existing files
            $official = Join-Path $appdata ".minecraft\mods"
            $versionsDir = Join-Path $appdata ".minecraft\versions"

            # Check if SKLauncher is installed (look for its exe)
            $skExe = Get-ChildItem -Path $appdata -Filter "SKLauncher*" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($skExe) {
                Write-Host "SKLauncher detected — using SKLauncher profile" -ForegroundColor Cyan
                return (Find-ModsDir -Launcher "sklauncher" -Version $Version -CustomDir "" -Instance "")
            }

            # Check MultiMC / Prism dirs
            $multimcRoot = Join-Path $appdata "..\..\..\MultiMC\instances"
            $multimcRoot = [System.IO.Path]::GetFullPath($multimcRoot)
            $prismRoot = Join-Path $appdata "..\..\..\PrismLauncher\instances"
            $prismRoot = [System.IO.Path]::GetFullPath($prismRoot)
            if (Test-Path $prismRoot) {
                Write-Host "Prism Launcher detected — using Prism instance default" -ForegroundColor Cyan
                $instances = Get-ChildItem -Path $prismRoot -Directory
                if ($instances.Count -gt 0) {
                    if (-not $Instance) { $Instance = $instances[0].Name }
                    Write-Host "Using instance: $Instance (use -Instance to override)" -ForegroundColor Yellow
                    return (Find-ModsDir -Launcher "prism" -Version $Version -CustomDir "" -Instance $Instance)
                }
            }
            if (Test-Path $multimcRoot) {
                Write-Host "MultiMC detected — using instance default" -ForegroundColor Cyan
                $instances = Get-ChildItem -Path $multimcRoot -Directory
                if ($instances.Count -gt 0) {
                    if (-not $Instance) { $Instance = $instances[0].Name }
                    Write-Host "Using instance: $Instance (use -Instance to override)" -ForegroundColor Yellow
                    return (Find-ModsDir -Launcher "multimc" -Version $Version -CustomDir "" -Instance $Instance)
                }
            }

            # Fallback : .minecraft\mods\
            Write-Host "No launcher detected — falling back to .minecraft\mods" -ForegroundColor Yellow
            return $official
        }

        default {
            Write-Host "Unknown launcher: $Launcher" -ForegroundColor Red
            exit 1
        }
    }
}

$MODS_DIR = Find-ModsDir -Launcher $Launcher -Version $Version -CustomDir $Dir -Instance $Instance
Write-Host "Mods target dir: $MODS_DIR"
Write-Host ""

# ====== Verify Minecraft is installed ======
$mcRoot = (Split-Path (Split-Path $MODS_DIR -Parent) -Parent)
if ($Launcher -eq "sklauncher") {
    $mcRoot = (Split-Path (Split-Path (Split-Path $MODS_DIR -Parent) -Parent) -Parent)
}
if (-not (Test-Path $mcRoot)) {
    Write-Host "Minecraft root not found at $mcRoot" -ForegroundColor Red
    Write-Host "Lance une fois ton launcher avec MC $Version pour creer le dossier." -ForegroundColor Yellow
    exit 1
}

# ====== Verify Java ======
$java = (Get-Command java -ErrorAction SilentlyContinue)
if (-not $java) {
    Write-Host "Error: java not in PATH" -ForegroundColor Red
    Write-Host "Installe Java 25+ : https://adoptium.net/" -ForegroundColor Red
    exit 1
}
$javaVer = (& java -version 2>&1 | Select-String "version" | ForEach-Object { $_.Line })
Write-Host "Java detecte: $javaVer"

# ====== Clean existing mods (if --Clean) ======
if ($Clean) {
    Write-Host ""
    Write-Host "=== Cleaning existing mods ===" -ForegroundColor Yellow
    $existing = Get-ChildItem -Path $MODS_DIR -Filter "*.jar" -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "Removing $($existing.Count) existing mod .jar:"
        $existing | ForEach-Object {
            Write-Host "  rm $($_.Name)"
            Remove-Item $_.FullName -Force
        }
    } else {
        Write-Host "No existing mods to clean"
    }
}

# Create mods dir if missing
if (-not (Test-Path $MODS_DIR)) {
    New-Item -ItemType Directory -Path $MODS_DIR -Force | Out-Null
}

# ====== Helper: SHA512 ======
function Get-SHA512($path) {
    $hash = [System.Security.Cryptography.SHA512]::Create()
    $stream = [System.IO.File]::OpenRead($path)
    try {
        $bytes = $hash.ComputeHash($stream)
        -join ($bytes | ForEach-Object { $_.ToString("x2") })
    } finally {
        $stream.Close()
    }
}

# ====== Download from Modrinth ======
$MODS = @(
    "better-autoclicker"
    "chat-heads"
    "chunky"
    "cloth-config"
    "continuity"
    "controlify"
    "distanthorizons"
    "entity-model-features"
    "entitytexturefeatures"
    "fabric-api"
    "fabric-language-kotlin"
    "ferrite-core"
    "iris"
    "krypton"
    "lithium"
    "modmenu"
    "particle-rain"
    "plasmo-voice"
    "3dskinlayers"
    "sodium"
    "sound-physics-remastered"
    "viafabric"
    "visuality"
    "yacl"
)

# ====== Versions epinglees ======
# L'API Modrinth renvoie les versions par date decroissante : prendre la 1re
# peut installer une beta (ex. plasmo-voice 2.2.0-beta.2 au lieu de la stable).
# Les 24 mods du pack v1.1.0 sont donc epingles sur un version_id precis
# (slug -> version_id) : c'est exactement l'ensemble teste sur l'instance
# de reference, pas "la derniere version publiee".
$script:PinnedVersions = @{
    "better-autoclicker" = "6pYrIgDv"
    "chat-heads" = "9O2ZSOkh"
    "chunky" = "86FKD9qx"
    "cloth-config" = "fg2uyxOW"
    "continuity" = "Jt2sCWTQ"
    "controlify" = "fo76vL20"
    "distanthorizons" = "TGgEbP9A"
    "entity-model-features" = "vF6qLXsA"
    "entitytexturefeatures" = "svwZ2o4d"
    "fabric-api" = "Zns5SSRA"
    "fabric-language-kotlin" = "SKW1BTL3"
    "ferrite-core" = "d5ddUdiB"
    "iris" = "vTN4NRGW"
    "krypton" = "UugdIYJw"
    "lithium" = "fWv5bnZk"
    "modmenu" = "xckkBHD5"
    "particle-rain" = "PbaF66N6"
    "plasmo-voice" = "vKP6gBRn"
    "3dskinlayers" = "gjM2TO0L"
    "sodium" = "g6ju16VJ"
    "sound-physics-remastered" = "29UOgzLw"
    "viafabric" = "qiAP0t9R"
    "visuality" = "BNe9kpJ7"
    "yacl" = "s9SjoFu1"
}

# ====== SHA-512 attendus (source : mods/manifest.json) ======
# Le hash attendu est verifie en local : meme si l'API Modrinth repond avec
# une autre empreinte, c'est celle du manifeste qui fait foi.
$script:ExpectedSha512 = @{
    "6pYrIgDv" = "c43e397976fe2a7fb016c34f7d42804d7d5fec0c1e2e28de174106ce005a17b92bc8ab98817fcd56a9e9872d60b02482fe6baf2a59877b366e7e062148b408d5"
    "9O2ZSOkh" = "8f6d3c42128ca54252090c5b5c06cf68c98c106b454aaec9dd94aa1ccd499fd2603b44d559f4ee9b8124c1eaf86233ba2290ba2f93d07480fe2e9fe3c534bfb5"
    "86FKD9qx" = "6f0323daa69d61bd3b3fbe9d8b713664d9b7c69182183f8dcff6362b43783639778a96e32215dbfd329588f06b60a5d93656dbb1d391c660db203482aa972d5e"
    "fg2uyxOW" = "8924e19d41845096724fa10f3717bc51964a0edbbbcad0ff1e6c6187a398b08f356e49579a657c2dc44a7f92e3850771f3ca70bf8c1f654de60425163b91dbb1"
    "Jt2sCWTQ" = "1ec1e3b2f73c26b19445d664822a8936e9076f4d8855a2ed5fac19786daa8da42da8fdc9526c4a53c227a82819a87ad8e73d5b4fc003f6519c50454c33014f04"
    "fo76vL20" = "cd4e64a9621dff200329b249dc63fc4542ce554db16c75c4b04cfa7495bf84e1a4bca0f89a7a9d4d425f6b6f23c8df52ab8ce323ee18ae49c6cf24858697bbf7"
    "TGgEbP9A" = "0b90b1b08d99974bfc3c8e86b2ceb252e2f91715ed66b925004c28335fb44e1bddbbb6b8043e4d4d53c87ed247789cd1788b1ba4e3f4394efe154e0c59cff236"
    "vF6qLXsA" = "4572fc065e757264947aff35a96d17d5e45d4b43e8e385b9a207f5380a8f43da5dbf8e10f30a7bc7cc4c0c8f7999717b4dd22d325667bdf8a0de6e839ad81efc"
    "svwZ2o4d" = "69193c58d4d05e08fea9afa34cc47563e9b9e95aa2da276441085ade44ed36f8123b9cc1a2938f9ecac9aea6fd9ceb51120dd20f7284337a3bb592bc3b904336"
    "Zns5SSRA" = "fb686a9fa923248328107a12498229d6951e316257f18b7d0e4cbd6885ba447ed50a44076a8a5ba47cfe2043b329db3587ab000aeab1face26b2587a5d4ba6b5"
    "SKW1BTL3" = "7fb475c4a7e7bdf8d0aca4b5798a58a354c51443d5b1fbde3e8cf34dfbf7191ef4238b5f07d08ec9490ec180b371624523326c3ad45d4ed2b2be541de9407e5d"
    "d5ddUdiB" = "d81fa97e11784c19d42f89c2f433831d007603dd7193cee45fa177e4a6a9c52b384b198586e04a0f7f63cd996fed713322578bde9a8db57e1188854ae5cbe584"
    "vTN4NRGW" = "d8d3312f77fc52a48e4a6cd836fda33669bdebcb4de0b8c0d30adc808b287330a533e0baef355cc1ce6336a26851d9775369a802a4666b7b7a6266af20088f42"
    "UugdIYJw" = "d1d57ebd41395b75b01f130cd9503eb8d208212424a399ff9f367f50be8fbc1c6472442b33c686e777c3148f6a609520e8fb732c755157c358cb207fd4d1123a"
    "fWv5bnZk" = "2ca92fb530135d2baddf0ba4cc4f93976234876a38c4aa02b487b2552400f005afcfbeebf5373fb4396fe2020537a42d7597b8da5a52b904355ef51d5fef07ad"
    "xckkBHD5" = "d00d52d5342728da13a6237f76c50fc5fd1c62d8112ae4e07726bbc64d2019a76130d6b2968765df81c6499225588eacee6681eebc13c0ada3cad91fc8ab2984"
    "PbaF66N6" = "8322aa75ec672ae63a4ea78936fd4cb96d8a06c5411bf6d2a76cdbaac1c06ebc7a96cd81125914e91db9f3a1a52e3be0ac8a44d2b5131ab9837a23726bd4206f"
    "vKP6gBRn" = "00090edb493fc6b632a6825c765ff797f8469625f2c30a44b8d07d920b6fa7159e6671d585d122d272d2e7a6e6a11f2c1cb5f81cbaf2738354ad80abd9fe8f83"
    "gjM2TO0L" = "1a93ba9f726f8053e111abbe225f67b85e74bdfb78955711218ef103e670bc2c0f011f5911bf725686b79a1b85cecbb1ba733bf1b2eaa2856e53c4f842680627"
    "g6ju16VJ" = "884a1ef0ce0e69d565d41a1359070a8d4f8589a086b565540defdb4741985053077dfd0f2a56898ce60510720a9f95dd8ba220a9a6340b6e0cf5cb12352e2419"
    "29UOgzLw" = "dcd812a812ce04d87dbab0bf24fc42ef6a3ddd8150a98e45c78963bb0bfaf6cba6b9464101cf8a8d4d9551bc4ae0c300913b99715eaff787aba744a3c08317f2"
    "qiAP0t9R" = "9098d75597b5a91bb50fa80228e729e87ed9aee70e19fda86fdc4c0e73127eaf1b7ece5b71a61149b34d9a8e17c0560f4be0d6c15537e7361d20e0fd641b6f4e"
    "BNe9kpJ7" = "90145cad547d329d5134eabbf45c7f35b1d0ce3ff2bcef8a1b187dc33723121b1a235c0cc259043588835b0cb7b31cba4aa84d738be810f0ea073308bec2eb4a"
    "s9SjoFu1" = "f3957028dd31cae78f08aee3e768f61bd12c4c8423257d357bc3c1a2172047c769d37901f99775c7ffff1e5ee794025dc72738b2869cab06f1c2811841d68b24"
}

Write-Host ""
Write-Host "Telechargement de $($MODS.Count) mods depuis Modrinth (MC $Version + Fabric)..." -ForegroundColor Yellow

$ok = 0
$skipped = 0
$failed = 0

foreach ($slug in $MODS) {
    Write-Host ""
    Write-Host "[$slug]" -ForegroundColor Cyan
    $pinnedId = $null
    if ($script:PinnedVersions.ContainsKey($slug)) {
        $pinnedId = $script:PinnedVersions[$slug]
    }

    if ($pinnedId) {
        $apiUrl = "https://api.modrinth.com/v2/version/$pinnedId"
    } else {
        $apiUrl = "https://api.modrinth.com/v2/project/$slug/version?loaders=%5B%22fabric%22%5D&game_versions=%5B%22$Version%22%5D"
    }

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -TimeoutSec 30 -UserAgent $script:HttpUserAgent
    } catch {
        Write-Host "  ERREUR API Modrinth pour $slug : $_" -ForegroundColor Red
        $failed++
        continue
    }

    if ($pinnedId) {
        # Version epinglee : verifie qu'elle cible bien la version de MC
        # demandee, puis normalise la reponse en liste (comme l'API projet).
        if (-not $response.game_versions -or ($response.game_versions -notcontains $Version)) {
            Write-Host "  Version epinglee $pinnedId incompatible avec MC $Version, skip" -ForegroundColor Yellow
            $skipped++
            continue
        }
        $versions = @($response)
    } else {
        $versions = $response
    }

    if (-not $versions -or $versions.Count -eq 0) {
        Write-Host "  Pas de version MC $Version Fabric pour $slug, skip" -ForegroundColor Yellow
        $skipped++
        continue
    }

    $version = $versions[0]
    $file = $version.files[0]
    $dest = Join-Path $MODS_DIR $file.filename
    $expectedSha = $file.hashes.sha512
    # Le manifeste (mods/manifest.json) fait foi pour l'empreinte attendue.
    if ($pinnedId -and $script:ExpectedSha512.ContainsKey($pinnedId)) {
        $expectedSha = $script:ExpectedSha512[$pinnedId]
    }

    # Skip if already correct
    if ((Test-Path $dest) -and ((Get-SHA512 $dest) -eq $expectedSha)) {
        Write-Host "  Deja installe: $($file.filename) ($($version.version_number))" -ForegroundColor Green
        $ok++
        continue
    }

    Write-Host "  DL $($file.filename) ($([math]::Round($file.size/1KB)) KB) [$($version.version_number)]..."
    try {
        Invoke-WebRequest -Uri $file.url -OutFile $dest -TimeoutSec 120 -UseBasicParsing -UserAgent $script:HttpUserAgent
    } catch {
        Write-Host "  ERREUR telechargement : $_" -ForegroundColor Red
        $failed++
        continue
    }

    $actualSha = Get-SHA512 $dest
    if ($actualSha -eq $expectedSha) {
        Write-Host "  OK" -ForegroundColor Green
        $ok++
    } else {
        Write-Host "  SHA mismatch, fichier supprime" -ForegroundColor Red
        Remove-Item $dest -Force
        $failed++
    }
}

Write-Host ""
Write-Host "=== Bilan ===" -ForegroundColor Cyan
Write-Host "OK : $ok | Skip : $skipped | Failed : $failed"
Write-Host ""

if ($failed -eq 0) {
    Write-Host "=== Installation OK ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "PROCHAINES ETAPES :" -ForegroundColor Yellow
    if ($Launcher -eq "sklauncher") {
        Write-Host "1. Ouvre SKLauncher"
        Write-Host "2. Selectionne le profil Fabric-Loader-0.19.5-26.3"
        Write-Host "3. Verifie la version MC : clic droit sur le profil > Settings > Minecraft Version doit etre 26.3 (PAS 26.1, 26.1.2, ou 26.4)"
        Write-Host "4. Lance le jeu"
    } elseif ($Launcher -in "multimc","prism") {
        Write-Host "1. Ouvre MultiMC/Prism"
        Write-Host "2. Verifie la version MC de l'instance (clic droit > Edit Instance > Settings > Minecraft Version = 26.3)"
        Write-Host "3. Lance le jeu"
    } else {
        Write-Host "1. Ouvre ton launcher"
        Write-Host "2. Force la version MC a 26.3 (PAS 26.1/26.1.2, PAS 26.4+)"
        Write-Host "3. Lance le jeu"
    }
    Write-Host "4. Verifie que 'Mod Menu' apparait dans le menu principal"
    Write-Host "5. Ajoute le serveur : mc.6ix7even.cc port 25565 (ou artlab:25565 via tailnet)"
    Write-Host "6. Tape /register <password> puis /login <password> en jeu"
    Write-Host ""
    Write-Host "Si probleme : ouvre une issue sur https://github.com/artlab-org/6ix7even-modpack/issues"
} else {
    Write-Host "=== Installation partielle ===" -ForegroundColor Yellow
    Write-Host "$failed mods ont echoue. Re-lance le script pour retry."
}

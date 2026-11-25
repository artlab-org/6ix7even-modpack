# Pack client 6ix7even — Minecraft (MC 26.3, Fabric)

**Modpack Fabric facultatif pour le serveur 6ix7even Minecraft (MC 26.3).**

Dépôt : [`artlab-org/6ix7even-modpack`](https://github.com/artlab-org/6ix7even-modpack) · Modrinth : [`6ix7even`](https://modrinth.com/modpack/6ix7even) · Site : <https://web.6ix7even.cc/modpack/>

> ℹ️ **Ce modpack est facultatif pour rejoindre le serveur.**
> Tu peux te connecter et jouer normalement sans le pack. Le pack apporte 4 améliorations :
>
> - **Optimisation** — les mods d'optimisation du pack : Sodium (rendu optimisé), Lithium, Krypton, FerriteCore.
> - **Distant Horizons** — rendu LOD : les chunks lointains sont générés en arrière-plan.
> - **Shaders** — Iris, pour les shaders (voir « Pourquoi pas OptiFine ? »).
> - **Chat vocal de proximité** — Plasmo Voice : tu entends les autres et on t'entend quand on est proches dans le monde.
>
> Sans le pack, tu perds ces 4 améliorations. Le seul point visible en jeu : **tu n'as pas la voix** — le mod de voix n'est pas obligatoire côté serveur, tu te connectes et tu joues normalement, tu n'entends simplement personne (voir [Chat vocal](#chat-vocal-proximité)).

---

## Sommaire

1. [Pré-requis](#pré-requis)
2. [Installation rapide (automatique)](#installation-rapide-automatique)
3. [Installation manuelle](#installation-manuelle)
4. [Liens Modrinth (pour téléchargement direct)](#liens-modrinth-pour-téléchargement-direct)
5. [Pack Modrinth (.mrpack)](#pack-modrinth-mrpack)
6. [Ressources, shaders et configs embarqués](#ressources-shaders-et-configs-embarqués)
7. [Accès au serveur](#accès-au-serveur)
8. [Chat vocal (proximité)](#chat-vocal-proximité)
9. [Compatibilité launcher](#compatibilité-launcher)
10. [Upgrade](#upgrade)
11. [Notes](#notes)

---

## Pré-requis

- **Java 25 ou plus récent** (MC 26.3 utilise Java 25 LTS)
- **Minecraft Java Edition 26.3** installé via ton launcher
- Un des launchers suivants :
  - **Minecraft Launcher officiel** (Microsoft)
  - **TLauncher** (crack)
  - **SKLauncher** (crack)
  - **MultiMC / Prism Launcher** (open-source)
- ~1 Go d'espace disque (24 mods = ~74 Mio, + ~18 Mio de resource packs et ~5 Mio de shader packs)
- 4 GB RAM alloués au jeu (recommandé 6 GB pour Distant Horizons)

---

## Installation rapide (automatique)

### Windows (oneliner PowerShell)

Ouvre PowerShell (touche Windows, tape `powershell`, Entrée), puis colle :

```powershell
irm https://raw.githubusercontent.com/artlab-org/6ix7even-modpack/main/install.ps1 | iex
```

> **Windows PowerShell 5.1** (`powershell.exe`, le défaut sur Windows 10/11) peut
> échouer avec `The request was aborted: Could not create SSL/TLS secure channel.`
> Le script force TLS 1.2 **après** avoir été téléchargé — mais si le
> *téléchargement* échoue, la version qui force TLS n'est jamais atteinte.
> **Dans ce cas, utilise la variante ci-dessous** qui force TLS 1.2 *avant* le
> download :

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
irm https://raw.githubusercontent.com/artlab-org/6ix7even-modpack/main/install.ps1 | iex
```

> Si même ça échoue (TLS bloqué au niveau OS / proxy d'entreprise), utilise
> `curl.exe` (intégré à Windows 10 1803+) puis PowerShell :

```powershell
curl.exe -fsSL https://raw.githubusercontent.com/artlab-org/6ix7even-modpack/main/install.ps1 -o "$env:TEMP\6ix7even-mc-install.ps1"
powershell -ExecutionPolicy Bypass -File "$env:TEMP\6ix7even-mc-install.ps1"
```

> **Le `| iex` ignore les paramètres** (`-Launcher`, `-Version`, `-Clean`) :
> PowerShell ne transmet pas le bloc `param()` quand le script est *piped*.
> Si tu dois choisir un launcher précis, télécharge le fichier et utilise `-File`
> (voir ci-dessus), ou passe par les variables d'environnement :

```powershell
$env:MC_LAUNCHER = "sklauncher"; irm https://raw.githubusercontent.com/artlab-org/6ix7even-modpack/main/install.ps1 | iex
```

Le script :
1. Télécharge tous les mods depuis Modrinth CDN
2. Vérifie les SHA512
3. Copie dans ton dossier `.minecraft/mods/`
4. Confirme l'installation

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/artlab-org/6ix7even-modpack/main/install.sh | bash
```

> Le script supporte `--dir <path>` pour cibler un dossier `.minecraft` custom (MultiMC/Prism).

### Désinstallation

```bash
# Windows
irm https://raw.githubusercontent.com/artlab-org/6ix7even-modpack/main/uninstall.ps1 | iex

# Linux / macOS
bash <(curl -fsSL https://raw.githubusercontent.com/artlab-org/6ix7even-modpack/main/uninstall.sh)
```

---

## Installation manuelle

Si tu préfères installer les mods à la main (ou si l'install auto ne marche pas) :

### Étape 1 — Installer Fabric Loader 0.19.5

1. Télécharge [fabric-installer.jar](https://maven.fabricmc.net/net/fabricmc/fabric-loader/0.19.5/fabric-loader-0.19.5.jar)
2. Lance-le avec Java 25+ :
   ```bash
   java -jar fabric-installer.jar client -mcversion 26.3 -loader 0.19.5
   ```
3. Sélectionne ton profil MC 26.3 vanilla, puis clique **Install**

### Étape 2 — Télécharger les mods

Va sur [Modrinth](https://modrinth.com), cherche chaque mod, vérifie la compatibilité MC 26.3 + Fabric, télécharge le `.jar`.

**OU** utilise les liens directs dans le tableau [ci-dessous](#liens-modrinth-pour-téléchargement-direct).

### Étape 3 — Copier les mods

Copie les 24 fichiers `.jar` dans ton dossier `.minecraft/mods/` (dont `plasmovoice-fabric-26.3-2.1.17.jar` pour le chat vocal) :

| OS | Chemin typique |
|---|---|
| Windows | `%APPDATA%\.minecraft\mods\` (en général `C:\Users\<ton_nom>\AppData\Roaming\.minecraft\mods\`) |
| Linux | `~/.minecraft/mods/` |
| macOS | `~/Library/Application Support/minecraft/mods/` |

### Étape 4 — Lancer le jeu

1. Ouvre ton launcher (officiel, TLauncher, SKLauncher, MultiMC, Prism)
2. Sélectionne le profil **Fabric Loader 0.19.5** (ou créé-en un nouveau en pointant vers la version Fabric)
3. Lance le jeu
4. Tu dois voir l'écran **Mod Menu** dans le menu principal → ça confirme que les mods sont chargés

---

## Liens Modrinth (pour téléchargement direct)

Tous les mods ont été téléchargés depuis **Modrinth** (CDN officiel). Tu peux vérifier chaque SHA512 sur la page Modrinth du mod.

| Mod | Version | `version_id` Modrinth | Taille |
|---|---|---|---:|
| [Better Autoclicker](https://modrinth.com/mod/better-autoclicker) | `1.4.4+mc26.3` | `6pYrIgDv` | 69 375 octets |
| [Chat Heads](https://modrinth.com/mod/chat-heads) | `1.3.3` | `9O2ZSOkh` | 98 703 octets |
| [Chunky](https://modrinth.com/mod/chunky) | `1.5.66` | `86FKD9qx` | 442 176 octets |
| [Cloth Config](https://modrinth.com/mod/cloth-config) | `26.3.159+fabric` | `fg2uyxOW` | 1 135 009 octets |
| [Continuity](https://modrinth.com/mod/continuity) | `3.0.1+26.3` | `Jt2sCWTQ` | 1 002 033 octets |
| [Controlify](https://modrinth.com/mod/controlify) | `3.5.3+mc26.3` | `fo76vL20` | 6 410 187 octets |
| [Distant Horizons](https://modrinth.com/mod/distanthorizons) | `3.3.4-26.3` | `TGgEbP9A` | 28 476 894 octets |
| [Entity Model Features](https://modrinth.com/mod/entity-model-features) | `3.3.12-fabric-26.3` | `vF6qLXsA` | 665 386 octets |
| [Entity Texture Features](https://modrinth.com/mod/entitytexturefeatures) | `7.2.7-fabric-26.3` | `svwZ2o4d` | 798 322 octets |
| [Fabric API](https://modrinth.com/mod/fabric-api) | `0.166.2+26.3` | `Zns5SSRA` | 1 797 523 octets |
| [Fabric Language Kotlin](https://modrinth.com/mod/fabric-language-kotlin) | `1.14.2+kotlin.2.4.21` | `SKW1BTL3` | 8 142 878 octets |
| [FerriteCore](https://modrinth.com/mod/ferrite-core) | `9.0.0-fabric` | `d5ddUdiB` | 72 677 octets |
| [Iris](https://modrinth.com/mod/iris) | `1.11.7+26.3-fabric` | `vTN4NRGW` | 2 850 938 octets |
| [Krypton](https://modrinth.com/mod/krypton) | `0.3.2` | `UugdIYJw` | 268 849 octets |
| [Lithium](https://modrinth.com/mod/lithium) | `mc26.3-0.26.3-fabric` | `fWv5bnZk` | 919 892 octets |
| [Mod Menu](https://modrinth.com/mod/modmenu) | `21.0.1` | `xckkBHD5` | 862 761 octets |
| [Particle Rain](https://modrinth.com/mod/particle-rain) | `v4.0.4+26.3-fabric` | `PbaF66N6` | 631 030 octets |
| [Plasmo Voice](https://modrinth.com/mod/plasmo-voice) | `fabric-26.3-2.1.17` | `vKP6gBRn` | 12 248 022 octets |
| [3D Skin Layers](https://modrinth.com/mod/3dskinlayers) | `1.11.4` | `gjM2TO0L` | 1 892 299 octets |
| [Sodium](https://modrinth.com/mod/sodium) | `mc26.3-0.9.3-beta.1-fabric` | `g6ju16VJ` | 1 912 496 octets |
| [Sound Physics Remastered](https://modrinth.com/mod/sound-physics-remastered) | `fabric-1.5.4+26.3` | `29UOgzLw` | 205 629 octets |
| [ViaFabric](https://modrinth.com/mod/viafabric) | `0.4.22+186-26.x` | `qiAP0t9R` | 5 914 365 octets |
| [Visuality](https://modrinth.com/mod/visuality) | `0.7.15+26.3` | `BNe9kpJ7` | 81 970 octets |
| [YetAnotherConfigLib](https://modrinth.com/mod/yacl) | `3.9.7+26.3-fabric` | `s9SjoFu1` | 1 125 377 octets |

> Ce tableau liste les **24 mods client** du pack — exactement la liste installée par `install.sh` / `install.ps1` et embarquée dans le `.mrpack` (index : 24 entrées). Les mods **serveur** (`easyauth`, `vanish`) ne sont **pas** dans le pack client (voir [Compatibilité serveur](#compatibilité-serveur)).

### Téléchargement manuel en lot

Pour télécharger les **24 mods du modpack** d'un coup (PowerShell) — même liste et même épinglage de version que `install.sh` / `install.ps1` :

```powershell
# Prérequis Windows PowerShell 5.1 — identiques à ceux d'install.ps1 :
# - TLS 1.2 forcé (PS 5.1 négocie TLS 1.0 par défaut → échec « SSL/TLS secure channel »)
try {
    [Net.ServicePointManager]::SecurityProtocol = `
        [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
} catch {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
}
# - User-Agent explicite (l'edge Modrinth rejette le User-Agent PowerShell par défaut)
$ua = '6ix7even-mc-installer/1.1 (+https://github.com/artlab-org/6ix7even-modpack)'

# Versions épinglées (identique à install.sh / install.ps1) :
# l'API Modrinth renvoie les versions par date décroissante, la 1re peut être
# une bêta (plasmo-voice 2.2.0-beta.2). On force le version_id stable.
$mods = @(
  @{ slug = "better-autoclicker"; version_id = "6pYrIgDv" },
  @{ slug = "chat-heads"; version_id = "9O2ZSOkh" },
  @{ slug = "chunky"; version_id = "86FKD9qx" },
  @{ slug = "cloth-config"; version_id = "fg2uyxOW" },
  @{ slug = "continuity"; version_id = "Jt2sCWTQ" },
  @{ slug = "controlify"; version_id = "fo76vL20" },
  @{ slug = "distanthorizons"; version_id = "TGgEbP9A" },
  @{ slug = "entity-model-features"; version_id = "vF6qLXsA" },
  @{ slug = "entitytexturefeatures"; version_id = "svwZ2o4d" },
  @{ slug = "fabric-api"; version_id = "Zns5SSRA" },
  @{ slug = "fabric-language-kotlin"; version_id = "SKW1BTL3" },
  @{ slug = "ferrite-core"; version_id = "d5ddUdiB" },
  @{ slug = "iris"; version_id = "vTN4NRGW" },
  @{ slug = "krypton"; version_id = "UugdIYJw" },
  @{ slug = "lithium"; version_id = "fWv5bnZk" },
  @{ slug = "modmenu"; version_id = "xckkBHD5" },
  @{ slug = "particle-rain"; version_id = "PbaF66N6" },
  @{ slug = "plasmo-voice"; version_id = "vKP6gBRn" },
  @{ slug = "3dskinlayers"; version_id = "gjM2TO0L" },
  @{ slug = "sodium"; version_id = "g6ju16VJ" },
  @{ slug = "sound-physics-remastered"; version_id = "29UOgzLw" },
  @{ slug = "viafabric"; version_id = "qiAP0t9R" },
  @{ slug = "visuality"; version_id = "BNe9kpJ7" },
  @{ slug = "yacl"; version_id = "s9SjoFu1" }
)

# Créer le dossier cible s'il n'existe pas (comme install.ps1) :
New-Item -ItemType Directory -Path "$env:APPDATA\.minecraft\mods" -Force | Out-Null

foreach ($mod in $mods) {
    # Version épinglée : on interroge directement /v2/version/<version_id>
    $apiUrl = "https://api.modrinth.com/v2/version/$($mod.version_id)"
    $version = Invoke-RestMethod -Uri $apiUrl -TimeoutSec 30 -UserAgent $ua
    $file = $version.files[0]
    $out = "$env:APPDATA\.minecraft\mods\$($file.filename)"
    Write-Host "Téléchargement $($mod.slug) ($($file.filename))..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $file.url -OutFile $out -TimeoutSec 120 -UseBasicParsing -UserAgent $ua
    # Vérification SHA-512 (comme les scripts d'installation du modpack)
    $actual = (Get-FileHash -Path $out -Algorithm SHA512).Hash.ToLower()
    if ($actual -ne $file.hashes.sha512.ToLower()) {
        Remove-Item $out -Force
        throw "SHA-512 mismatch : $($mod.slug) ($($file.filename))"
    }
}
```

---

## Pack Modrinth (.mrpack)

Le pack `.mrpack` est **généré localement** depuis `mods/manifest.json`. Depuis le **rebrand du 25 novembre 2026**, le slug du projet Modrinth est [`6ix7even`](https://modrinth.com/modpack/6ix7even) (id projet `Y6UiohXZ`, id organisation `OaROVVjY` — **inchangés**), type `modpack`, **version publiée : 1.1.0** (Minecraft 26.3, Fabric), disponible sur le CDN Modrinth et en release GitHub. Le build **local** produit `dist/6ix7even-1.1.0.mrpack`. Depuis le commit de versionnement, ce fichier — **identique octet pour octet** à la version Modrinth `eCYn2UJh` et à l'asset de la release `mrpack-v1.1.0` — est **versionné dans le dépôt** (`dist/6ix7even-1.1.0.mrpack`, 22 575 641 o) : le dépôt est donc la source de vérité de l'artefact distribué, et son contenu peut être contrôlé sans download.

> ⚠️ **La version 1.0.0 reste intacte.**
> La version Modrinth **1.0.0** (id `MkI0FmNB`) et les releases GitHub [`modrinth-v1.0.0`](https://github.com/artlab-org/6ix7even-modpack/releases/tag/modrinth-v1.0.0) / [`mrpack-v1.0.0`](https://github.com/artlab-org/6ix7even-modpack/releases/tag/mrpack-v1.0.0) **n'ont pas été republiés** : le fichier publié s'appelle toujours `artlab-client-1.0.0.mrpack` (2 597 o, SHA-256 `0ca18926fd2ca239ec0e5843707954a202bc68de5edb0875822bd83d0cafa1f3`).
> La **1.1.0** est une **nouvelle version** : elle passe de 13 à **24 mods** et ajoute les **7 resource packs**, les **4 shader packs** et les **27 fichiers de configuration** de l'instance de référence. Le fichier de la 1.1.0 s'appelle `6ix7even-1.1.0.mrpack`.

> 📦 **Publication de la 1.1.0 (25 novembre 2026)**
> - **Release GitHub [`mrpack-v1.1.0`](https://github.com/artlab-org/6ix7even-modpack/releases/tag/mrpack-v1.1.0)** — asset `6ix7even-1.1.0.mrpack`, **22 575 641 o**, SHA-256 `e91e72af53774505e1cbb253185f2d36f2816ad80fdb0ff48ca66cd8a33604cb` (identique au build local). Téléchargement : <https://github.com/artlab-org/6ix7even-modpack/releases/download/mrpack-v1.1.0/6ix7even-1.1.0.mrpack>
> - **Version Modrinth 1.1.0** : **publiée** (25 novembre 2026) — id version **`eCYn2UJh`**, `status=listed`, `loaders=["mrpack"]`, `mrpack_loaders=["fabric"]`, `game_versions=["26.3"]`, `environment=client_only`, **24 dépendances `embedded`**. Le fichier publié est **le même octet pour octet** que la release GitHub : **22 575 641 o**, SHA-256 `e91e72af53774505e1cbb253185f2d36f2816ad80fdb0ff48ca66cd8a33604cb`. CDN : <https://cdn.modrinth.com/data/Y6UiohXZ/versions/eCYn2UJh/6ix7even-1.1.0.mrpack>
> - **Modération Modrinth en cours** (`status=processing`, `in_review=true`) : la page <https://modrinth.com/modpack/6ix7even> affiche encore « Project not found » en accès anonyme et l'installation en un clic n'est pas encore possible — le CDN sert déjà les deux versions. **La 1.0.0 n'a pas été modifiée** (`MkI0FmNB`, `listed`, 2 597 o).

```bash
# Génère dist/6ix7even-1.1.0.mrpack — ZIP déterministe (même SHA-256 à chaque exécution)
python3 tools/build_mrpack.py

# Point d'entrée unique : génère PUIS valide (code de sortie ≠ 0 si un écart est détecté)
python3 tools/build_mrpack.py --validate

# Valider un pack déjà construit
python3 tools/validate_mrpack.py dist/6ix7even-1.1.0.mrpack

# Idem + contrôle en ligne contre l'API Modrinth (sha512 et tailles distants)
python3 tools/validate_mrpack.py dist/6ix7even-1.1.0.mrpack --online
```

Pré-requis : **Python 3.9+**, bibliothèque standard uniquement (`zipfile`) — aucune dépendance externe.

Le `.mrpack` produit est **déterministe** : timestamps ZIP figés au 1er janvier 1980, ordre des entrées stable, attributs UNIX forcés. Deux exécutions successives donnent donc le **même SHA-256**.

```text
# build 1.1.0 (actuel) — mesuré sur le mods/manifest.json v1.1.0
e91e72af53774505e1cbb253185f2d36f2816ad80fdb0ff48ca66cd8a33604cb  6ix7even-1.1.0.mrpack

# build 1.0.0 (référence antérieure, local)
9aa3b8ebda7b58f5a32eadbfd83380938eb8eb80ad72b7e0d227d7c113663345  6ix7even-1.0.0.mrpack

# artefact DÉJÀ PUBLIÉ (nom d'origine inchangé) — version Modrinth 1.0.0 + releases GitHub
0ca18926fd2ca239ec0e5843707954a202bc68de5edb0875822bd83d0cafa1f3  artlab-client-1.0.0.mrpack
```

> Ces empreintes sont des **références de reproductibilité**, pas des contrôles d'intégrité : elles changent dès que le manifeste change (un mod, une version ou une URL de plus). Le contrôle d'intégrité, lui, est fait par `tools/validate_mrpack.py`, qui recalcule les empreintes de chaque `.jar` réel.

Le pack contient `modrinth.index.json` à la racine, au [format de pack Modrinth](https://github.com/modrinth/code/blob/main/apps/labrinth/src/models/v3/pack.rs) : `formatVersion` 1, `game` `minecraft`, `versionId` `1.1.0`, `name`, `summary`, `dependencies` (`minecraft` 26.3 + `fabric-loader` 0.19.5) et **24 entrées** `files[]` (`path`, `hashes` sha1/sha512, `env`, `downloads`, `fileSize`).

Le dossier `overrides/` est présent et contient **39 fichiers** :

| Dossier | Contenu | Nombre |
|---|---|---:|
| `overrides/config/` | configurations des mods (Distant Horizons, Iris, Sodium, Lithium, Plasmo Voice, Mod Menu, YACL, …) | 27 fichiers |
| `overrides/resourcepacks/` | resource packs de l'instance de référence | 7 fichiers |
| `overrides/shaderpacks/` | shader packs de l'instance de référence | 4 packs (+ 1 `.txt`) |

Les `.jar` ne sont **pas** embarqués : le launcher les télécharge depuis `cdn.modrinth.com` et vérifie les empreintes.

`tools/validate_mrpack.py` recalcule SHA-1, SHA-512 et la taille de chaque `.jar` depuis les fichiers réels, les compare à l'index, contrôle les dépendances, vérifie qu'il y a une entrée par mod du manifeste et que chaque URL suit la forme `https://cdn.modrinth.com/data/<project_id>/versions/<version_id>/<fichier>`, et sort en code 1 au moindre écart. Un contrôle supplémentaire de l'API Modrinth (`GET /v2/version/<version_id>`, sha512 et taille distants) est disponible via `--online` ; sans ce drapeau, la validation reste **hors ligne et déterministe**.

**Installation** : importer `dist/6ix7even-1.1.0.mrpack` dans le launcher Modrinth (« Import pack »), ou dans tout launcher compatible `.mrpack` — le launcher installe Minecraft 26.3 + Fabric Loader 0.19.5, les 24 mods du pack, et dépose les resource packs, shader packs et configs dans l'instance. Une fois la modération Modrinth validée, la [page du projet](https://modrinth.com/modpack/6ix7even) permettra en plus l'installation en un clic depuis le launcher.

| Launcher | Import `.mrpack` | Comment faire |
|---|---|---|
| **Modrinth App** (Windows / Linux / macOS) | ✅ | Lance l'app → onglet **Modpacks** → **Import pack** → choisis `dist/6ix7even-1.1.0.mrpack` (les libellés du menu varient selon la version de l'app) |
| **Prism Launcher** / **MultiMC** | ✅ | **Add profile** / **New instance** → **Import from file** → `dist/6ix7even-1.1.0.mrpack` |
| **Minecraft Launcher officiel** (Microsoft) | ❌ | Le launcher officiel sait utiliser un **profil Fabric** (voir [Compatibilité launcher](#compatibilité-launcher)) mais **n'importe pas** de `.mrpack` : utilise le Modrinth App, ou l'[installation manuelle](#installation-manuelle) des 24 `.jar` |
| **TLauncher** / **SKLauncher** | ⚠️ non couvert | Leur gestion des mods est **propriétaire** et hors du périmètre de ce pack : pour rester aligné sur le pack, utilise le **Modrinth App** ou l'installation manuelle des 24 `.jar` |

> Ce tableau décrit uniquement l'**import du fichier `.mrpack`**. Les 24 `.jar` restent installables à la main dans n'importe quel launcher ([Liens Modrinth](#liens-modrinth-pour-téléchargement-direct)).

**Import manuel du fichier** : le `.mrpack` est une **archive ZIP** — tu peux l'ouvrir, lire `modrinth.index.json` et en tirer la liste des 24 mods avec leur URL de téléchargement et leurs empreintes, puis les installer à la main comme indiqué dans [Liens Modrinth](#liens-modrinth-pour-téléchargement-direct) :

```bash
# Le .mrpack est un ZIP : l'index se lit sans installer le pack
unzip -p dist/6ix7even-1.1.0.mrpack modrinth.index.json | python3 -m json.tool
```

> Le pack **publié** est **versionné dans le dépôt** : `dist/6ix7even-1.1.0.mrpack` (22 575 641 o, SHA-256 `e91e72af53774505e1cbb253185f2d36f2816ad80fdb0ff48ca66cd8a33604cb`), **identique** à la version Modrinth `eCYn2UJh` et à l'asset de la release GitHub `mrpack-v1.1.0`. Les autres builds de `dist/` restent ignorés par Git (`.gitignore`) : ils sont produits à la demande par la commande ci-dessus.

---

## Ressources, shaders et configs embarqués

Depuis la **1.1.0**, le `.mrpack` embarque le contenu visuel et la configuration de l'instance de référence (profil AstralRinth `artlab-client-1.0.0`).

### Resource packs (7)

| Fichier | Taille |
|---|---:|
| `Default-Dark-Mode-26.3-2026.9.0.zip` | 761 869 octets |
| `Dramatic Skys Demo 1.5.3.36.6.zip` | 13 912 171 octets |
| `FA+All_Extensions-v1.10.1.zip` | 548 952 octets |
| `FA+Player-v1.1.zip` | 110 203 octets |
| `Fresh Food.zip` | 1 396 587 octets |
| `FreshAnimations_v1.11.2_26.1+.zip` | 778 725 octets |
| `§a§lVocal Villagers §r§71.5.zip` | 1 148 267 octets |

> 6 resource packs présents dans l'instance ne sont **pas** embarqués (choix d'Arthur) : `Better-Leaves-9.6.zip`, `Default HD 128x Demo 1.8.2.7.zip`, `Enhanced Audio r7.zip`, `Faithful 64x - Release 15.zip`, `Patrix_26.3_32x_basic.zip`, `Recolourful Containers 3.1.4 (1.19.4+).zip`.

### Shader packs (4)

| Fichier | Taille |
|---|---:|
| `ComplementaryReimagined_r5.8.zip` | 544 613 octets |
| `ComplementaryUnbound_r5.9.3.zip` | 553 400 octets |
| `MakeUp-UltraFast-9.5g.zip` | 405 096 octets |
| `photon_v1.4.zip` | 3 857 333 octets |

> `ComplementaryReimagined_r5.8.zip.txt` accompagne le shader pack (note de l'auteur) et est embarqué lui aussi.

### Configs (27 fichiers)

`config/` embarque les réglages de l'instance de référence : `DistantHorizons.toml`, `ViaFabric/viafabric.yml`, `ViaFabric/viaversion.yml`, `auto-clicker-fabric.json`, `chat_heads.json5`, `chunky/config.json`, `continuity.json`, `entity_model_features.json`, `entity_texture_features.json`, `ferritecore.mixin.properties`, `iris-excluded.json`, `iris.properties`, `lithium.properties`, `modmenu.json`, `particlerain/config.json`, `plasmovoice/client.toml`, `skinlayers.json`, `sodium-mixins.properties`, `sodium-options.json`, `sound_physics_remastered/` (4 fichiers), `transition.json`, `trender.json`, `visuality.json`, `yacl.json5`.

Les réglages **spécifiques à une machine** (empreinte Sodium, cache Plasmo Voice, tâches Chunky du monde, configuration Controlify) sont **volontairement exclus** : le pack reste portable d'une machine à l'autre.

> ⚠️ Les resource packs et shader packs sont **à activer** dans les options du jeu (ressources → packs activés) : ils sont installés mais pas activés automatiquement. Les configs, elles, s'appliquent dès le premier lancement.

### Client-only : ce que le pack installe — et ce qu'il ne contient pas

Ce pack est **client-only** : il n'installe que ce qui tourne **chez le joueur**.

- **Installé par le pack** : Minecraft 26.3, Fabric Loader 0.19.5, les **24 mods client** (Fabric API, Sodium, Iris, Lithium, FerriteCore, Krypton, Mod Menu, Cloth Config, Distant Horizons, Fabric Language Kotlin, ViaFabric, Chunky, Plasmo Voice, Continuity, Controlify, Better Autoclicker, Chat Heads, Entity Model Features, Entity Texture Features, Particle Rain, 3D Skin Layers, Sound Physics Remastered, Visuality, YetAnotherConfigLib), les **7 resource packs**, les **4 shader packs** et les **27 fichiers de configuration** (voir [Ressources, shaders et configs embarqués](#ressources-shaders-et-configs-embarqués)).
- **Non installé par le pack** : la **configuration serveur** — `server.properties`, la liste des joueurs, la whitelist et les données du monde ne sont **pas** dans le `.mrpack`. Le dossier `overrides/` ne contient que du **contenu client** (configs, resource packs, shader packs) : **le pack ne contient aucun réglage serveur**.
- **Mods côté serveur** : EasyAuth et Vanish tournent **sur le serveur**, pas dans le pack client (voir [Compatibilité serveur](#compatibilité-serveur)).

Dans l'index, chaque mod est marqué `env: {client: required, server: unsupported}` : le pack ne peut pas être installé sur un serveur, et rien n'y est installé par erreur.

**Après l'installation du pack**, il reste à rejoindre le serveur :

1. Lance l'instance créée par le launcher (profil Fabric Loader 0.19.5).
2. Ajoute le serveur : **`mc.6ix7even.cc` port `25565`** (accès public) ou `artlab` port `25565` (en tailnet).
3. Connecte-toi avec n'importe quel pseudo, puis `/register <ton_mot_de_passe>` puis `/login <ton_mot_de_passe>` (voir [Accès au serveur](#accès-au-serveur)).

> Le pack reste **facultatif** : sans lui, tu te connectes et tu joues normalement — tu perds seulement le rendu optimisé, Distant Horizons, les shaders et la voix (voir l'accroche en tête de ce README).

### Page Modrinth du pack

**Page Modrinth du pack : <https://modrinth.com/modpack/6ix7even>**

Projet Modrinth `6ix7even` (id `Y6UiohXZ`), publié sous l'**organisation** id `OaROVVjY` (**inchangé** depuis la publication), type `modpack`, licence MIT, Minecraft **26.3**, chargeur **Fabric** (`client_side: required`, `server_side: unsupported`).

La version **1.0.0** (id `MkI0FmNB`, `release`) y est publiée avec le fichier `artlab-client-1.0.0.mrpack` (**2 597 o**, SHA-256 `0ca18926fd2ca239ec0e5843707954a202bc68de5edb0875822bd83d0cafa1f3` — identique à la release GitHub) : **le nom du fichier publié n'a pas changé** au rebrand du 25 novembre 2026, la republication n'a pas été faite. Le projet est **soumis à la modération Modrinth** (`status: processing`) : tant que la validation n'est pas faite, la page affiche « Project not found » et le projet n'apparaît pas encore dans les listes. D'ici là, le `.mrpack` reste téléchargeable depuis la [release GitHub `modrinth-v1.0.0`](https://github.com/artlab-org/6ix7even-modpack/releases/tag/modrinth-v1.0.0) — sous son nom d'origine, `artlab-client-1.0.0.mrpack`.

La version **1.1.0** est publiée **sur GitHub et sur Modrinth** : release [`mrpack-v1.1.0`](https://github.com/artlab-org/6ix7even-modpack/releases/tag/mrpack-v1.1.0) et version Modrinth **`eCYn2UJh`** (`status=listed`), **le même fichier des deux côtés** — `6ix7even-1.1.0.mrpack`, **22 575 641 o**, SHA-256 `e91e72af53774505e1cbb253185f2d36f2816ad80fdb0ff48ca66cd8a33604cb` — identique au build local. CDN : <https://cdn.modrinth.com/data/Y6UiohXZ/versions/eCYn2UJh/6ix7even-1.1.0.mrpack>. La **page du projet** reste en attente de modération Modrinth (`status=processing`) : « Project not found » en accès anonyme tant que le projet n'est pas approuvé — sans impact sur le téléchargement des `.mrpack`.

---

## Accès au serveur

- **Tailnet** : `artlab:25565` (100.70.152.40:25565) — pour les accès internes (`artlab` est le **nom d'hôte tailnet de la machine**, pas la marque du pack)
- **Public** : `mc.6ix7even.cc:25565` (A public → `195.201.220.239`)
- **Site du pack** : <https://web.6ix7even.cc/modpack/>

### Première connexion

1. Ajoute le serveur dans ton launcher : `artlab` port `25565` (en tailnet), ou `mc.6ix7even.cc` port `25565` (en accès public)
2. Connecte-toi avec **n'importe quel pseudo** (online-mode=false → crack + premium OK)
3. Tape `/register <ton_mot_de_passe>` (ex : `/register abc123`)
4. Tape `/login <ton_mot_de_passe>` pour te reconnecter
5. Tu peux maintenant jouer !

Si tu changes de pseudo, refais `/register` avec le nouveau pseudo.

### Commandes admin

Les admins (ElNadou, ElPouleto, arthur) ont accès à :
- `/vanish` — devenir invisible
- `/gamemode`, `/tp`, `/give`, `/effect`, `/weather`, `/time`
- `/op <pseudo>` — promouvoir un joueur (niveau 4 = tout)

---

## Chat vocal (proximité)

Le modpack installe **Plasmo Voice 2.1.17** (`plasmovoice-fabric-26.3-2.1.17.jar`) : c'est le mod de **chat vocal de proximité**. On t'entend et on entend les autres quand on est proches dans le monde ; le volume baisse avec la distance.

| Mod | Version | `version_id` Modrinth | Taille | Page Modrinth |
|---|---|---|---|---|
| [plasmo-voice](https://modrinth.com/mod/plasmo-voice) | 2.1.17 (`fabric-26.3-2.1.17`, stable) | `vKP6gBRn` | 12 248 022 octets | [modrinth.com/mod/plasmo-voice](https://modrinth.com/mod/plasmo-voice) |

- Le mod est **installé côté client** : `install.sh` / `install.ps1` le téléchargent avec le reste du modpack, tu n'as rien à faire en plus.
- **Côté serveur, le mod de voix est facultatif** : tu peux te connecter et jouer normalement même si tu ne l'as pas (ou si tu joues sans le modpack) — tu as simplement pas la voix.
- Dépendance : `fabric-api` (déjà présent dans le modpack).

### Comment vérifier que le mod est chargé

1. **Mod Menu** (le modpack contient Mod Menu 21.0.1) : dans le menu principal, ouvre **Mods** → la liste doit contenir **Plasmo Voice**, version **2.1.17**. C'est le contrôle le plus rapide.
2. **Dossier des mods** : le fichier `plasmovoice-fabric-26.3-2.1.17.jar` doit être présent dans `.minecraft/mods/` (ou `versions/<ton_profil>/mods/`).
3. **Log de lancement** : dans `logs/latest.log`, cherche `plasmovoice` — le mod doit apparaître dans les lignes de chargement.

### Réseau : le même port que le jeu

Le serveur 6ix7even utilise **le port 25565 pour les deux** — même adresse, même port, protocole différent :

| Flux | Protocole | Port |
|---|---|---|
| Minecraft (jeu) | TCP | 25565 |
| Plasmo Voice (voix) | UDP | 25565 |

Concrètement : la voix part vers **la même adresse que celle utilisée pour le jeu** : `mc.6ix7even.cc:25565` en accès public, ou `artlab:25565` en tailnet. Le jeu utilise **TCP** et la voix **UDP** sur le port `25565` ; cette correspondance d'adresse et de port est la condition pour que la whitelist `25565/UDP` corresponde au trafic de voix.

> Si tu es derrière un firewall ou un NAT, il faut autoriser **UDP 25565 en sortie** vers le serveur, en plus du TCP. Le port UDP est ouvert côté serveur par une **action manuelle d'Arthur** (règle de firewall Hetzner) : tant qu'elle n'est pas faite, tu te connectes au jeu mais tu n'entends personne.

### Version installée : la 2.1.17 stable est épinglée

L'API Modrinth renvoie les versions par date décroissante : une requête **générique** sur `/v2/project/plasmo-voice/version` récupère donc la **bêta `2.2.0-beta.2`** au lieu de la stable. C'est pour ça que `install.sh` et `install.ps1` **épinglent** explicitement la version stable (`vKP6gBRn` → `fabric-26.3-2.1.17`) et vérifient son SHA-512 : **le modpack installe toujours la stable, jamais la bêta**.

Si tu installes **à la main**, prends le fichier direct :
`plasmovoice-fabric-26.3-2.1.17.jar`
SHA-512 : `00090edb493fc6b632a6825c765ff797f8469625f2c30a44b8d07d920b6fa7159e6671d585d122d272d2e7a6e6a11f2c1cb5f81cbaf2738354ad80abd9fe8f83`
Lien CDN direct : `https://cdn.modrinth.com/data/1bZhdhsH/versions/vKP6gBRn/plasmovoice-fabric-26.3-2.1.17.jar`

> Le script de téléchargement en lot de la section [Liens Modrinth](#liens-modrinth-pour-téléchargement-direct) installe bien les **24 mods**, `plasmo-voice` compris : il l'épingle sur `vKP6gBRn` (`fabric-26.3-2.1.17`), donc **jamais** sur la bêta `2.2.0-beta.2`. Pour installer le mod de voix à la main, prends le **lien direct** ci-dessus.

---

## Compatibilité launcher

Testé sur :
- ✅ **Minecraft Launcher officiel** (Microsoft) — profil Fabric Loader 0.19.5
- ✅ **Prism Launcher** — version Fabric Loader 0.19.5
- ✅ **MultiMC** — instance Fabric Loader 0.19.5
- ✅ **TLauncher** — version Fabric 26.3 (TLauncher 4+)
- ✅ **SKLauncher** — version Fabric 26.3 (1.4+)
- ⚠️ **Badlion Client** — non testé, devrait marcher mais peux pas garantir
- ❌ **Lunar Client / Badlion / autres clients moddés** — incompatibles, ces launchers moddés ne supportent pas Fabric

---

## Upgrade

Pour mettre à jour un mod :

1. Va sur sa [page Modrinth](https://modrinth.com) (lien dans le tableau ci-dessus)
2. Vérifie que la version supporte **MC 26.3 + Fabric**
3. Télécharge le nouveau `.jar`
4. Remplace l'ancien dans `.minecraft/mods/`
5. Relance le jeu

Les **SHA512** sont vérifiés par le script d'install automatique pour éviter les corruptions.

**Depuis la 1.1.0** : le pack contient 24 mods, les resource packs, les shader packs et les configs. Pour tout mettre à jour d'un coup, réimporte `dist/6ix7even-1.1.0.mrpack` dans le launcher (ou relance `install.sh` / `install.ps1`).

---

## Notes

### Pourquoi pas OptiFine ?

OptiFine est **mort sur Fabric** : il n'a pas de build compatible Sodium, et Sodium est devenu le standard en 2024+. Le combo **Sodium + Iris** est l'équivalent moderne : moteur de rendu optimisé + shaders OptiFine-compatibles.

### Distant Horizons (LOD)

Ce mod permet une render distance quasi-infinie en générant des chunks lointains en arrière-plan. Pour en profiter :

1. Va dans `Options > Video Settings > Distant Horizons`
2. Augmente `Render Distance Horizontal` (en chunks) jusqu'à 256 ou 512
3. Alloue **au moins 4 GB de RAM** au jeu (Edit Profile → JVM Args → `-Xmx4G`)

### Voir à travers les portails du Nether

Pas de mod Fabric dédié compatible MC 26.3 à ce jour. Tu peux utiliser **Crying Portals** (resource pack) pour rendre les portails translucides.

### Java 25 LTS

MC 26.3 utilise Java 25 LTS. Si ton launcher propose une option « Java version », choisis **Java 25**.

---

## Compatibilité serveur

Le serveur attendu doit tourner avec :
- **Fabric Loader 0.19.5** (auto-installé via `itzg/minecraft-server`)
- **Mods serveur** (déjà installés) : EasyAuth, Vanish, ViaFabric, Lithium, FerriteCore, Krypton, Distant Horizons
- **Plasmo Voice** — installé côté serveur pour le chat vocal de proximité (voir [Chat vocal](#chat-vocal-proximité))

Si le serveur est down, contacte un admin.

---

---

## Troubleshooting — le jeu ne se lance pas

Si MC crashe au lancement avec le modpack, **99% du temps c'est l'une de ces 3 causes** :

### 1. Mauvaise version MC chargée (cause #1)

Le launcher Mojang officiel télécharge la dernière version stable automatiquement (en ce moment **26.5+** qui peut être incompatible avec les mods 26.3). **Tu dois forcer MC 26.3** :

1. Ouvre le launcher Mojang
2. À côté de **Jouer**, clique sur la version affichée (probablement "Latest release" ou un X.Y+)
3. Sélectionne **26.3** dans le menu déroulant
4. Relance → le modpack Fabric devrait charger

Vérification : le serveur tourne en MC **26.3 protocol 777**. Si tu essaies 26.4+, le serveur te kickera avec "Incompatible client".

### 2. Mauvais Java utilisé (cause #2)

MC 26.3 utilise Java 25 LTS. Si ton launcher utilise Java 8 ou 11 (par défaut sur Windows), Java crash.

**Vérification** : ouvre un terminal et tape `java -version`. Tu dois voir **Java 25**.

**Fix** : dans le launcher Mojang → **Installations** → choisis ton profil Fabric → **Edit** → **Java version** → change vers **25** (bouton "..." à droite du champ Java executable). Si **Java 25** n'est pas listé, installe-le via Adoptium (https://adoptium.net/) et pointe le launcher vers le chemin complet (`C:\Program Files\Eclipse Adoptium\jdk-25.0.4.1-hotspot\bin\javaw.exe`).

### 3. Fabric Loader pas installé ou mauvaise version (cause #3)

Le modpack a besoin de **Fabric Loader 0.19.5**. Si tu utilises un profil vanilla sans Fabric Loader :

1. Va sur https://maven.fabricmc.net/net/fabricmc/fabric-loader/0.19.5/fabric-loader-0.19.5.jar
2. Télécharge `fabric-loader-0.19.5.jar`
3. Lance-le avec Java 25+ : `java -jar fabric-loader-0.19.5.jar client -mcversion 26.3 -loader 0.19.5`
4. Sélectionne ton profil MC 26.3, clique **Install**

Ou via MultiMC/Prism : ajoute une instance "Fabric" depuis le launcher, sélectionne version 26.3, installe, mets les mods dans `.minecraft/mods/`.

---



### 4. SKLauncher a installé ses propres mods 26.1 par défaut

Si tu utilises **SKLauncher** (ou TLauncher avec profil Fabric), le launcher peut **injecter ses propres mods** (Zoomify, Controlify, YetAnotherConfigLib, ViaFabric-mc26-1) qui sont pour **MC 26.1** et bloquent le boot MC 26.3 avec :

```
Incompatible mods found!
net.fabricmc.loader.impl.FormattedException: Some of your mods are incompatible with the game or each other!
```

**Fix** : réinstalle mon modpack avec `-Clean` (ça wipe les mods 26.1) :

```powershell
irm https://raw.githubusercontent.com/artlab-org/6ix7even-modpack/main/install.ps1 | iex -args @{Launcher='sklauncher'; Clean=$true}
```

OU manuellement :
1. Va dans `versions\<ton_profil_fabric>\mods\`
2. Supprime tous les .jar qui ne sont PAS dans la liste de mon modpack (24 mods) :
   `betterAutoclicker-fabric-1.4.4+mc26.3.jar`
   `chat_heads-1.3.3-fabric-26.3.jar`
   `Chunky-Fabric-1.5.66.jar`
   `cloth-config-fabric-26.3.159.jar`
   `continuity-3.0.1+26.3.jar`
   `controlify-3.5.3+mc26.3-universal.jar`
   `DistantHorizons-3.3.4-26.3-fabric-neoforge.jar`
   `entity_model_features-3.3.12-26.3-fabric.jar`
   `entity_texture_features-7.2.7-26.3-fabric.jar`
   `fabric-api-0.166.2+26.3.jar`
   `fabric-language-kotlin-1.14.2+kotlin.2.4.21.jar`
   `ferritecore-9.0.0-fabric.jar`
   `iris-fabric-1.11.7+mc26.3.jar`
   `krypton-0.3.2.jar`
   `lithium-fabric-0.26.3+mc26.3.jar`
   `modmenu-21.0.1.jar`
   `particlerain-4.0.4+26.3-fabric.jar`
   `plasmovoice-fabric-26.3-2.1.17.jar`
   `skinlayers3d-fabric-1.11.4-mc26.3.jar`
   `sodium-fabric-0.9.3-beta.1+mc26.3.jar`
   `sound-physics-remastered-fabric-1.5.4+26.3.jar`
   `ViaFabric-0.4.22+186-26.x.jar`
   `visuality-0.7.15+26.3.jar`
   `yet_another_config_lib_v3-3.9.7+26.3-fabric.jar`
3. Relance MC

Note : `ViaFabric` a 2 versions (`viafabric` pour 26.3 et `viafabric-mc26-1` pour 26.1). Tu dois garder uniquement la version **26.3**.


## Crash report à m'envoyer si rien ne marche

Si après ces 3 fixes le jeu crashe encore, envoie-moi :
1. **logs/latest.log** depuis `.minecraft/logs/latest.log` (ou `.minecraft/versions/1.21.x-yyyy.z.z/latest.log`)
2. **crash-reports/latest.txt** depuis `.minecraft/crash-reports/`
3. **Version MC** exacte (en haut du launcher)
4. **Version Java** (`java -version` dans un terminal)
5. **OS** + version launcher (officiel/MultiMC/Prism/TLauncher/SKLauncher)
6. **Contenu de .minecraft/mods/** (`ls .minecraft/mods/`)

Avec ça je peux diagnostiquer en 30s.


---

## License

MIT — voir [LICENSE](./LICENSE).

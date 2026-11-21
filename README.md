# mc-modpack-client — Modpack client artlab Minecraft (MC 26.3 Fabric)

**Modpack Fabric facultatif pour le serveur artlab Minecraft (MC 26.3).**

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
4. [Liens Modrinth (téléchargement direct)](#liens-modrinth-pour-téléchargement-direct)
5. [Pack Modrinth (.mrpack)](#pack-modrinth-mrpack)
6. [Accès au serveur](#accès-au-serveur)
7. [Chat vocal (proximité)](#chat-vocal-proximité)
8. [Compatibilité launcher](#compatibilité-launcher)
9. [Upgrade](#upgrade)
10. [Notes](#notes)

---

## Pré-requis

- **Java 21 ou plus récent** (MC 26.3 utilise Java 25 LTS)
- **Minecraft Java Edition 26.3** installé via ton launcher
- Un des launchers suivants :
  - **Minecraft Launcher officiel** (Microsoft)
  - **TLauncher** (crack)
  - **SKLauncher** (crack)
  - **MultiMC / Prism Launcher** (open-source)
- 1 GB d'espace disque (mods = ~62 Mio pour les 13 `.jar` du modpack)
- 4 GB RAM alloués au jeu (recommandé 6 GB pour Distant Horizons)

---

## Installation rapide (automatique)

### Windows (oneliner PowerShell)

Ouvre PowerShell (touche Windows, tape `powershell`, Entrée), puis colle :

```powershell
irm https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/install.ps1 | iex
```

> **Windows PowerShell 5.1** (`powershell.exe`, le défaut sur Windows 10/11) peut
> échouer avec `The request was aborted: Could not create SSL/TLS secure channel.`
> Le script force TLS 1.2 **après** avoir été téléchargé — mais si le
> *téléchargement* échoue, la version qui force TLS n'est jamais atteinte.
> **Dans ce cas, utilise la variante ci-dessous** qui force TLS 1.2 *avant* le
> download :

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
irm https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/install.ps1 | iex
```

> Si même ça échoue (TLS bloqué au niveau OS / proxy d'entreprise), utilise
> `curl.exe` (intégré à Windows 10 1803+) puis PowerShell :

```powershell
curl.exe -fsSL https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/install.ps1 -o "$env:TEMP\rtlab-mc-install.ps1"
powershell -ExecutionPolicy Bypass -File "$env:TEMP\rtlab-mc-install.ps1"
```

> **Le `| iex` ignore les paramètres** (`-Launcher`, `-Version`, `-Clean`) :
> PowerShell ne transmet pas le bloc `param()` quand le script est *piped*.
> Si tu dois choisir un launcher précis, télécharge le fichier et utilise `-File`
> (voir ci-dessus), ou passe par les variables d'environnement :

```powershell
$env:MC_LAUNCHER = "sklauncher"; irm https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/install.ps1 | iex
```

Le script :
1. Télécharge tous les mods depuis Modrinth CDN
2. Vérifie les SHA512
3. Copie dans ton dossier `.minecraft/mods/`
4. Confirme l'installation

### Linux / macOS

```bash
curl -fsSL https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/install.sh | bash
```

> Le script supporte `--dir <path>` pour cibler un dossier `.minecraft` custom (MultiMC/Prism).

### Désinstallation

```bash
# Windows
irm https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/uninstall.ps1 | iex

# Linux / macOS
bash <(curl -fsSL https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/uninstall.sh)
```

---

## Installation manuelle

Si tu préfères installer les mods à la main (ou si l'install auto ne marche pas) :

### Étape 1 — Installer Fabric Loader 0.19.5

1. Télécharge [fabric-installer.jar](https://maven.fabricmc.net/net/fabricmc/fabric-loader/0.19.5/fabric-loader-0.19.5.jar)
2. Lance-le avec Java 21+ :
   ```bash
   java -jar fabric-installer.jar client -mcversion 26.3 -loader 0.19.5
   ```
3. Sélectionne ton profil MC 26.3 vanilla, puis clique **Install**

### Étape 2 — Télécharger les mods

Va sur [Modrinth](https://modrinth.com), cherche chaque mod, vérifie la compatibilité MC 26.3 + Fabric, télécharge le `.jar`.

**OU** utilise les liens directs dans le tableau [ci-dessous](#liens-modrinth-pour-téléchargement-direct).

### Étape 3 — Copier les mods

Copie les 13 fichiers `.jar` dans ton dossier `.minecraft/mods/` (dont `plasmovoice-fabric-26.3-2.1.17.jar` pour le chat vocal) :

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

| Mod | Version | Taille |
|---|---|---:|
| [fabric-api](https://modrinth.com/mod/fabric-api) | 0.163.0+26.3 | 1,774,707 bytes |
| [sodium](https://modrinth.com/mod/sodium) | mc26.3-0.9.3-beta.1-fabric | 1,912,496 bytes |
| [iris](https://modrinth.com/mod/iris) | 1.11.7+26.3-fabric | 2,850,938 bytes |
| [lithium](https://modrinth.com/mod/lithium) | mc26.3-0.26.2-fabric | 914,543 bytes |
| [ferrite-core](https://modrinth.com/mod/ferrite-core) | 9.0.0-fabric | 72,677 bytes |
| [krypton](https://modrinth.com/mod/krypton) | 0.3.2 | 268,849 bytes |
| [modmenu](https://modrinth.com/mod/modmenu) | 21.0.0 | 856,779 bytes |
| [cloth-config](https://modrinth.com/mod/cloth-config) | 26.3.159+fabric | 1,135,009 bytes |
| [distanthorizons](https://modrinth.com/mod/distanthorizons) | 3.3.4-26.3 | 28,476,894 bytes |
| [fabric-language-kotlin](https://modrinth.com/mod/fabric-language-kotlin) | 1.14.2+kotlin.2.4.21 | 8,142,878 bytes |
| [viafabric](https://modrinth.com/mod/viafabric) | 0.4.22+186-26.x | 5,914,365 bytes |
| [chunky](https://modrinth.com/mod/chunky) | 1.5.3 | 354,095 bytes |
| [easyauth](https://modrinth.com/mod/easyauth) | 3.4.4 | 24,257,433 bytes |
| [vanish](https://modrinth.com/mod/vanish) | 1.6.16+26.3 | 1,256,413 bytes |
| [plasmo-voice](https://modrinth.com/mod/plasmo-voice) | 2.1.17 (`fabric-26.3-2.1.17`) | 12,248,022 bytes |

> Ce tableau liste 15 mods : les **13 mods client** — exactement la liste installée par `install.sh` / `install.ps1`, à copier dans `.minecraft/mods/` — plus `easyauth` et `vanish`, qui tournent **côté serveur** (voir [Compatibilité serveur](#compatibilité-serveur)) et ne sont pas installés par les scripts client.

### Téléchargement manuel en lot

Pour télécharger les **13 mods du modpack** d'un coup (PowerShell) — même liste et même épinglage de version que `install.sh` / `install.ps1` :

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
$ua = 'artlab-mc-installer/1.0 (+https://github.com/artlab-org/mc-modpack-client)'

$mods = @(
  @{ slug = "fabric-api"; version = "0.163.0+26.3" },
  @{ slug = "sodium"; version = "mc26.3-0.9.3-beta.1-fabric" },
  @{ slug = "iris"; version = "1.11.7+26.3-fabric" },
  @{ slug = "lithium"; version = "mc26.3-0.26.2-fabric" },
  @{ slug = "ferrite-core"; version = "9.0.0-fabric" },
  @{ slug = "krypton"; version = "0.3.2" },
  @{ slug = "modmenu"; version = "21.0.0" },
  @{ slug = "cloth-config"; version = "26.3.159+fabric" },
  @{ slug = "distanthorizons"; version = "3.3.4-26.3" },
  @{ slug = "fabric-language-kotlin"; version = "1.14.2+kotlin.2.4.21" },
  @{ slug = "viafabric"; version = "0.4.22+186-26.x" },
  @{ slug = "chunky"; version = "1.5.3" },
  @{ slug = "plasmo-voice"; version = "fabric-26.3-2.1.17" }
)

# Versions épinglées (identique à install.sh / install.ps1) :
# l'API Modrinth renvoie les versions par date décroissante, la 1re peut être
# une bêta (plasmo-voice 2.2.0-beta.2). On force le version_id stable.
$pinned = @{ "plasmo-voice" = "vKP6gBRn" }

# Créer le dossier cible s'il n'existe pas (comme install.ps1:251-252) :
New-Item -ItemType Directory -Path "$env:APPDATA\.minecraft\mods" -Force | Out-Null

foreach ($mod in $mods) {
  if ($pinned.ContainsKey($mod.slug)) {
    # Version épinglée : on interroge directement /v2/version/<version_id>
    $apiUrl = "https://api.modrinth.com/v2/version/$($pinned[$mod.slug])"
    $version = Invoke-RestMethod -Uri $apiUrl -TimeoutSec 30 -UserAgent $ua
  } else {
    $apiUrl = "https://api.modrinth.com/v2/project/$($mod.slug)/version?game_versions=%5B%2226.3%22%5D&loaders=%5B%22fabric%22%5D"
    $version = (Invoke-RestMethod -Uri $apiUrl -TimeoutSec 30 -UserAgent $ua)[0]
  }
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

Le pack `.mrpack` est **généré localement** depuis `mods/manifest.json` — il n'est **pas publié sur Modrinth** pour l'instant.

```bash
# Génère dist/artlab-1.0.0.mrpack — ZIP déterministe (même SHA-256 à chaque exécution)
python3 tools/build_mrpack.py

# Point d'entrée unique : génère PUIS valide (code de sortie ≠ 0 si un écart est détecté)
python3 tools/build_mrpack.py --validate

# Valider un pack déjà construit
python3 tools/validate_mrpack.py dist/artlab-1.0.0.mrpack
```

Pré-requis : **Python 3.9+**, bibliothèque standard uniquement (`zipfile`) — aucune dépendance externe.

Le `.mrpack` produit est **déterministe** : timestamps ZIP figés au 1er janvier 1980, ordre des entrées stable, attributs UNIX forcés. Deux exécutions successives donnent donc le **même SHA-256** — mesuré le 21 novembre 2026 sur le `mods/manifest.json` actuel :

```text
0ca18926fd2ca239ec0e5843707954a202bc68de5edb0875822bd83d0cafa1f3  artlab-1.0.0.mrpack
```

> Cette empreinte est une **référence de reproductibilité**, pas un contrôle d'intégrité : elle change dès que le manifeste change (un mod, une version ou une URL de plus). Le contrôle d'intégrité, lui, est fait par `tools/validate_mrpack.py`, qui recalcule les empreintes de chaque `.jar` réel.

Le pack contient `modrinth.index.json` à la racine, au [format de pack Modrinth](https://github.com/modrinth/code/blob/main/apps/labrinth/src/models/v3/pack.rs) : `formatVersion` 1, `game` `minecraft`, `versionId`, `name`, `summary`, `dependencies` (`minecraft` 26.3 + `fabric-loader` 0.19.5) et 13 entrées `files[]` (`path`, `hashes` sha1/sha512, `env`, `downloads`, `fileSize`). Un dossier `overrides/` n'est ajouté **que** si `config/`, `resourcepacks/` ou `shaderpacks/` contiennent du contenu réel. Les `.jar` ne sont pas embarqués : le launcher les télécharge depuis `cdn.modrinth.com` et vérifie les empreintes.

`tools/validate_mrpack.py` recalcule SHA-1, SHA-512 et la taille de chaque `.jar` depuis les fichiers réels, les compare à l'index, contrôle les dépendances et les 13/13 mods, et sort en code 1 au moindre écart.

**Installation** : importer `dist/artlab-1.0.0.mrpack` dans le launcher Modrinth (« Import pack »), ou dans tout launcher compatible `.mrpack` — le launcher installe Minecraft 26.3 + Fabric Loader 0.19.5 et les 13 mods du pack.

| Launcher | Import `.mrpack` | Comment faire |
|---|---|---|
| **Modrinth App** (Windows / Linux / macOS) | ✅ | Lance l'app → onglet **Modpacks** → **Import pack** → choisis `dist/artlab-1.0.0.mrpack` (les libellés du menu varient selon la version de l'app) |
| **Prism Launcher** / **MultiMC** | ✅ | **Add profile** / **New instance** → **Import from file** → `dist/artlab-1.0.0.mrpack` |
| **Minecraft Launcher officiel** (Microsoft) | ❌ | Le launcher officiel sait utiliser un **profil Fabric** (voir [Compatibilité launcher](#compatibilité-launcher)) mais **n'importe pas** de `.mrpack` : utilise le Modrinth App, ou l'[installation manuelle](#installation-manuelle) des 13 `.jar` |
| **TLauncher** / **SKLauncher** | ⚠️ non couvert | Leur gestion des mods est **propriétaire** et hors du périmètre de ce pack : pour rester aligné sur le pack, utilise le **Modrinth App** ou l'installation manuelle des 13 `.jar` |

> Ce tableau décrit uniquement l'**import du fichier `.mrpack`**. Les 13 `.jar` restent installables à la main dans n'importe quel launcher ([Liens Modrinth](#liens-modrinth-pour-téléchargement-direct)).

**Import manuel du fichier** : le `.mrpack` est une **archive ZIP** — tu peux l'ouvrir, lire `modrinth.index.json` et en tirer la liste des 13 mods avec leur URL de téléchargement et leurs empreintes, puis les installer à la main comme indiqué dans [Liens Modrinth](#liens-modrinth-pour-téléchargement-direct) :

```bash
# Le .mrpack est un ZIP : l'index se lit sans installer le pack
unzip -p dist/artlab-1.0.0.mrpack modrinth.index.json | python3 -m json.tool
```

> Le dossier `dist/` est ignoré par Git (`.gitignore`) : le `.mrpack` n'est **pas versionné**. Il est produit à la demande par la commande ci-dessus, ou fourni en pièce jointe par le canal de distribution du projet.

### Client-only : ce que le pack installe — et ce qu'il ne contient pas

Ce pack est **client-only** : il n'installe que ce qui tourne **chez le joueur**.

- **Installé par le pack** : Minecraft 26.3, Fabric Loader 0.19.5 et les **13 mods client** (Fabric API, Sodium, Iris, Lithium, FerriteCore, Krypton, Mod Menu, Cloth Config, Distant Horizons, Fabric Language Kotlin, ViaFabric, Chunky, Plasmo Voice).
- **Non installé par le pack** : la **configuration serveur** — `server.properties`, la liste des joueurs, la whitelist et les données du monde ne sont **pas** dans le `.mrpack`. Un dossier `overrides/` n'est embarqué que si `config/`, `resourcepacks/` ou `shaderpacks/` contiennent du contenu réel ; à ce jour ces dossiers ne contiennent que des `.gitkeep`, donc **le pack ne contient que `modrinth.index.json`** (13 entrées, 7 458 octets).
- **Mods côté serveur** : EasyAuth et Vanish tournent **sur le serveur**, pas dans le pack client (voir [Compatibilité serveur](#compatibilité-serveur)).

Dans l'index, chaque mod est marqué `env: {client: required, server: unsupported}` : le pack ne peut pas être installé sur un serveur, et rien n'y est installé par erreur.

**Après l'installation du pack**, il reste à rejoindre le serveur :

1. Lance l'instance créée par le launcher (profil Fabric Loader 0.19.5).
2. Ajoute le serveur : **`mc.6ix7even.cc` port `25565`** (accès public) ou `artlab` port `25565` (en tailnet).
3. Connecte-toi avec n'importe quel pseudo, puis `/register <ton_mot_de_passe>` puis `/login <ton_mot_de_passe>` (voir [Accès au serveur](#accès-au-serveur)).

> Le pack reste **facultatif** : sans lui, tu te connectes et tu joues normalement — tu perds seulement le rendu optimisé, Distant Horizons, les shaders et la voix (voir l'accroche en tête de ce README).

### Page Modrinth du pack — URL à compléter

<!-- MODRINTH_URL -->
<!-- URL attendue : https://modrinth.com/modpack/<slug> -->

**Page Modrinth du pack : URL à compléter.** Le projet Modrinth n'existe pas encore : le pack est distribué par ce dépôt uniquement. Le marqueur `MODRINTH_URL` ci-dessus devra être remplacé par l'URL réelle (`https://modrinth.com/modpack/<slug>`) le jour où le projet Modrinth sera créé.

> ⚠️ **Slug Modrinth du projet : à compléter.** Le projet n'existe pas encore sur Modrinth : le pack n'est distribué que par ce dépôt, rien n'est publié. Quand le slug sera fixé, le remplacer dans `tools/build_mrpack.py` (`DEFAULT_SLUG`) et dans cette section — ne pas publier avant validation.

---

## Accès au serveur

- **Tailnet** : `artlab:25565` (100.70.152.40:25565) — pour les accès internes
- **Public** : `mc.6ix7even.cc:25565` (A public → `195.201.220.239`)

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

1. **Mod Menu** (le modpack contient Mod Menu 21.0.0) : dans le menu principal, ouvre **Mods** → la liste doit contenir **Plasmo Voice**, version **2.1.17**. C'est le contrôle le plus rapide.
2. **Dossier des mods** : le fichier `plasmovoice-fabric-26.3-2.1.17.jar` doit être présent dans `.minecraft/mods/` (ou `versions/<ton_profil>/mods/`).
3. **Log de lancement** : dans `logs/latest.log`, cherche `plasmovoice` — le mod doit apparaître dans les lignes de chargement.

### Réseau : le même port que le jeu

Le serveur Artlab utilise **le port 25565 pour les deux** — même adresse, même port, protocole différent :

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

> Le script de téléchargement en lot de la section [Liens Modrinth](#liens-modrinth-pour-téléchargement-direct) installe bien les **13 mods**, `plasmo-voice` compris : il l'épingle sur `vKP6gBRn` (`fabric-26.3-2.1.17`), donc **jamais** sur la bêta `2.2.0-beta.2`. Pour installer le mod de voix à la main, prends le **lien direct** ci-dessus.

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

MC 26.3 utilise Java 25 LTS. Si ton launcher propose une option « Java version », choisis Java 21+ (de préférence Java 25).

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

**Vérification** : ouvre un terminal et tape `java -version`. Tu dois voir Java 21+ (idéalement 25).

**Fix** : dans le launcher Mojang → **Installations** → choisis ton profil Fabric → **Edit** → **Java version** → change vers 21+ (bouton "..." à droite du champ Java executable). Si Java 21+ n'est pas listé, installe-le via Adoptium (https://adoptium.net/) et pointe le launcher vers le chemin complet (`C:\Program Files\Eclipse Adoptium\jdk-25.0.4.1-hotspot\bin\javaw.exe`).

### 3. Fabric Loader pas installé ou mauvaise version (cause #3)

Le modpack a besoin de **Fabric Loader 0.19.5**. Si tu utilises un profil vanilla sans Fabric Loader :

1. Va sur https://maven.fabricmc.net/net/fabricmc/fabric-loader/0.19.5/fabric-loader-0.19.5.jar
2. Télécharge `fabric-loader-0.19.5.jar`
3. Lance-le avec Java 21+ : `java -jar fabric-loader-0.19.5.jar client -mcversion 26.3 -loader 0.19.5`
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
irm https://raw.githubusercontent.com/artlab-org/mc-modpack-client/main/install.ps1 | iex -args @{Launcher='sklauncher'; Clean=$true}
```

OU manuellement :
1. Va dans `versions\<ton_profil_fabric>\mods\`
2. Supprime tous les .jar qui ne sont PAS dans la liste de mon modpack (13 mods) :
   `fabric-api`, `sodium`, `iris`, `lithium`, `ferrite-core`, `krypton`, `modmenu`, `cloth-config`, `distanthorizons`, `fabric-language-kotlin`, `viafabric`, `chunky`, `plasmo-voice`
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

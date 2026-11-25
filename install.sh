#!/usr/bin/env bash
# 6ix7even MC modpack install script (Linux/macOS)
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/artlab-org/6ix7even-modpack/main/install.sh | bash
#   curl -fsSL ... | bash -s -- --launcher auto --clean
#   curl -fsSL ... | bash -s -- --launcher sklauncher --version 26.3
#   curl -fsSL ... | bash -s -- --launcher multimc --instance 6ix7even
#   curl -fsSL ... | bash -s -- --dir /path/to/.minecraft/mods
#
# Launchers supported: auto | official | sklauncher | multimc | prism | custom

set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/artlab-org/6ix7even-modpack/main"
MC_VERSION="${MC_VERSION:-26.3}"
LAUNCHER="auto"
CLEAN=0
DIR_OVERRIDE=""
INSTANCE=""
PRISM_LAUNCHER_BIN_DIR="${MC_PRISM_BIN:-}"
SKLAUNCHER_BIN_DIR="${MC_SKLAUNCHER_BIN:-}"

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --launcher) LAUNCHER="$2"; shift 2 ;;
        --version) MC_VERSION="$2"; shift 2 ;;
        --clean) CLEAN=1; shift ;;
        --dir) DIR_OVERRIDE="$2"; shift 2 ;;
        --instance) INSTANCE="$2"; shift 2 ;;
        --prism-bin) PRISM_LAUNCHER_BIN_DIR="$2"; shift 2 ;;
        --sklauncher-bin) SKLAUNCHER_BIN_DIR="$2"; shift 2 ;;
        -h|--help)
            sed -n '2,16p' "$0"
            exit 0 ;;
        *) echo "Unknown arg: $1" >&2; exit 1 ;;
    esac
done

echo ""
echo "=== 6ix7even MC modpack installer ==="
echo "Launcher: $LAUNCHER | MC version: $MC_VERSION | Clean: $CLEAN"
echo ""

# ====== Launcher detection ======

detect_sklauncher() {
    # SKLauncher (Windows) — WSL detection: look for SKLauncher.exe in mounted Windows drives
    # On Linux/macOS, SKLauncher is unlikely, but check WSL just in case
    if [[ -n "$SKLAUNCHER_BIN_DIR" && -d "$SKLAUNCHER_BIN_DIR" ]]; then
        echo "$SKLAUNCHER_BIN_DIR"
        return 0
    fi
    # Try common paths
    local candidates=(
        "/mnt/c/Users/$USER/AppData/Roaming/.minecraft/versions"
        "$HOME/.minecraft/versions"
    )
    for c in "${candidates[@]}"; do
        if [[ -d "$c" ]]; then
            # Check if SKLauncher is the source — heuristic: presence of SKLauncher-specific dirs
            echo "$c"
            return 0
        fi
    done
    return 1
}

detect_prism_or_multimc() {
    # MultiMC / Prism : look for instances dir
    local candidates=(
        "$HOME/.local/share/PrismLauncher/instances"
        "$HOME/.local/share/multimc/instances"
        "$HOME/.multimc/instances"
        "$HOME/.prismlauncher/instances"
    )
    for c in "${candidates[@]}"; do
        if [[ -d "$c" ]]; then
            echo "$c"
            return 0
        fi
    done
    return 1
}

find_mods_dir() {
    # Custom override
    if [[ -n "$DIR_OVERRIDE" ]]; then
        mkdir -p "$DIR_OVERRIDE"
        echo "$DIR_OVERRIDE"
        return 0
    fi

    case "$LAUNCHER" in
        official)
            mkdir -p "$HOME/.minecraft/mods"
            echo "$HOME/.minecraft/mods"
            return 0
            ;;
        sklauncher)
            local versions_dir
            if ! versions_dir=$(detect_sklauncher); then
                echo "SKLauncher .minecraft/versions not found" >&2
                echo "Set --sklauncher-bin or run on Windows" >&2
                exit 1
            fi

            # Find a profile directory matching MC version + Fabric/loader
            local match=""
            match=$(python3 -c "
import os, glob
v='$versions_dir'; mv='$MC_VERSION'
for d in glob.glob(os.path.join(v,'*')):
    if not os.path.isdir(d): continue
    n=os.path.basename(d)
    if mv in n and any(x in n.lower() for x in ['fabric','loader']):
        print(d); break
" 2>/dev/null)

            if [[ -z "$match" ]]; then
                echo "No Fabric profile for MC $MC_VERSION in $versions_dir" >&2
                echo "Available:"
                find "$versions_dir" -mindepth 1 -maxdepth 1 -type d -printf "  %f\n" 2>/dev/null
                exit 1
            fi

            local mods="$match/mods"
            mkdir -p "$mods"
            echo "$mods"
            return 0
            ;;
        multimc)
            local root
            if ! root=$(detect_prism_or_multimc); then
                echo "MultiMC root not found" >&2; exit 1
            fi
            [[ -z "$INSTANCE" ]] && { echo "multimc needs --instance <name>" >&2; exit 1; }
            local d="$root/$INSTANCE/.minecraft/mods"
            [[ ! -d "$root/$INSTANCE" ]] && { echo "MultiMC instance not found: $root/$INSTANCE" >&2; exit 1; }
            mkdir -p "$d"
            echo "$d"
            return 0
            ;;
        prism)
            local root
            if ! root=$(detect_prism_or_multimc); then
                echo "Prism root not found" >&2; exit 1
            fi
            [[ -z "$INSTANCE" ]] && { echo "prism needs --instance <name>" >&2; exit 1; }
            local d="$root/$INSTANCE/.minecraft/mods"
            [[ ! -d "$root/$INSTANCE" ]] && { echo "Prism instance not found: $root/$INSTANCE" >&2; exit 1; }
            mkdir -p "$d"
            echo "$d"
            return 0
            ;;
        custom)
            [[ -z "$DIR_OVERRIDE" ]] && { echo "custom needs --dir <path>" >&2; exit 1; }
            mkdir -p "$DIR_OVERRIDE"
            echo "$DIR_OVERRIDE"
            return 0
            ;;
        auto)
            # Linux/macOS : SKLauncher irrelevant unless WSL. Try Prism → MultiMC → official
            if detect_prism_or_multimc >/dev/null 2>&1; then
                local root
                root=$(detect_prism_or_multimc)
                local instances=()
                while IFS= read -r d; do instances+=("$d"); done < <(find "$root" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
                if [[ ${#instances[@]} -gt 0 ]]; then
                    if [[ -z "$INSTANCE" ]]; then
                        INSTANCE=$(basename "${instances[0]}")
                        echo "[auto] Using Prism/MultiMC instance: $INSTANCE (use --instance to override)"
                    fi
                    # Detect prism vs multimc by path
                    if [[ "$root" == *Prism* ]] || [[ "$root" == *prism* ]]; then
                        local d="$root/$INSTANCE/.minecraft/mods"
                        mkdir -p "$d"
                        echo "$d"
                        return 0
                    else
                        local d="$root/$INSTANCE/.minecraft/mods"
                        mkdir -p "$d"
                        echo "$d"
                        return 0
                    fi
                fi
            fi
            # Fallback : .minecraft/mods
            mkdir -p "$HOME/.minecraft/mods"
            echo "$HOME/.minecraft/mods"
            return 0
            ;;
        *)
            echo "Unknown launcher: $LAUNCHER" >&2
            exit 1
            ;;
    esac
}

MODS_DIR=$(find_mods_dir)
echo "Mods target dir: $MODS_DIR"
echo ""

# ====== Verify Java ======
if ! command -v java >/dev/null 2>&1; then
    echo "Error: java not in PATH" >&2
    echo "Installe Java 25+ : https://adoptium.net/" >&2
    exit 1
fi
java -version 2>&1 | head -1 | sed "s/^/Java detecte: /"

# ====== Clean if requested ======
if [[ "$CLEAN" = "1" ]]; then
    echo ""
    echo "=== Cleaning existing mods ==="
    if compgen -G "$MODS_DIR/*.jar" >/dev/null; then
        local_count=$(find "$MODS_DIR" -maxdepth 1 -name "*.jar" | wc -l)
        echo "Removing $local_count existing mod .jar:"
        find "$MODS_DIR" -maxdepth 1 -name "*.jar" -exec rm -f {} \;
        find "$MODS_DIR" -maxdepth 1 -name "*.jar.disabled" -exec rm -f {} \;
    else
        echo "No existing mods"
    fi
fi

mkdir -p "$MODS_DIR"

# ====== Download from Modrinth ======
MODS=(
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
# (format slug:version_id) : c'est exactement l'ensemble teste sur l'instance
# de reference, pas "la derniere version publiee".
PINNED_VERSIONS=(
    "better-autoclicker:6pYrIgDv"
    "chat-heads:9O2ZSOkh"
    "chunky:86FKD9qx"
    "cloth-config:fg2uyxOW"
    "continuity:Jt2sCWTQ"
    "controlify:fo76vL20"
    "distanthorizons:TGgEbP9A"
    "entity-model-features:vF6qLXsA"
    "entitytexturefeatures:svwZ2o4d"
    "fabric-api:Zns5SSRA"
    "fabric-language-kotlin:SKW1BTL3"
    "ferrite-core:d5ddUdiB"
    "iris:vTN4NRGW"
    "krypton:UugdIYJw"
    "lithium:fWv5bnZk"
    "modmenu:xckkBHD5"
    "particle-rain:PbaF66N6"
    "plasmo-voice:vKP6gBRn"
    "3dskinlayers:gjM2TO0L"
    "sodium:g6ju16VJ"
    "sound-physics-remastered:29UOgzLw"
    "viafabric:qiAP0t9R"
    "visuality:BNe9kpJ7"
    "yacl:s9SjoFu1"
)

# ====== SHA-512 attendus (source : mods/manifest.json) ======
# Le hash attendu est verifie en local : meme si l'API Modrinth repond avec
# une autre empreinte, c'est celle du manifeste qui fait foi.
EXPECTED_SHA512=(
    "6pYrIgDv|c43e397976fe2a7fb016c34f7d42804d7d5fec0c1e2e28de174106ce005a17b92bc8ab98817fcd56a9e9872d60b02482fe6baf2a59877b366e7e062148b408d5"
    "9O2ZSOkh|8f6d3c42128ca54252090c5b5c06cf68c98c106b454aaec9dd94aa1ccd499fd2603b44d559f4ee9b8124c1eaf86233ba2290ba2f93d07480fe2e9fe3c534bfb5"
    "86FKD9qx|6f0323daa69d61bd3b3fbe9d8b713664d9b7c69182183f8dcff6362b43783639778a96e32215dbfd329588f06b60a5d93656dbb1d391c660db203482aa972d5e"
    "fg2uyxOW|8924e19d41845096724fa10f3717bc51964a0edbbbcad0ff1e6c6187a398b08f356e49579a657c2dc44a7f92e3850771f3ca70bf8c1f654de60425163b91dbb1"
    "Jt2sCWTQ|1ec1e3b2f73c26b19445d664822a8936e9076f4d8855a2ed5fac19786daa8da42da8fdc9526c4a53c227a82819a87ad8e73d5b4fc003f6519c50454c33014f04"
    "fo76vL20|cd4e64a9621dff200329b249dc63fc4542ce554db16c75c4b04cfa7495bf84e1a4bca0f89a7a9d4d425f6b6f23c8df52ab8ce323ee18ae49c6cf24858697bbf7"
    "TGgEbP9A|0b90b1b08d99974bfc3c8e86b2ceb252e2f91715ed66b925004c28335fb44e1bddbbb6b8043e4d4d53c87ed247789cd1788b1ba4e3f4394efe154e0c59cff236"
    "vF6qLXsA|4572fc065e757264947aff35a96d17d5e45d4b43e8e385b9a207f5380a8f43da5dbf8e10f30a7bc7cc4c0c8f7999717b4dd22d325667bdf8a0de6e839ad81efc"
    "svwZ2o4d|69193c58d4d05e08fea9afa34cc47563e9b9e95aa2da276441085ade44ed36f8123b9cc1a2938f9ecac9aea6fd9ceb51120dd20f7284337a3bb592bc3b904336"
    "Zns5SSRA|fb686a9fa923248328107a12498229d6951e316257f18b7d0e4cbd6885ba447ed50a44076a8a5ba47cfe2043b329db3587ab000aeab1face26b2587a5d4ba6b5"
    "SKW1BTL3|7fb475c4a7e7bdf8d0aca4b5798a58a354c51443d5b1fbde3e8cf34dfbf7191ef4238b5f07d08ec9490ec180b371624523326c3ad45d4ed2b2be541de9407e5d"
    "d5ddUdiB|d81fa97e11784c19d42f89c2f433831d007603dd7193cee45fa177e4a6a9c52b384b198586e04a0f7f63cd996fed713322578bde9a8db57e1188854ae5cbe584"
    "vTN4NRGW|d8d3312f77fc52a48e4a6cd836fda33669bdebcb4de0b8c0d30adc808b287330a533e0baef355cc1ce6336a26851d9775369a802a4666b7b7a6266af20088f42"
    "UugdIYJw|d1d57ebd41395b75b01f130cd9503eb8d208212424a399ff9f367f50be8fbc1c6472442b33c686e777c3148f6a609520e8fb732c755157c358cb207fd4d1123a"
    "fWv5bnZk|2ca92fb530135d2baddf0ba4cc4f93976234876a38c4aa02b487b2552400f005afcfbeebf5373fb4396fe2020537a42d7597b8da5a52b904355ef51d5fef07ad"
    "xckkBHD5|d00d52d5342728da13a6237f76c50fc5fd1c62d8112ae4e07726bbc64d2019a76130d6b2968765df81c6499225588eacee6681eebc13c0ada3cad91fc8ab2984"
    "PbaF66N6|8322aa75ec672ae63a4ea78936fd4cb96d8a06c5411bf6d2a76cdbaac1c06ebc7a96cd81125914e91db9f3a1a52e3be0ac8a44d2b5131ab9837a23726bd4206f"
    "vKP6gBRn|00090edb493fc6b632a6825c765ff797f8469625f2c30a44b8d07d920b6fa7159e6671d585d122d272d2e7a6e6a11f2c1cb5f81cbaf2738354ad80abd9fe8f83"
    "gjM2TO0L|1a93ba9f726f8053e111abbe225f67b85e74bdfb78955711218ef103e670bc2c0f011f5911bf725686b79a1b85cecbb1ba733bf1b2eaa2856e53c4f842680627"
    "g6ju16VJ|884a1ef0ce0e69d565d41a1359070a8d4f8589a086b565540defdb4741985053077dfd0f2a56898ce60510720a9f95dd8ba220a9a6340b6e0cf5cb12352e2419"
    "29UOgzLw|dcd812a812ce04d87dbab0bf24fc42ef6a3ddd8150a98e45c78963bb0bfaf6cba6b9464101cf8a8d4d9551bc4ae0c300913b99715eaff787aba744a3c08317f2"
    "qiAP0t9R|9098d75597b5a91bb50fa80228e729e87ed9aee70e19fda86fdc4c0e73127eaf1b7ece5b71a61149b34d9a8e17c0560f4be0d6c15537e7361d20e0fd641b6f4e"
    "BNe9kpJ7|90145cad547d329d5134eabbf45c7f35b1d0ce3ff2bcef8a1b187dc33723121b1a235c0cc259043588835b0cb7b31cba4aa84d738be810f0ea073308bec2eb4a"
    "s9SjoFu1|f3957028dd31cae78f08aee3e768f61bd12c4c8423257d357bc3c1a2172047c769d37901f99775c7ffff1e5ee794025dc72738b2869cab06f1c2811841d68b24"
)

pinned_version_id() {
    local slug="$1" entry
    for entry in "${PINNED_VERSIONS[@]}"; do
        [[ "${entry%%:*}" == "$slug" ]] || continue
        echo "${entry##*:}"
        return 0
    done
    return 1
}

expected_sha512() {
    local version_id="$1" entry
    for entry in "${EXPECTED_SHA512[@]}"; do
        [[ "${entry%%|*}" == "$version_id" ]] || continue
        echo "${entry##*|}"
        return 0
    done
    return 1
}

echo ""
echo "Telechargement de ${#MODS[@]} mods depuis Modrinth (MC $MC_VERSION + Fabric)..."

ok=0
skipped=0
failed=0

for slug in "${MODS[@]}"; do
    echo ""
    echo "[$slug]"

    pinned_id="$(pinned_version_id "$slug" || true)"

    if [[ -n "$pinned_id" ]]; then
        api_url="https://api.modrinth.com/v2/version/$pinned_id"
    else
        api_url="https://api.modrinth.com/v2/project/$slug/version?loaders=%5B%22fabric%22%5D&game_versions=%5B%22$MC_VERSION%22%5D"
    fi

    api_json=$(curl -fsS "$api_url" 2>&1) || {
        echo "  ERREUR API Modrinth pour $slug" >&2
        failed=$((failed+1))
        continue
    }

    if [[ -n "$pinned_id" ]]; then
        # Version epinglee : verifie qu'elle cible bien la version de MC
        # demandee, puis normalise la reponse en liste (comme l'API projet).
        if ! echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if '$MC_VERSION' in d.get('game_versions',[]) else 1)"; then
            echo "  Version epinglee $pinned_id incompatible avec MC $MC_VERSION, skip"
            skipped=$((skipped+1))
            continue
        fi
        api_json=$(echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(json.dumps([d]))")
    fi

    # Get first version's first file URL + SHA512 + version + filename
    file_url=$(echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['files'][0]['url'])" 2>/dev/null) || {
        echo "  Pas de version MC $MC_VERSION Fabric pour $slug"
        skipped=$((skipped+1))
        continue
    }
    file_name=$(echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['files'][0]['filename'])")
    expected_sha=$(echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['files'][0]['hashes']['sha512'])")
    version=$(echo "$api_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['version_number'])")

    # Le manifeste (mods/manifest.json) fait foi pour l'empreinte attendue.
    if [[ -n "$pinned_id" ]]; then
        manifest_sha="$(expected_sha512 "$pinned_id" || true)"
        if [[ -n "$manifest_sha" ]]; then
            expected_sha="$manifest_sha"
        fi
    fi

    dest="${MODS_DIR}/${file_name}"
    if [[ -f "$dest" ]]; then
        actual=$(sha512sum "$dest" | cut -d" " -f1)
        if [[ "$actual" == "$expected_sha" ]]; then
            echo "  Deja installe: $file_name ($version)"
            ok=$((ok+1))
            continue
        fi
    fi

    echo "  DL $file_name ($version)..."
    tmp=$(mktemp)
    if ! curl -fsSL -o "$tmp" "$file_url"; then
        echo "  ERREUR telechargement" >&2
        rm -f "$tmp"
        failed=$((failed+1))
        continue
    fi
    actual=$(sha512sum "$tmp" | cut -d" " -f1)
    if [[ "$actual" == "$expected_sha" ]]; then
        mv "$tmp" "$dest"
        echo "  OK"
        ok=$((ok+1))
    else
        echo "  SHA mismatch, skip" >&2
        rm -f "$tmp"
        failed=$((failed+1))
    fi
done

echo ""
echo "=== Bilan ==="
echo "OK : $ok | Skip : $skipped | Failed : $failed"
echo ""

if [[ "$failed" = "0" ]]; then
    echo "=== Installation OK ==="
    echo ""
    echo "PROCHAINES ETAPES :"
    if [[ "$LAUNCHER" == "sklauncher" ]]; then
        echo "1. Ouvre SKLauncher"
        echo "2. Selectionne le profil Fabric pour MC $MC_VERSION"
        echo "3. Verifie la version MC = $MC_VERSION (PAS $MC_VERSION.1, PAS $MC_VERSION.4)"
        echo "4. Lance le jeu"
    elif [[ "$LAUNCHER" =~ multimc|prism ]]; then
        echo "1. Ouvre MultiMC/Prism"
        echo "2. Verifie la version MC de l'instance = $MC_VERSION"
        echo "3. Lance le jeu"
    else
        echo "1. Ouvre ton launcher"
        echo "2. Force la version MC a $MC_VERSION (PAS 26.1.x, PAS 26.4+)"
        echo "3. Lance le jeu"
    fi
    echo "4. Verifie que 'Mod Menu' apparait dans le menu principal"
    echo "5. Ajoute le serveur : mc.6ix7even.cc port 25565 (ou artlab:25565 via tailnet)"
    echo "6. Tape /register <password> puis /login <password> en jeu"
    echo ""
    echo "Si probleme : https://github.com/artlab-org/6ix7even-modpack/issues"
else
    echo "=== Installation partielle ==="
    echo "$failed mods ont echoue. Re-lance le script pour retry."
fi

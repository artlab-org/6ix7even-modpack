#!/usr/bin/env python3
"""Generateur deterministe de pack Modrinth (.mrpack) pour le modpack client artlab.

Source de verite : ``mods/manifest.json`` (mods figes, hashes et URLs).

Format de sortie : spec officielle du format de pack Modrinth, telle qu'elle est
implementee par le launcher Modrinth :

  https://github.com/modrinth/code/blob/main/apps/labrinth/src/models/v3/pack.rs
  https://github.com/modrinth/code/blob/main/packages/app-lib/src/api/pack/install_from.rs

  ``PackFormat { game, formatVersion, versionId, name, summary, files[], dependencies{} }``
  ``PackFile   { path, hashes{sha1,sha512}, env{client,server}, downloads[], fileSize }``

Le .mrpack produit ne contient que ``modrinth.index.json`` a la racine, plus un
dossier ``overrides/`` *uniquement* si des overrides reels existent (config/,
resourcepacks/, shaderpacks/ non vides). Les .jar ne sont PAS embarques : le
launcher les telecharge via ``downloads[]``.

Usage :
    python3 tools/build_mrpack.py                # -> dist/<slug>-<version>.mrpack
    python3 tools/build_mrpack.py --validate     # build + validation (code de sortie != 0 si ecart)
    python3 tools/build_mrpack.py --slug artlab --name "Artlab" --summary "..."
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
import zipfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_MANIFEST = REPO_ROOT / "mods" / "manifest.json"
DEFAULT_OUT_DIR = REPO_ROOT / "dist"

# Slug du projet Modrinth : "artlab-client" (slug verifie libre le 2026-11-21 :
# GET /v2/project/artlab-client -> 404 ; projet a creer a la publication).
# Le slug ne sert qu'au NOM du fichier .mrpack : il n'entre pas dans
# modrinth.index.json, le contenu du pack reste inchange.
DEFAULT_SLUG = "artlab-client"
DEFAULT_NAME = "Artlab client"
DEFAULT_SUMMARY = (
    "Modpack client artlab : Minecraft 26.3 (Fabric loader 0.19.5), "
    "13 mods optimises (rendu, performance, monde distant, voix). "
    "Pack genere localement depuis mods/manifest.json."
)

# Dossiers du depot dont le contenu reel est embarque dans overrides/.
OVERRIDE_SOURCES = ("config", "resourcepacks", "shaderpacks")

# Timestamp ZIP fige (minimum de l'epoch ZIP) : indispensable au determinisme.
ZIP_EPOCH = (1980, 1, 1, 0, 0, 0)

INDEX_NAME = "modrinth.index.json"

# Cles obligatoires pour chaque mod du manifeste : leur absence est une erreur
# explicite (et non une KeyError brute au moment de la construction).
REQUIRED_MOD_KEYS = ("slug", "version", "filename", "url", "sha1", "sha512", "size")


def load_manifest(path: Path) -> dict:
    with path.open(encoding="utf-8") as handle:
        manifest = json.load(handle)
    for key in ("version", "mc_version", "fabric_loader", "mods"):
        if key not in manifest:
            raise SystemExit(f"manifest invalide : cle '{key}' absente de {path}")
    mods = manifest["mods"]
    if not isinstance(mods, list):
        raise SystemExit(f"manifest invalide : 'mods' doit etre une liste dans {path}")
    for position, mod in enumerate(mods):
        if not isinstance(mod, dict):
            raise SystemExit(
                f"manifest invalide : mods[{position}] n'est pas un objet dans {path}"
            )
        missing = [key for key in REQUIRED_MOD_KEYS if key not in mod]
        if missing:
            slug = mod.get("slug") or f"#{position}"
            raise SystemExit(
                f"manifest invalide : mod '{slug}' (mods[{position}]) incomplet dans {path} "
                f"— cle(s) manquante(s) : {', '.join(missing)}"
            )
    return manifest


def build_index(manifest: dict, slug: str, name: str, summary: str) -> dict:
    """Construit l'objet modrinth.index.json conforme a la spec Modrinth."""
    files = []
    for mod in manifest["mods"]:
        files.append(
            {
                "path": f"mods/{mod['filename']}",
                "hashes": {"sha1": mod["sha1"], "sha512": mod["sha512"]},
                # pack client : les mods ne sont pas supportes cote serveur.
                "env": {"client": "required", "server": "unsupported"},
                "downloads": [mod["url"]],
                "fileSize": mod["size"],
            }
        )
    return {
        "formatVersion": 1,
        "game": "minecraft",
        "versionId": manifest["version"],
        "name": name,
        "summary": summary,
        "files": files,
        "dependencies": {
            "minecraft": manifest["mc_version"],
            "fabric-loader": manifest["fabric_loader"],
        },
    }


def collect_overrides(repo_root: Path) -> list[tuple[str, bytes]]:
    """Retourne [(chemin dans le .mrpack, contenu)] pour les overrides reels.

    Les .gitkeep et les fichiers caches ne sont pas embarques : sans contenu
    reel, aucun dossier overrides/ n'est cree dans le pack.
    """
    entries: list[tuple[str, bytes]] = []
    for source in OVERRIDE_SOURCES:
        base = repo_root / source
        if not base.is_dir():
            continue
        for path in sorted(base.rglob("*")):
            if not path.is_file():
                continue
            relative = path.relative_to(base)
            if path.name == ".gitkeep":
                continue
            if any(part.startswith(".") for part in relative.parts):
                continue
            entries.append((f"overrides/{source}/{relative.as_posix()}", path.read_bytes()))
    return sorted(entries, key=lambda item: item[0])


def _write_entry(archive: zipfile.ZipFile, name: str, payload: bytes) -> None:
    """Ajoute une entree ZIP de facon deterministe (timestamp et attributs figes)."""
    info = zipfile.ZipInfo(name, date_time=ZIP_EPOCH)
    info.compress_type = zipfile.ZIP_DEFLATED
    info.create_system = 3  # Unix, independant de la machine de build
    info.external_attr = 0o644 << 16
    archive.writestr(info, payload)


def write_mrpack(out_path: Path, index: dict, overrides: list[tuple[str, bytes]]) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    payload = (json.dumps(index, indent=2, ensure_ascii=False) + "\n").encode("utf-8")
    with zipfile.ZipFile(out_path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        _write_entry(archive, INDEX_NAME, payload)
        for name, data in overrides:
            _write_entry(archive, name, data)


def display_path(path: Path) -> str:
    """Chemin relatif au depot si possible, chemin absolu sinon."""
    try:
        return str(path.resolve().relative_to(REPO_ROOT))
    except ValueError:
        return str(path)


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Genere le pack Modrinth (.mrpack) du modpack client artlab.")
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST, help="manifeste des mods")
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR, help="dossier de sortie")
    parser.add_argument("--slug", default=DEFAULT_SLUG, help="slug du pack (nom de fichier)")
    parser.add_argument("--name", default=DEFAULT_NAME, help="nom affiche du pack")
    parser.add_argument("--summary", default=DEFAULT_SUMMARY, help="resume du pack")
    parser.add_argument("--validate", action="store_true", help="valide le pack genere et retourne son code de sortie")
    args = parser.parse_args(argv)

    manifest = load_manifest(args.manifest)
    index = build_index(manifest, args.slug, args.name, args.summary)
    overrides = collect_overrides(REPO_ROOT)

    out_path = args.out_dir / f"{args.slug}-{manifest['version']}.mrpack"
    write_mrpack(out_path, index, overrides)

    print(f"Pack Modrinth genere : {display_path(out_path)}")
    print(f"  formatVersion   : {index['formatVersion']}")
    print(f"  game/version    : {index['game']} / {index['versionId']}")
    print(f"  dependances     : {index['dependencies']}")
    print(f"  mods dans index : {len(index['files'])}")
    print(f"  overrides       : {len(overrides)} fichier(s)")
    print(f"  sha256 (pack)   : {sha256_file(out_path)}")

    if args.validate:
        sys.path.insert(0, str(Path(__file__).resolve().parent))
        import validate_mrpack  # noqa: E402  (import tardif : option --validate)

        return validate_mrpack.main([str(out_path), "--manifest", str(args.manifest)])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

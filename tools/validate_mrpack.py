#!/usr/bin/env python3
"""Validateur de pack Modrinth (.mrpack) pour le modpack client artlab.

Controles :
  * archive ZIP lisible, ``modrinth.index.json`` present a la racine ;
  * structure de l'index conforme a la spec Modrinth
    (https://github.com/modrinth/code/blob/main/apps/labrinth/src/models/v3/pack.rs) ;
  * dependances et versionId coherentes avec ``mods/manifest.json`` ;
  * 13/13 mods declares, un par entree, avec path/hashes/env/downloads/fileSize ;
  * sha1, sha512 et fileSize *recalcules depuis les fichiers reels* (.jar presents
    dans ``mods/``, sinon telecharges depuis ``downloads[]``) et compares a l'index.

Code de sortie : 0 si tout est conforme, 1 sinon.

Usage :
    python3 tools/validate_mrpack.py dist/artlab-1.0.0.mrpack
    python3 tools/validate_mrpack.py                 # auto-detecte le pack de dist/
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
import urllib.request
import zipfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_MANIFEST = REPO_ROOT / "mods" / "manifest.json"
DEFAULT_MODS_DIR = REPO_ROOT / "mods"
DEFAULT_OUT_DIR = REPO_ROOT / "dist"
DEFAULT_CACHE_DIR = DEFAULT_OUT_DIR / ".cache"
INDEX_NAME = "modrinth.index.json"
EXPECTED_FORMAT_VERSION = 1
ALLOWED_DOWNLOAD_HOSTS = ("cdn.modrinth.com",)
VALID_SIDES = ("required", "optional", "unsupported")


class Report:
    """Collecte les controles et affiche un rapport lisible."""

    def __init__(self) -> None:
        self.errors: list[str] = []
        self.checks = 0

    def ok(self, label: str, detail: str = "") -> None:
        self.checks += 1
        suffix = f"  {detail}" if detail else ""
        print(f"OK   {label}{suffix}")

    def ko(self, label: str, detail: str = "") -> None:
        self.checks += 1
        self.errors.append(f"{label}{f'  {detail}' if detail else ''}")
        suffix = f"  {detail}" if detail else ""
        print(f"KO   {label}{suffix}")

    def check(self, condition: bool, label: str, detail_ok: str = "", detail_ko: str = "") -> bool:
        if condition:
            self.ok(label, detail_ok)
        else:
            self.ko(label, detail_ko or detail_ok)
        return condition


def hash_file(path: Path) -> tuple[str, str, int]:
    sha1 = hashlib.sha1()
    sha512 = hashlib.sha512()
    size = 0
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            sha1.update(chunk)
            sha512.update(chunk)
            size += len(chunk)
    return sha1.hexdigest(), sha512.hexdigest(), size


def fetch(url: str, cache_dir: Path, filename: str) -> Path:
    """Recupere le fichier dans le cache (download si absent)."""
    cache_dir.mkdir(parents=True, exist_ok=True)
    target = cache_dir / filename
    if not target.exists() or target.stat().st_size == 0:
        request = urllib.request.Request(url, headers={"User-Agent": "artlab-mrpack-validator/1.0"})
        with urllib.request.urlopen(request, timeout=60) as response:
            target.write_bytes(response.read())
    return target


def auto_detect_pack(out_dir: Path) -> Path:
    candidates = sorted(out_dir.glob("*.mrpack"))
    if not candidates:
        raise SystemExit(f"aucun .mrpack trouve dans {out_dir}")
    if len(candidates) > 1:
        raise SystemExit(f"plusieurs .mrpack dans {out_dir} : {[c.name for c in candidates]}")
    return candidates[0]


def validate(pack_path: Path, manifest_path: Path, mods_dir: Path, cache_dir: Path) -> Report:
    report = Report()
    print(f"== Archive : {pack_path}")
    if not pack_path.exists():
        report.ko("archive presente", "fichier introuvable")
        return report
    report.ok("archive presente", f"{pack_path.stat().st_size} octets")

    if not zipfile.is_zipfile(pack_path):
        report.ko("archive ZIP valide", "le fichier n'est pas une archive ZIP")
        return report
    with zipfile.ZipFile(pack_path) as archive:
        names = archive.namelist()
        report.ok("archive ZIP valide", f"{len(names)} entree(s)")
        if INDEX_NAME not in names:
            report.ko(f"{INDEX_NAME} present a la racine", f"entrees: {names}")
            return report
        report.ok(f"{INDEX_NAME} present a la racine")
        try:
            index = json.loads(archive.read(INDEX_NAME).decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as error:
            report.ko(f"{INDEX_NAME} est du JSON valide", str(error))
            return report
        report.ok(f"{INDEX_NAME} est du JSON valide")

        unexpected = [n for n in names if n != INDEX_NAME and not n.startswith("overrides/")]
        report.check(
            not unexpected,
            "aucune entree inattendue dans le pack",
            f"{len(names) - 1 - len([n for n in names if n.startswith('overrides/')])} entree(s) hors index",
            f"entrees inattendues: {unexpected}",
        )
        embedded_jars = [n for n in names if n.endswith(".jar")]
        report.check(not embedded_jars, "aucun .jar embarque dans le pack (telechargement via downloads[])", "", f"{embedded_jars}")

    with manifest_path.open(encoding="utf-8") as handle:
        manifest = json.load(handle)
    mods = manifest["mods"]

    print("== Structure de modrinth.index.json (spec Modrinth)")
    report.check(index.get("formatVersion") == EXPECTED_FORMAT_VERSION, "formatVersion == 1", f"formatVersion={index.get('formatVersion')}")
    report.check(index.get("game") == "minecraft", 'game == "minecraft"', f"game={index.get('game')}")
    report.check(isinstance(index.get("versionId"), str) and index["versionId"], "versionId present (chaine non vide)", f"versionId={index.get('versionId')}")
    report.check(isinstance(index.get("name"), str) and index["name"], "name present (chaine non vide)", f"name={index.get('name')}")
    report.check(isinstance(index.get("summary"), str) and index["summary"], "summary present (chaine non vide)", f"summary={str(index.get('summary'))[:60]}...")
    dependencies = index.get("dependencies")
    report.check(isinstance(dependencies, dict), "dependencies est un objet", f"dependencies={dependencies}")
    if isinstance(dependencies, dict):
        report.check(
            dependencies.get("minecraft") == manifest["mc_version"],
            'dependencies["minecraft"] == manifest mc_version',
            f"{dependencies.get('minecraft')}",
            f"{dependencies.get('minecraft')} != {manifest['mc_version']}",
        )
        report.check(
            dependencies.get("fabric-loader") == manifest["fabric_loader"],
            'dependencies["fabric-loader"] == manifest fabric_loader',
            f"{dependencies.get('fabric-loader')}",
            f"{dependencies.get('fabric-loader')} != {manifest['fabric_loader']}",
        )
    files = index.get("files")
    report.check(isinstance(files, list), "files est une liste", f"{len(files) if isinstance(files, list) else '?'} entree(s)")

    print("== Coherence avec mods/manifest.json")
    report.check(index.get("versionId") == manifest["version"], "versionId == manifest version", f"{index.get('versionId')}")
    report.check(
        len(files) == len(mods) == 13,
        "13/13 mods declares dans l'index",
        f"index={len(files)} manifest={len(mods)}",
        f"index={len(files)} manifest={len(mods)} (attendu 13)",
    )
    by_path = {entry.get("path"): entry for entry in files} if isinstance(files, list) else {}
    for mod in mods:
        expected_path = f"mods/{mod['filename']}"
        entry = by_path.get(expected_path)
        if entry is None:
            report.ko(f"{mod['slug']} : present dans l'index", f"path absent: {expected_path}")
            continue
        problems = []
        if entry.get("hashes", {}).get("sha1") != mod["sha1"]:
            problems.append("sha1 != manifest")
        if entry.get("hashes", {}).get("sha512") != mod["sha512"]:
            problems.append("sha512 != manifest")
        if entry.get("fileSize") != mod["size"]:
            problems.append(f"fileSize {entry.get('fileSize')} != {mod['size']}")
        if entry.get("downloads") != [mod["url"]]:
            problems.append("downloads != manifest url")
        env = entry.get("env") or {}
        if env.get("client") != "required" or env.get("server") != "unsupported":
            problems.append(f"env={env}")
        report.check(not problems, f"{mod['slug']} : path/hashes/env/downloads/fileSize", expected_path, "; ".join(problems))

    print("== Downloads (hotes autorises par le launcher Modrinth)")
    for entry in files if isinstance(files, list) else []:
        for url in entry.get("downloads", []):
            host = url.split("/")[2] if "://" in url and url.count("/") > 2 else ""
            report.check(
                url.startswith("https://") and host in ALLOWED_DOWNLOAD_HOSTS,
                f"{entry.get('path')} : URL cdn.modrinth.com",
                url,
                f"URL non autorise: {url}",
            )

    print("== Empreintes recalculees depuis les fichiers reels")
    for mod in mods:
        local = mods_dir / mod["filename"]
        entry = by_path.get(f"mods/{mod['filename']}", {})
        if not local.exists():
            try:
                local = fetch(mod["url"], cache_dir, mod["filename"])
            except Exception as error:  # noqa: BLE001 - le cas est reporte dans le rapport
                report.ko(f"{mod['slug']} : fichier real disponible", f"telechargement impossible: {error}")
                continue
        sha1, sha512, size = hash_file(local)
        index_sha1 = (entry.get("hashes") or {}).get("sha1")
        index_sha512 = (entry.get("hashes") or {}).get("sha512")
        index_size = entry.get("fileSize")
        problems = []
        if sha1 != index_sha1:
            problems.append(f"sha1 reel {sha1} != index {index_sha1}")
        if sha512 != index_sha512:
            problems.append(f"sha512 reel {sha512[:16]}... != index {str(index_sha512)[:16]}...")
        if size != index_size:
            problems.append(f"taille reelle {size} != fileSize {index_size}")
        report.check(not problems, f"{mod['slug']} : sha1/sha512/fileSize recalcules", f"{mod['filename']} ({size} o)", "; ".join(problems))

    return report


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Valide un pack Modrinth (.mrpack).")
    parser.add_argument("pack", nargs="?", type=Path, default=None, help="chemin du .mrpack (auto-detect sinon)")
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST, help="manifeste des mods")
    parser.add_argument("--mods-dir", type=Path, default=DEFAULT_MODS_DIR, help="dossier des .jar reels")
    parser.add_argument("--cache-dir", type=Path, default=DEFAULT_CACHE_DIR, help="cache des .jar telecharges")
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR, help="dossier de recherche du pack")
    args = parser.parse_args(argv)

    pack_path = args.pack or auto_detect_pack(args.out_dir)
    report = validate(pack_path, args.manifest, args.mods_dir, args.cache_dir)
    print("")
    if report.errors:
        print(f"== Bilan : {report.checks} controles, {len(report.errors)} ECART(S)")
        for error in report.errors:
            print(f"   - {error}")
        return 1
    print(f"== Bilan : {report.checks} controles OK, 0 ecart")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

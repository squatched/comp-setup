#!/usr/bin/env python3
"""
patch_dd_udkinput.py — Applies keybinding patches to UDKInput.ini

Usage:
    ./patch_dd_udkinput.py [path/to/UDKInput.ini]

If no path is given, falls back to DEFAULT_PATH below.
Edits the file in-place (writes to a temp file then replaces atomically).
"""

from __future__ import annotations

import sys
import os
import tempfile
import re
import stat
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path


class Modifier(Enum):
    Control = "Control=true"
    Shift   = "Shift=true"
    Alt     = "Alt=true"


@dataclass
class Binding:
    key:       str
    modifiers: set[Modifier] = field(default_factory=set)

    def matches_line(self, line: str) -> bool:
        if f'Name="{self.key}"' not in line:
            return False
        return all(m.value in line for m in self.modifiers)

    def apply(self, line: str) -> str:
        """Rewrite Name and modifiers on a line to exactly match this Binding."""
        line = re.sub(r'Name="[^"]*"', f'Name="{self.key}"', line, count=1)
        line = line.rstrip().rstrip(")")
        for m in Modifier:
            line = re.sub(rf',\s*{re.escape(m.value)}', '', line)
        for m in Modifier:
            if m in self.modifiers:
                line += f",{m.value}"
        line += ")"
        return line


@dataclass
class Rebind:
    command:  str      # Matched verbatim against Command="..." on the line
    target:   Binding  # Authoritative desired state
    original: Binding | None = None  # If set, line must also match this to be touched;
                                     # an unmatched original is an error at patch time


# ---------------------------------------------------------------------------
# REBINDS
# Keyed by ini section header (verbatim, including brackets).
# Only sections listed here are touched; everything else passes through.
#
# Each Rebind declares the desired end state for a command.
# `original` disambiguates commands bound to multiple keys — only the line
# whose current Name/modifiers match `original` is rewritten.
# An unmatched `original` is an error. An unmatched original-less Rebind warns.
# ---------------------------------------------------------------------------
M = Modifier  # local alias to keep the table compact

REBINDS: dict[str, list[Rebind]] = {
    "[Engine.PlayerInput]": [
        Rebind("IncreasePlacementTowerRadius",     Binding("RightBrace"),         original=Binding("Add")),
        Rebind("DecreasePlacementTowerRadius",     Binding("LeftBrace"),          original=Binding("Underscore")),
        Rebind("IncreasePlacementTowerRadius",     Binding("RightBracket"),       original=Binding("Equals")),
        Rebind("DecreasePlacementTowerRadius",     Binding("LeftBracket"),        original=Binding("Subtract")),
        Rebind("MoveForward",                      Binding("Comma"),              original=Binding("W")),
        Rebind("MoveBackward",                     Binding("O"),                  original=Binding("S")),
        Rebind("StrafeRight",                      Binding("E"),                  original=Binding("D")),
        Rebind("ShowTradeUI",                      Binding("G"),                  original=Binding("U")),
        Rebind("ToggleActionWheel",                Binding("Y"),                  original=Binding("T")),
        Rebind("CheckActivation",                  Binding("Period"),             original=Binding("E")),
        Rebind("CallOutOn | OnRelease CallOutOff", Binding("J"),                  original=Binding("C")),
        Rebind("CheckAlternateActivation",         Binding("U"),                  original=Binding("F")),
        Rebind("ShowMyHeroInfo",                   Binding("C"),                  original=Binding("I")),
        Rebind("AltFire",                          Binding("P"),                  original=Binding("R")),
        Rebind("ActivateCrystal",                  Binding("I"),                  original=Binding("G")),
        Rebind("ActivateCrystalForAllPlayers",     Binding("I", {M.Control}),     original=Binding("G", {M.Control})),
        Rebind("Button bFreeLook",                 Binding("Quote"),              original=Binding("Q")),
        Rebind("ToggleHUD",                        Binding("D"),                  original=Binding("H")),
        Rebind("tiledshot",                        Binding("K"),                  original=Binding("V")),
        Rebind("toggleItemBeams",                  Binding("X"),                  original=Binding("B")),
        Rebind("DoWeaponSwap",                     Binding("Q"),                  original=Binding("X")),
        Rebind("ToggleHideMiniMapTowers",          Binding("L"),                  original=Binding("P")),
        Rebind("ToggleHideMiniMapBillboards",      Binding("R"),                  original=Binding("O")),
        Rebind("ToggleHideGoodEquipmentOverlay",   Binding("L", {M.Control}),     original=Binding("P", {M.Control})),
        Rebind("ToggleQualityOutline",             Binding("R", {M.Control}),     original=Binding("O", {M.Control})),
        Rebind("ControlEmulatorPlayer1",           Binding("F1"),                 original=Binding("F2")),
        Rebind("ControlEmulatorPlayer2",           Binding("F2"),                 original=Binding("F3")),
        Rebind("ControlEmulatorPlayer3",           Binding("F3"),                 original=Binding("F4")),
        Rebind("ControlEmulatorPlayer4",           Binding("F4"),                 original=Binding("F5")),
        Rebind("BossTimerSkip",                    Binding("K"),                  original=Binding("V")),
        Rebind("SwitchCountdownSkip",              Binding("K", {M.Control}),     original=Binding("V", {M.Control})),
        Rebind("ToggleItemCensor",                 Binding("J", {M.Control}),     original=Binding("C", {M.Control})),
        Rebind("ToggleHysteresis",                 Binding("X", {M.Control}),     original=Binding("B", {M.Control})),
        Rebind("ToggleStepTowardsTarget",          Binding("Colon", {M.Control}), original=Binding("Z", {M.Control})),
        Rebind("DropHalfMana",                     Binding("B"),                  original=Binding("N")),
    ],
}

# ---------------------------------------------------------------------------
# STRING REPLACEMENTS
# Verbatim find-and-replace anywhere in the file, applied after rebinds.
# Format: (find, replace). Each occurrence is replaced.
# ---------------------------------------------------------------------------
STRING_REPLACEMENTS: tuple[tuple[str, str], ...] = (
    ("ConsoleKey=F1", "ConsoleKey=F5"),
)

# ---------------------------------------------------------------------------
# Default file path — adjust if your Steam library is elsewhere
# ---------------------------------------------------------------------------
DEFAULT_PATH = Path.home() / (
    ".local/share/Steam/steamapps/common/"
    "Dungeon Defenders/UDKGame/Config/UDKInput.ini"
)

# ---------------------------------------------------------------------------

def patch(text: str) -> str:
    lines = text.splitlines(keepends=True)
    result = []

    current_section: str | None = None
    active_rebinds: list[Rebind] = []

    # Build per-section match tracking: (section, index) -> matched?
    unmatched_with_original:    set[tuple[str, int]] = set()
    unmatched_without_original: set[tuple[str, int]] = set()
    for section, rebinds in REBINDS.items():
        for i, r in enumerate(rebinds):
            if r.original is not None:
                unmatched_with_original.add((section, i))
            else:
                unmatched_without_original.add((section, i))

    for line in lines:
        stripped = line.rstrip("\n").rstrip("\r")

        # Track current section
        if stripped.startswith("[") and stripped.endswith("]"):
            current_section = stripped
            active_rebinds = REBINDS.get(current_section, [])
            result.append(line)
            continue

        if stripped.startswith("Bindings=(") and active_rebinds:
            for i, rebind in enumerate(active_rebinds):
                if f'Command="{rebind.command}"' not in stripped:
                    continue
                if rebind.original is not None:
                    if not rebind.original.matches_line(stripped):
                        # Already at target state — counts as matched
                        if rebind.target.matches_line(stripped):
                            unmatched_with_original.discard((current_section, i))
                        continue
                    unmatched_with_original.discard((current_section, i))
                else:
                    unmatched_without_original.discard((current_section, i))
                stripped = rebind.target.apply(stripped)
                break

            eol = line[len(line.rstrip("\r\n")):]
            result.append(stripped + eol)
        else:
            result.append(line)

    if unmatched_without_original:
        for section, i in sorted(unmatched_without_original):
            print(
                f'Warning: no line found for command="{REBINDS[section][i].command}"'
                f' in section {section} — the game may not have written this binding yet.',
                file=sys.stderr,
            )

    if unmatched_with_original:
        missed = [
            f'  [{section}] command="{REBINDS[section][i].command}"'
            f' original key="{REBINDS[section][i].original.key}"'
            for section, i in sorted(unmatched_with_original)
        ]
        raise RuntimeError(
            "The following rebinds specify an original binding that was not found in the file.\n"
            "The game may have changed its defaults:\n" + "\n".join(missed)
        )

    patched = "".join(result)

    for find, replace in STRING_REPLACEMENTS:
        patched = patched.replace(find, replace)

    return patched


def backup_path(target: Path) -> Path:
    """Return UDKInput.backup.YYYY-MM-DD(.N).ini, incrementing N if needed."""
    from datetime import date
    stem = f"UDKInput.backup.{date.today().isoformat()}"
    candidate = target.parent / f"{stem}.ini"
    counter = 1
    while candidate.exists():
        candidate = target.parent / f"{stem}.{counter}.ini"
        counter += 1
    return candidate


def main() -> None:
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_PATH

    if not target.exists():
        print(f"Error: file not found: {target}", file=sys.stderr)
        print(
            "If this is a fresh install, try launching Dungeon Defenders once "
            "and saving your settings — that should generate a default UDKInput.ini.",
            file=sys.stderr,
        )
        sys.exit(1)

    original = target.read_text(encoding="utf-8", errors="replace")

    try:
        patched = patch(original)
    except RuntimeError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

    if patched == original:
        print("No changes needed.")
        return

    backup = backup_path(target)
    backup.write_text(original, encoding="utf-8")
    os.chmod(backup, stat.S_IMODE(target.stat().st_mode))
    print(f"Backup:  {backup}")

    original_mode = stat.S_IMODE(target.stat().st_mode)
    fd, tmp_path = tempfile.mkstemp(dir=target.parent, prefix=".patch_tmp_")
    try:
        os.chmod(tmp_path, original_mode)
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write(patched)
        os.replace(tmp_path, target)
    except Exception:
        os.unlink(tmp_path)
        raise

    print(f"Patched: {target}")


if __name__ == "__main__":
    main()

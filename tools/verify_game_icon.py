"""Verify the promoted Squirrel Dash launcher icon and make size QA evidence."""

from __future__ import annotations

import hashlib
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
ACTIVE = ROOT / "assets" / "art" / "game_icon.png"
CONCEPT = ROOT / "assets" / "art" / "icon_concepts" / "04_squirrel_dash.png"
OUT = ROOT / "build" / "icon-qa"
SIZES = (192, 96, 72, 48)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inspect(path: Path) -> Image.Image:
    with Image.open(path) as source:
        assert source.mode == "RGBA", f"{path} must be RGBA, got {source.mode}"
        assert source.width == source.height and source.width > 0, f"{path} must be square"
        alpha_bounds = source.getchannel("A").getbbox()
        assert alpha_bounds is not None, f"{path} must contain non-transparent pixels"
        return source.copy()


def make_contact_sheet(icon: Image.Image) -> Path:
    padding, label_height = 20, 34
    width = sum(SIZES) + padding * (len(SIZES) + 1)
    height = 192 + label_height + padding * 2
    sheet = Image.new("RGBA", (width, height), (31, 55, 42, 255))
    draw = ImageDraw.Draw(sheet)
    x = padding
    for size in SIZES:
        preview = icon.resize((size, size), Image.Resampling.LANCZOS)
        y = padding + (192 - size) // 2
        sheet.alpha_composite(preview, (x, y))
        draw.text((x, padding + 192 + 5), f"{size}px", fill=(255, 244, 216, 255))
        x += size + padding
    OUT.mkdir(parents=True, exist_ok=True)
    target = OUT / "squirrel_dash_launcher_sizes.png"
    sheet.save(target)
    return target


def main() -> None:
    active = inspect(ACTIVE)
    concept = inspect(CONCEPT)
    active_hash = sha256(ACTIVE)
    concept_hash = sha256(CONCEPT)
    assert active_hash == concept_hash, "active icon bytes differ from selected Concept 04"
    assert active.tobytes() == concept.tobytes(), "active icon pixels differ from selected Concept 04"
    contact_sheet = make_contact_sheet(active)
    print(
        "GAME_ICON_VERIFY_PASS "
        f"sha256={active_hash} size={active.size[0]}x{active.size[1]} mode=RGBA "
        f"contact_sheet={contact_sheet}"
    )


if __name__ == "__main__":
    main()

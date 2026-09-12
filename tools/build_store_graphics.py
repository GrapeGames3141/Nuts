#!/usr/bin/env python3
"""Build the Play Store app icon (512x512) and feature graphic (1024x500).

Both are composed from shipped game art so the listing matches the build.
Run from the repo root: python3 tools/build_store_graphics.py
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
ART = ROOT / "assets/art"
OUT = ROOT / "builds/store/nuts"
FONT_BOLD = "/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf"
FONT_REGULAR = "/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf"

# Sampled from the centre and rim of assets/art/game_icon.png so the square
# backdrop blends into the artwork's own circular glow instead of banding.
ICON_CORE = (253, 236, 86)
ICON_RIM = (244, 172, 18)


def radial_background(size: int, core: tuple, rim: tuple) -> Image.Image:
    """Square radial gradient from `core` at the centre to `rim` at the corners."""
    small = 64
    grad = Image.new("RGB", (small, small))
    px = grad.load()
    centre = (small - 1) / 2.0
    for y in range(small):
        for x in range(small):
            d = (((x - centre) ** 2 + (y - centre) ** 2) ** 0.5) / centre
            t = min(1.0, d / 1.05)
            px[x, y] = tuple(round(c + (r - c) * t) for c, r in zip(core, rim))
    return grad.resize((size, size), Image.LANCZOS)


def build_icon() -> Path:
    size = 512
    base = radial_background(size, ICON_CORE, ICON_RIM).convert("RGBA")
    art = Image.open(ART / "game_icon.png").convert("RGBA")
    # The source circle already fills its canvas; scale it to the full square so
    # Play's own corner masking never crops into the squirrel.
    art = art.resize((size, size), Image.LANCZOS)
    base.alpha_composite(art)
    out = OUT / "App icon.png"
    # Play requires a 32-bit PNG with no transparency in the final icon.
    base.convert("RGB").save(out, "PNG")
    return out


def fit_height(image: Image.Image, height: int) -> Image.Image:
    width = round(image.width * height / image.height)
    return image.resize((width, height), Image.LANCZOS)


def outlined_text(draw, xy, text, font, fill, outline, width) -> None:
    draw.text(xy, text, font=font, fill=fill, stroke_width=width, stroke_fill=outline)


def build_feature_graphic() -> Path:
    w, h = 1024, 500
    forest = Image.open(ART / "forest_background.png").convert("RGB")
    # Crop the canopy band, which reads as forest even at feature-graphic height.
    scaled = forest.resize((w, round(forest.height * w / forest.width)), Image.LANCZOS)
    top = round(scaled.height * 0.26)
    base = scaled.crop((0, top, w, top + h)).convert("RGBA")

    # Push the background back so the title and squirrel stay legible.
    base = Image.blend(base, Image.new("RGBA", (w, h), (18, 40, 26, 255)), 0.28)
    base = base.filter(ImageFilter.GaussianBlur(1.6))

    # Soft dark wash behind the left-hand text column.
    wash = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(wash).rectangle([0, 0, 620, h], fill=(12, 30, 20, 150))
    base.alpha_composite(wash.filter(ImageFilter.GaussianBlur(60)))

    squirrel = fit_height(Image.open(ART / "squirrel_front_acorn_v1.png").convert("RGBA"), 452)
    base.alpha_composite(squirrel, (w - squirrel.width - 78, h - squirrel.height - 16))

    draw = ImageDraw.Draw(base)
    title = ImageFont.truetype(FONT_BOLD, 132)
    tagline = ImageFont.truetype(FONT_BOLD, 40)
    sub = ImageFont.truetype(FONT_REGULAR, 31)

    outlined_text(draw, (96, 108), "Nuts!", title, (255, 240, 176), (52, 28, 10), 7)
    outlined_text(draw, (102, 266), "Catch acorns in order", tagline, (255, 255, 255), (30, 18, 8), 5)
    outlined_text(draw, (102, 324), "50 levels through four seasons", sub, (214, 236, 196), (26, 16, 8), 4)

    out = OUT / "Feature graphic.png"
    base.convert("RGB").save(out, "PNG")
    return out


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for path in (build_icon(), build_feature_graphic()):
        with Image.open(path) as image:
            print(f"{path.relative_to(ROOT)} {image.size} {image.mode}")


if __name__ == "__main__":
    main()

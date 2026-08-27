"""Build non-destructive idle/pop head repairs from the generated source sheet."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).parents[1]
SOURCE = ROOT / "assets/art/squirrel_sheet_clean.png"
HEADROOM = 32
OUTPUTS = {
    8: ROOT / "assets/art/squirrel_idle_head_repair_v1.png",
    11: ROOT / "assets/art/squirrel_pop_head_repair_v1.png",
}
# Each profile is (top-edge run start/end, ear/head peak center, half-width, lift).
# A low curved lift across the full run removes the generated flat crop line; the
# narrow peaks restore the missing ear tips without repainting the face or body.
PROFILES = {
    8: [((119, 198), ((138, 17, 15), (178, 15, 17)))],
    11: [((44, 135), ((80, 14, 15),)), ((139, 195), ((170, 12, 12),))],
}


def lift_for(x: int, start: int, end: int, peaks: tuple[tuple[int, int, int], ...]) -> int:
    span = max(1, end - start)
    # A three-pixel rounded forehead contour across each original crop run.
    lift = 3 + round(2 * (1.0 - abs((2.0 * (x - start) / span) - 1.0)))
    for center, half_width, height in peaks:
        distance = abs(x - center)
        if distance <= half_width:
            lift = max(lift, round(height * (1.0 - distance / half_width)))
    return lift


def clean_component(image: Image.Image) -> Image.Image:
    alpha = image.getchannel("A")
    points = {(x, y) for y in range(image.height) for x in range(image.width) if alpha.getpixel((x, y)) > 8}
    components: list[set[tuple[int, int]]] = []
    while points:
        start = points.pop()
        component, queue = {start}, [start]
        while queue:
            px, py = queue.pop()
            for yy in range(py - 1, py + 2):
                for xx in range(px - 1, px + 2):
                    if (xx, yy) in points:
                        points.remove((xx, yy))
                        component.add((xx, yy))
                        queue.append((xx, yy))
        components.append(component)
    if not components:
        return image
    keep = max(components, key=len)
    cleaned = Image.new("RGBA", image.size, (0, 0, 0, 0))
    source_pixels, output_pixels = image.load(), cleaned.load()
    for x, y in keep:
        output_pixels[x, y] = source_pixels[x, y]
    return cleaned


def build(frame: int, cell: Image.Image) -> Image.Image:
    cell = clean_component(cell)
    repaired = Image.new("RGBA", (cell.width, cell.height + HEADROOM), (0, 0, 0, 0))
    repaired.alpha_composite(cell, (0, HEADROOM))
    for (start, end), peaks in PROFILES[frame]:
        for x in range(start, end + 1):
            lift = lift_for(x, start, end, peaks)
            # Reuse each frame's own painterly top-edge colors. Sampling a few
            # pixels down introduces the existing warm fur variation into the tip.
            for offset in range(lift):
                sample_y = min(12, max(0, (lift - offset - 1) // 2))
                color = cell.getpixel((x, sample_y))
                if color[3] <= 8:
                    color = cell.getpixel((x, 0))
                repaired.putpixel((x, HEADROOM - 1 - offset), color)
    return repaired


sheet = Image.open(SOURCE).convert("RGBA")
cell_w, cell_h = sheet.width // 4, sheet.height // 3
for frame, output in OUTPUTS.items():
    x, y = (frame % 4) * cell_w, (frame // 4) * cell_h
    build(frame, sheet.crop((x, y, x + cell_w, y + cell_h))).save(output)
    print(output)

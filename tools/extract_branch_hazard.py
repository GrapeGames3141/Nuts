"""Extract the clean top-right branch from the seasonal hazards source sheet."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).parents[1]
SOURCE = ROOT / "assets/art/items/seasonal_hazards.png"
OUTPUT = ROOT / "assets/art/items/branch_clean_v1.png"


def dominant_component(image: Image.Image) -> Image.Image:
    alpha = image.getchannel("A")
    points = {(x, y) for y in range(image.height) for x in range(image.width) if alpha.getpixel((x, y)) > 8}
    if not points:
        return image
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
    keep = max(components, key=len)
    clean = Image.new("RGBA", image.size, (0, 0, 0, 0))
    source_pixels, clean_pixels = image.load(), clean.load()
    for x, y in keep:
        clean_pixels[x, y] = source_pixels[x, y]
    return clean


sheet = Image.open(SOURCE).convert("RGBA")
cell_width = sheet.width // 2
cell_height = (sheet.height + 1) // 2
# Source sheet is 1312x1199: retain the full 656x600 top-right cell canvas.
branch = sheet.crop((cell_width, 0, sheet.width, cell_height))
dominant_component(branch).save(OUTPUT)
print(OUTPUT)
